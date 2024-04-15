{{ 
    config(
        materialized="view"
    )
}}


SELECT 
    tl.season_year, 
    tl.game_id, 
    tl.game_date,
    tl.team_id,
    tl.team_abbreviation,
    d.team_id AS opponent_id,
    tl.opponent_abbreviation,
    wl, 
    plus_minus
FROM 
    {{ source('nba_api', 'src_teamlogs')}} AS tl
LEFT JOIN 
    {{ source('nba_api', 'src_team')}} AS d
        ON tl.opponent_abbreviation = d.abbreviation
