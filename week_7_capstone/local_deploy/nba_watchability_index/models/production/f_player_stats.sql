{{
    config(
        materialized='table'
    )
}}

SELECT * FROM {{ ref("stg_player_stats") }}