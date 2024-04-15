{{
    config(
        materialized='table'
    )
}}

SELECT * FROM {{ source('nba_api', 'temp_daily_schedule') }}