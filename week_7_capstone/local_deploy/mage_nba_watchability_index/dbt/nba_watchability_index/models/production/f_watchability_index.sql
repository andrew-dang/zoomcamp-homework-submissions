{{
    config(
        materialized='table'
    )
}}

WITH 
-- top 20 players by total counting stats
top_twenty_players AS 
(
    SELECT 
        * 
    FROM 
        {{ ref('f_player_stats') }}
    ORDER BY avg_counting_stats_per_game DESC
    LIMIT 20
),
-- how many top players each team has
top_players_grouped_by_team AS 
(
    SELECT 
        team_id,
        team_abbreviation,
        COUNT(*) AS num_players
    FROM 
        top_twenty_players
    GROUP BY team_id, team_abbreviation
),
-- What is the max value of point differential in the head_to_head table
point_differential_values AS 
(
    SELECT 
        MAX(avg_point_differential) AS max_difference
    FROM 
        {{ ref('f_head_to_head') }}
),

-- join daily schedule with several other fact tables and dimension tables to get raw values for index calculation
raw_values AS 
(
    SELECT 
        ds.*,
        h.avg_point_differential,
        h.abs_series_score,
        ht.conference AS home_team_conference, 
        ht.division AS home_team_division,
        awt.conference AS away_team_conference, 
        awt.division AS away_team_division,
        hs.conference_rank AS home_team_conference_rank,
        hs.league_rank AS home_team_league_rank,
        aws.conference_rank AS away_team_conference_rank, 
        aws.league_rank AS away_team_league_rank,
        htp.num_players AS num_top_players_home_team, 
        atp.num_players AS num_top_players_away_team
    FROM 
        {{ ref('d_daily_schedule') }} AS ds
    LEFT JOIN 
        {{ ref('f_head_to_head') }} AS h 
            ON ds.home_team_id = h.team_id 
            AND ds.away_team_id = h.opponent_id
    LEFT JOIN 
        {{ ref('d_teams') }} AS ht -- home team
            ON ds.home_team_id = ht.team_id
    LEFT JOIN 
        {{ ref('d_teams') }} AS awt -- away team
            ON ds.away_team_id = awt.team_id
    LEFT JOIN 
        {{ ref('f_current_standings') }} AS hs -- home team standings
            ON ds.home_team_id = hs.team_id
    LEFT JOIN 
        {{ ref('f_current_standings') }} AS aws -- away team standings
            ON ds.away_team_id = aws.team_id
    LEFT JOIN 
        top_players_grouped_by_team AS htp -- home top players
            ON ds.home_team_id = htp.team_id
    LEFT JOIN 
        top_players_grouped_by_team AS atp -- away top players
            ON ds.away_team_id = atp.team_id
),

-- initial calculations for index inputs: difference in top players, rival checks, and difference in conference and league rank
index_inputs AS 
(
    SELECT 
        game_date,
        game_id, 
        start_time, 
        home_team_id, 
        home_team_abbreviation,
        away_team_id, 
        away_team_abbreviation,
        home_team_league_rank,
        away_team_league_rank,
        avg_point_differential,
        abs_series_score,
        num_top_players_home_team,
        num_top_players_away_team,
        ABS(num_top_players_home_team - num_top_players_away_team) AS top_player_net_difference, 
        CASE WHEN home_team_conference = away_team_conference THEN 1 ELSE 0 END AS conference_rival_check,
        CASE WHEN home_team_division = away_team_division THEN 1 ELSE 0 END AS division_rival_check,
        -- If they are not in the same conference, then it is "not exciting" with a max value of 15
        CASE WHEN home_team_conference = away_team_conference THEN ABS(home_team_conference_rank - away_team_conference_rank) ELSE 15 END AS conference_rank_difference_score,
        ABS(home_team_league_rank - away_team_league_rank) AS league_rank_difference_score
    FROM raw_values
),

-- normalize inputs so they all fall within the range of 0-1
normalized_inputs AS
(
    SELECT 
        game_date,
        game_id, 
        start_time, 
        home_team_id, 
        home_team_abbreviation,
        away_team_id, 
        away_team_abbreviation,
        -- assign a score based on number of "good" players for each team 
        COALESCE(NULLIF(num_top_players_home_team, 0) / (SELECT MAX(num_players) FROM top_players_grouped_by_team), 0) AS home_team_top_player_score,
        COALESCE(NULLIF(num_top_players_away_team, 0) / (SELECT MAX(num_players) FROM top_players_grouped_by_team), 0) AS away_team_top_player_score,
        -- assign a score based on the difference of "good" players between the teams; if both teams have 0 then assign min score, else, assign score based normalized by max difference
        CASE
            WHEN top_player_net_difference = 0 AND num_top_players_home_team + num_top_players_home_team = 0 THEN 1
            -- WHEN top_player_net_difference = 0 AND num_top_players_home_team + num_top_players_home_team > 0 
            --     THEN COALESCE(NULLIF(top_player_net_difference, 0) / (SELECT MAX(num_players) FROM top_players_grouped_by_team), 0)
            ELSE COALESCE(NULLIF(top_player_net_difference, 0) / (SELECT MAX(num_players) FROM top_players_grouped_by_team), 0)
        END AS top_player_net_difference_score,
        -- assign an excitement score that is weighted by the team's position on the league table
        COALESCE(NULLIF(1.0 - (home_team_league_rank / 30), 0) / (29/30), 0) AS home_team_league_rank_score, 
        COALESCE(NULLIF(1.0 - (away_team_league_rank / 30), 0) / (29/30), 0) AS away_team_league_rank_score,
        -- assign a score for avg point differential which is normalized by the max differential
        1.0 - COALESCE(NULLIF(avg_point_differential,0) / (SELECT max_difference FROM point_differential_values), 0) AS norm_point_differential_score,
        -- maximum value of abs_series_score is 4, min is 0 
        1.0 - COALESCE(NULLIF(abs_series_score,0)/4, 0) AS series_score,
        conference_rival_check,
        division_rival_check,
        -- maximum value of the conference rank score is 15, min is 1; higher score is better
        1.0 - (conference_rank_difference_score - 1 )/14 AS norm_conference_rank_score,
        -- maximum value league rank score 29, min is 1
        1.0 - (league_rank_difference_score - 1)/28 AS norm_league_rank_score
    FROM index_inputs
)
SELECT 
    game_date,
    game_id, 
    start_time, 
    home_team_id, 
    home_team_abbreviation,
    away_team_id, 
    away_team_abbreviation,
    
    -- inputs to index 
    home_team_league_rank_score, 
    away_team_league_rank_score,
    norm_point_differential_score,
    series_score, 
    division_rival_check,
    norm_conference_rank_score,
    norm_league_rank_score,
    home_team_top_player_score,
    away_team_top_player_score,
    top_player_net_difference_score,

    -- index calculation
    ROUND(100 * (norm_point_differential_score + 
    series_score + 
    division_rival_check + 
    norm_conference_rank_score + 
    norm_league_rank_score + 
    home_team_league_rank_score + 
    away_team_league_rank_score +
    home_team_top_player_score +
    away_team_top_player_score +
    top_player_net_difference_score
    ) / 10, 2) AS watchability_index
FROM normalized_inputs