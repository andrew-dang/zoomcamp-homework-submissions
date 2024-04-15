{{
    config(
        materialized='view'
    )
}}

WITH 
source AS 
(
    SELECT 
        *, 
        pts + reb + ast + stl + blk AS avg_counting_stats_per_game
    FROM 
        {{ source('nba_api', 'src_player_stats') }}
)

SELECT 
    player_id, 
    player_name,  
    team_id, 
    team_abbreviation,
    pts,
    reb,
    ast,
    stl,
    blk, 
    age, 
    gp,  
    fgm,
    fga,
    fg_pct,
    ftm,
    fta,
    ft_pct,
    avg_counting_stats_per_game
FROM source