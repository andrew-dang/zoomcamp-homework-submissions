{{
    config(
        materialized='table'
    )
}}

SELECT * FROM {{ ref("stg_current_standings") }}