{{
    config(
        materialized="view"
    )
}}

WITH 
head_to_head AS 
(
    SELECT 
        team_id, 
        team_abbreviation,
        opponent_id,
        opponent_abbreviation,
        AVG(ABS(plus_minus)) AS avg_point_differential, 
        SUM(CASE WHEN wl = 'L' THEN -1 ELSE 1 END) AS series_score,
        ABS(SUM(CASE WHEN wl = 'L' THEN -1 ELSE 1 END)) AS abs_series_score 
    FROM 
        {{ ref('stg_teamlogs') }}
    GROUP BY team_id, team_abbreviation, opponent_id, opponent_abbreviation
) 
-- TO DO: Add matchup ID (install required dbt packages)
SELECT 
    {{ dbt_utils.generate_surrogate_key(['team_id', 'opponent_id']) }} AS matchup_id, 
    *
FROM head_to_head