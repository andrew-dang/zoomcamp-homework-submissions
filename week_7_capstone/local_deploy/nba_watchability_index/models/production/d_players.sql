{{
    config(
        materialized='table'
    )
}}

SELECT * FROM {{ source('nba_api', 'src_dim_player') }}