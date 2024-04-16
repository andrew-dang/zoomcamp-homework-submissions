{{
    config(
        materialized='view'
    )
}}

SELECT 
    * 
FROM 
    {{ ref('stg_player_stats') }}
ORDER BY avg_counting_stats_per_game DESC
LIMIT 20