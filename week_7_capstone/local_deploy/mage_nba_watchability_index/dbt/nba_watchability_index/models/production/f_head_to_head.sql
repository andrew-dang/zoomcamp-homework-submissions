{{
    config(
        materialized='table'
    )
}}

SELECT * FROM {{ ref("stg_head_to_head") }}