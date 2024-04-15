{{
    config(
        materialized='view'
    )
}}

SELECT 
    team_id, 
    season_id, 
    strptime(standingsdate, '%m/%d/%Y') AS standingsdate,
    conference, 
    team, 
    g,
    w,
    l,
    w_pct,
    home_record, 
    road_record,
    conference_rank, 
    league_rank
FROM 
    {{ source('nba_api', 'src_daily_standings') }}