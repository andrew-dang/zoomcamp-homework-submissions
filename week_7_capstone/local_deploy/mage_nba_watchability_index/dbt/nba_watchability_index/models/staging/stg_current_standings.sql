{{
    config(
        materialized='view'
    )
}}

WITH 
todays_standings as 
(
    SELECT MAX(standingsdate) AS today FROM {{ ref('stg_daily_standings')}}
)
SELECT 
    *
FROM 
    {{ ref('stg_daily_standings')}}
WHERE 
    standingsdate = (SELECT today FROM todays_standings)