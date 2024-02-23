{{ config(materialized='table') }}

-- count records by year-month and trip type

WITH 
colored_trips AS (
    SELECT 
        date_trunc('month', pickup_datetime) AS year_month,
        pickup_borough,
        service_type,
        COUNT(tripid) AS num_trips
    FROM {{ ref('fact_trips') }}
    GROUP BY year_month, pickup_borough, service_type
),
fhv_trips AS (
    SELECT
        date_trunc('month', pickup_datetime) AS year_month,
        pickup_borough,
        service_type,
        COUNT(tripid) AS num_trips
    FROM {{ ref('fact_fhv_trips') }}
    GROUP BY year_month, pickup_borough, service_type
)
SELECT * FROM colored_trips
UNION 
SELECT * FROM fhv_trips