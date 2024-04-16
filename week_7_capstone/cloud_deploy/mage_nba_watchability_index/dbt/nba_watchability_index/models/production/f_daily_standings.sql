{{
    config(
        materialized='incremental',
        unique_key=['standingsdate', 'team_id']
    )
}}

SELECT 
    * 
FROM {{ ref("stg_daily_standings") }}
{% if_incremental() %}
    WHERE standingsdate >= (SELECT MAX(standingsdate) FROM {{ this }})
{% endif %}