{{
    config(
        materialized="view"
    )
}}

WITH 
top_players_grouped_by_team AS 
(
    SELECT 
        team_id,
        team_abbreviation,
        COUNT(*) AS num_players
    FROM 
        {{ ref('stg_top_twenty_players_counting_stats') }}
    GROUP BY team_id, team_abbreviation
),
point_differential_values AS 
(
    SELECT 
        MAX(avg_point_differential) AS max_difference
    FROM 
        {{ ref('stg_head_to_head') }}
),
raw_values AS 
(
    SELECT 
        ds.*,
        h.avg_point_differential,
        h.abs_series_score,
        ht.team_conference AS home_team_conference, 
        ht.team_division AS home_team_division,
        awt.team_conference AS away_team_conference, 
        awt.team_division AS away_team_division,
        hs.conference_rank AS home_team_conference_rank,
        hs.league_rank AS home_team_league_rank,
        aws.conference_rank AS away_team_conference_rank, 
        aws.league_rank AS away_team_league_rank,
        htp.num_players AS num_top_players_home_team, 
        atp.num_players AS num_top_players_away_team
    FROM 
        {{ source('nba_api', 'temp_daily_schedule') }} AS ds
    LEFT JOIN 
        {{ ref('stg_head_to_head') }} AS h 
            ON ds.home_team_id = h.team_id 
            AND ds.away_team_id = h.opponent_id
    LEFT JOIN 
        {{ source('nba_api', 'src_team') }} AS ht -- home team
            ON ds.home_team_id = ht.id
    LEFT JOIN 
        {{ source('nba_api', 'src_team') }} AS awt -- away team
            ON ds.away_team_id = awt.id
    LEFT JOIN 
        {{ ref('stg_current_standings') }} AS hs -- home team standings
            ON ds.home_team_id = hs.team_id
    LEFT JOIN 
        {{ ref('stg_current_standings') }} AS aws -- away team standings
            ON ds.away_team_id = aws.team_id
    LEFT JOIN 
        top_players_grouped_by_team AS htp -- home top players
            ON ds.home_team_id = htp.team_id
    LEFT JOIN 
        top_players_grouped_by_team AS atp -- away top players
            ON ds.away_team_id = atp.team_id
),
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
        -- TO DO: Need to determine how to adjust for two bad teams playing each other - not as exciting
        -- home_team_conference_rank + away_team_conference_rank AS combined_conference_rank, 
        -- home_team_league_rank + away_team_league_rank AS combined_league_rank,
        CASE WHEN home_team_conference = away_team_conference THEN 1 ELSE 0 END AS conference_rival_check,
        CASE WHEN home_team_division = away_team_division THEN 1 ELSE 0 END AS division_rival_check,
        -- If they are not in the same conference, then it is "not exciting" with a max value of 15
        CASE WHEN home_team_conference = away_team_conference THEN ABS(home_team_conference_rank - away_team_conference_rank) ELSE 15 END AS conference_rank_difference_score,
        ABS(home_team_league_rank - away_team_league_rank) AS league_rank_difference_score
    FROM raw_values
),
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
        COALESCE(NULLIF(num_top_players_home_team, 0) / (SELECT MAX(num_players) FROM top_players_grouped_by_team), 0) AS home_team_top_player_score,
        COALESCE(NULLIF(num_top_players_away_team, 0) / (SELECT MAX(num_players) FROM top_players_grouped_by_team), 0) AS away_team_top_player_score,
        
        -- TO DO, THIS IS PRODUCING NaNs; probably not accounting for when net difference is more than 0; STILL NEEDS REFACTORING - getting 0 when one team has a top player
        -- REMINDER TO INCLUDE NEW INPUTS INTO INDEX
        CASE
            WHEN top_player_net_difference = 0 AND num_top_players_home_team + num_top_players_home_team = 0 THEN 1
            WHEN top_player_net_difference = 0 AND num_top_players_home_team + num_top_players_home_team > 0 
                THEN COALESCE(NULLIF(top_player_net_difference, 0) / (SELECT MAX(num_players) FROM top_players_grouped_by_team), 0)
            ELSE COALESCE(NULLIF(top_player_net_difference, 0) / (SELECT MAX(num_players) FROM top_players_grouped_by_team), 0)
        END AS top_player_net_difference_score,
        -- TO DO: Need to adjust for two bad teams playing each other 
        -- ( (conference_rank_difference_score / combined_conference_rank) - (1.0/30) ) / ( (1.0/3) - (1.0/30) ) AS adjusted_conference_score,
        -- ( (league_rank_difference_score / combined_league_rank) - (1.0/59) ) / ( (1.0/3) - (1.0/59) ) AS adjusted_league_score,
        -- the lower the point differential, the closer the previous games were; more exciting
        COALESCE(NULLIF(1.0 - (home_team_league_rank / 30), 0) / (29/30), 0) AS home_team_league_rank_score, 
        COALESCE(NULLIF(1.0 - (away_team_league_rank / 30), 0) / (29/30), 0) AS away_team_league_rank_score,
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
    conference_rival_check, -- conference_rank_score achieves the same thing
    division_rival_check,
    norm_conference_rank_score,
    norm_league_rank_score,
    home_team_top_player_score,
    away_team_top_player_score,
    top_player_net_difference_score,

    -- index calculation
    ROUND(100 * (norm_point_differential_score + series_score + conference_rival_check + division_rival_check + norm_conference_rank_score + norm_league_rank_score) / 6, 2) AS watchability_index,
    -- ROUND(100 * (norm_point_differential_score + series_score + division_rival_check + norm_conference_rank_score + norm_league_rank_score + home_team_league_rank_score + away_team_league_rank_score) / 7, 2) AS adjusted_watchability_index
    -- ROUND(100 * (norm_point_differential_score + series_score + conference_rival_check + division_rival_check + adjusted_conference_score + adjusted_league_score) / 6, 2) AS adjusted_watchability_index
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
    ) / 10, 2) AS adjusted_watchability_index
FROM normalized_inputs
