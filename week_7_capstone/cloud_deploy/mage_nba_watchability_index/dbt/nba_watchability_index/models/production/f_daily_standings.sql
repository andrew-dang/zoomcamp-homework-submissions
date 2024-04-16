{{
    config(
        materialized='table'
    )
}}

SELECT * FROM {{ ref("stg_daily_standings") }}