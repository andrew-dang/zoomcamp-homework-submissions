{{
    config(
        materialized='table'
    )
}}

SELECT 
    team_id, 
    full_name AS team_name, 
    abbreviation, 
    nickname, 
    city, 
    team_conference AS conference,
    team_division AS division
FROM {{ source('nba_api', ) }}