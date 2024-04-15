# imports from api 
from nba_api.stats.endpoints import playerindex, teaminfocommon, teamgamelogs as tgl, leaguedashplayerstats as ldps, scoreboardv2 as sb
from nba_api.stats.static import teams
from nba_api.live.nba.endpoints import scoreboard, boxscore # boxscore used to get who is on the court 
import datetime
import time
import dlt 
import duckdb
import pandas as pd

# Helper functions for data loading
def get_teams_basic():
    """
    This endpoint provides information about teams, notably the team's ID, 
    full name, abbreviation, nickname, and city. 
    """
    nba_teams = teams.get_teams()
    nba_teams_df = pd.DataFrame.from_records(nba_teams)

    return nba_teams_df

def get_team_info_common(team_id_list: list):
    """
    This endpoint provides other important demographic details which we be used 
    to assess the watchability of a game, notably the conference and division which 
    a team belongs to. 
    """
    records = []
    for team_id in team_id_list:
        team = teaminfocommon.TeamInfoCommon(team_id=team_id).team_info_common.get_data_frame().to_dict(orient='records')
        records.append(team[0])

    team_info_common_df = pd.DataFrame.from_records(records)

    return team_info_common_df

def get_opponent_abbreviation(matchup: str):
    """
    Get the opponent abbreviation which is the 3 letter code after @ or vs. within the string. 
    The matchup column in the gamelogs table is a string column.
    Split the matchup string using @ or vs. as the delimiter.  
    """
    if "@" in matchup:
        opp_abbr = matchup.split("@")[1].strip()
    else:
        opp_abbr = matchup.split("vs.")[1].strip()

    return opp_abbr

@dlt.resource(name="src_dim_player", write_disposition="replace")
def load_dim_player():
    players_df = playerindex.PlayerIndex().player_index.get_data_frame()

    yield players_df

@dlt.resource(name="src_daily_standings", write_disposition="replace")
def load_daily_standings(initial_load: bool = False):
    """
    Use the ScoreboardV2 endpoint to get daily standings for current season.
    If initial_load is True, get standings for each day of the season. 
    Otherwise, get the current standings. 
    """
    if initial_load == False:
        for attempt in range(5):
            print(f"Attempt {attempt}: Loading current standings")
            
            try:
                # Get daily standings
                ec = sb.ScoreboardV2().east_conf_standings_by_day.get_data_frame()
                wc = sb.ScoreboardV2().west_conf_standings_by_day.get_data_frame()

                ec['STANDINGSDATE'] = pd.to_datetime(ec['STANDINGSDATE'], format="%m/%d/%Y")
                wc['STANDINGSDATE'] = pd.to_datetime(ec['STANDINGSDATE'], format="%m/%d/%Y")
            
                # Assign conference rank 
                ec["CONFERENCE_RANK"] = ec["W_PCT"].rank(method='first', ascending=False)
                wc["CONFERENCE_RANK"] = wc["W_PCT"].rank(method='first', ascending=False)
            
                # Concatenate dataframes to assign league rank
                daily_lr = pd.concat([ec, wc], ignore_index=True).reset_index(drop=True)
                sort_cols = ["W_PCT", "CONFERENCE_RANK"]
            
                # Get league rankings
                daily_lr["LEAGUE_RANK"] = daily_lr.sort_values(sort_cols, ascending=[False, True]).groupby(sort_cols, sort=False).ngroup() + 1
    
                yield daily_lr

            except:
                print(f"Retrying loading current standings...")
                # Get daily standings
                ec = sb.ScoreboardV2().east_conf_standings_by_day.get_data_frame()
                wc = sb.ScoreboardV2().west_conf_standings_by_day.get_data_frame()

                ec['STANDINGSDATE'] = pd.to_datetime(ec['STANDINGSDATE'], format="%m/%d/%Y")
                wc['STANDINGSDATE'] = pd.to_datetime(ec['STANDINGSDATE'], format="%m/%d/%Y")
            
                # Assign conference rank 
                ec["CONFERENCE_RANK"] = ec["W_PCT"].rank(method='first', ascending=False)
                wc["CONFERENCE_RANK"] = wc["W_PCT"].rank(method='first', ascending=False)
            
                # Concatenate dataframes to assign league rank
                daily_lr = pd.concat([ec, wc], ignore_index=True).reset_index(drop=True)
                sort_cols = ["W_PCT", "CONFERENCE_RANK"]
            
                # Get league rankings
                daily_lr["LEAGUE_RANK"] = daily_lr.sort_values(sort_cols, ascending=[False, True]).groupby(sort_cols, sort=False).ngroup() + 1

                yield daily_lr
                
            else:
                break
        else:
            print("Out of retries. Could not load standings")
    
    # If inital_load is False, load historic standings since the first standings update
    else:
        # Constants
        FIRST_STANDINGS_UPDATE_DATE = datetime.datetime(2023, 10, 25, 11, 30)
        TODAY = datetime.datetime.today()
        DELTA = (TODAY - FIRST_STANDINGS_UPDATE_DATE).days
    
        for day_offset in range(DELTA, -1, -1):
            print(f"Getting standings for {day_offset} days from today", end="\r")
            for attempts in range(5):
                try:
                    # Get daily standings
                    ec = sb.ScoreboardV2(day_offset=-day_offset).east_conf_standings_by_day.get_data_frame()
                    wc = sb.ScoreboardV2(day_offset=-day_offset).west_conf_standings_by_day.get_data_frame()

                    # Convert STANDINGSDATE to datetime
                    ec['STANDINGSDATE'] = pd.to_datetime(ec['STANDINGSDATE'], format="%m/%d/%Y")
                    wc['STANDINGSDATE'] = pd.to_datetime(ec['STANDINGSDATE'], format="%m/%d/%Y")
                
                
                    # Assign conference rank 
                    ec["CONFERENCE_RANK"] = ec["W_PCT"].rank(method='first', ascending=False)
                    wc["CONFERENCE_RANK"] = wc["W_PCT"].rank(method='first', ascending=False)
                
                    # Concatenate dataframes to assign league rank
                    daily_lr = pd.concat([ec, wc], ignore_index=True).reset_index(drop=True)
                    sort_cols = ["W_PCT", "CONFERENCE_RANK"]
                
                    # Get league rankings
                    daily_lr["LEAGUE_RANK"] = daily_lr.sort_values(sort_cols, ascending=[False, True]).groupby(sort_cols, sort=False).ngroup() + 1
    
                    yield daily_lr
                    
                except:
                    print(f"Retrying getting data for {day_offset} days from today...")
                    # Get daily standings
                    ec = sb.ScoreboardV2(day_offset=-day_offset).east_conf_standings_by_day.get_data_frame()
                    wc = sb.ScoreboardV2(day_offset=-day_offset).west_conf_standings_by_day.get_data_frame()
                     
                    # Convert STANDINGSDATE to datetime
                    ec['STANDINGSDATE'] = pd.to_datetime(ec['STANDINGSDATE'], format="%m/%d/%Y")
                    wc['STANDINGSDATE'] = pd.to_datetime(ec['STANDINGSDATE'], format="%m/%d/%Y")
                
                    # Assign conference rank 
                    ec["CONFERENCE_RANK"] = ec["W_PCT"].rank(method='first', ascending=False)
                    wc["CONFERENCE_RANK"] = wc["W_PCT"].rank(method='first', ascending=False)
                
                    # Concatenate dataframes to assign league rank
                    daily_lr = pd.concat([ec, wc], ignore_index=True).reset_index(drop=True)
                    sort_cols = ["W_PCT", "CONFERENCE_RANK"]
                
                    # Get league rankings
                    daily_lr["LEAGUE_RANK"] = daily_lr.sort_values(sort_cols, ascending=[False, True]).groupby(sort_cols, sort=False).ngroup() + 1
    
                    yield daily_lr
                    
                else:
                    break
            else:
                print("Out of retries. Moving to next day's standings.")
                time.sleep(2)
                continue

            time.sleep(2)

@dlt.resource(name='src_player_stats', write_disposition='replace')
def load_player_stats():
    player_stats_df = ldps.LeagueDashPlayerStats(per_mode_detailed="PerGame").league_dash_player_stats.get_data_frame()

    yield player_stats_df

@dlt.resource(name="src_team", write_disposition='replace')
def load_dim_team():
    """
    Uses get_team_basic() and get_team_info_common() and joins results together to get 
    the necessary details of the NBA teams. 
    """
    teams_basic = get_teams_basic()
    team_id_list = teams_basic["id"].to_list() # List of team ids to be used in team_info_common()
    team_info_common = get_team_info_common(team_id_list)

    # Join two dataframes together 
    dim_team = teams_basic.merge(team_info_common[["TEAM_ID", "TEAM_CONFERENCE", "TEAM_DIVISION"]], left_on='id', right_on='TEAM_ID')

    yield dim_team

@dlt.resource(name='src_teamlogs', write_disposition='replace')
def load_teamlogs():
    """
    Gets logs of every NBA game played in the 2023-2024 season. 
    Only return the relevant columns.

    Returns:
    --------
    sel_teamlogs (pd.DataFrame): DataFrame containing the relevant columns. 
    
    """
    
    # Relevant columns to select from API response
    SEL_COLS = [
        "SEASON_YEAR",
        "TEAM_ID",
        "TEAM_ABBREVIATION",
        "TEAM_NAME",
        "GAME_ID",
        "GAME_DATE",
        "MATCHUP",
        "WL",
        "PLUS_MINUS"
    ]
    
    # Get team logs
    teamlogs = tgl.TeamGameLogs(season_nullable="2023-24").team_game_logs.get_data_frame()
    sel_teamlogs = teamlogs[SEL_COLS]

    # Get opponent abbreviation. This will be used to calculate head-to-head stats downstream. 
    sel_teamlogs["OPPONENT_ABBREVIATION"] = sel_teamlogs["MATCHUP"].apply(lambda x: get_opponent_abbreviation(x))

    yield sel_teamlogs

@dlt.resource(name='temp_daily_schedule', write_disposition='replace')
def load_daily_schedule():
    todays_scoreboard = scoreboard.ScoreBoard().get_dict()['scoreboard']

    # Store records
    records = []
    for game in todays_scoreboard['games']:
        game_dict = {
        "game_date": todays_scoreboard['gameDate'],
        "game_id": game['gameId'],
        "start_time": game['gameTimeUTC'],
        "home_team_id": game['homeTeam']['teamId'],
        "home_team_abbreviation": game['homeTeam']['teamTricode'],
        "away_team_id": game['awayTeam']['teamId'],
        "away_team_abbreviation": game['awayTeam']['teamTricode']
        }

        records.append(game_dict)

    # Create dataframe 
    daily_schedule = pd.DataFrame().from_records(records)

    yield daily_schedule
    
# Refresh all dlt pipelines with one command
def refresh_db():
    # Create DuckDb connection 
    db_path = "../duckdb_files/database.db"
    con = duckdb.connect(db_path)

    # Create pipelines for each dlt resource 
    dim_player_pipeline = dlt.pipeline(
        pipeline_name="player_info_to_db",
        destination=dlt.destinations.duckdb(credentials=con),
        dataset_name="nba_api",
        )
    
    standings_pipeline = dlt.pipeline(
        pipeline_name="standings_to_db", 
        destination=dlt.destinations.duckdb(credentials=con),
        dataset_name="nba_api",
        )
    
    dim_team_pipeline = dlt.pipeline(
        pipeline_name="team_info_to_db", 
        destination=dlt.destinations.duckdb(credentials=con),
        dataset_name="nba_api",
        )
    
    player_stats_pipeline = dlt.pipeline(
        pipeline_name="player_stats_to_db", 
        destination=dlt.destinations.duckdb(credentials=con),
        dataset_name="nba_api",
        )
    
    teamlogs_pipeline = dlt.pipeline(
        pipeline_name="teamlogs_to_db", 
        destination=dlt.destinations.duckdb(credentials=con),
        dataset_name="nba_api",
        )
    
    daily_schedule_pipeline = dlt.pipeline(
        pipeline_name='daily_schedule_to_db',
        destination=dlt.destinations.duckdb(credentials=con),
        dataset_name="nba_api",
        )

    # Run each pipeline
    dim_player_info = dim_player_pipeline.run(
        data=load_dim_player
        )
    
    standings_info = standings_pipeline.run(
        data=load_daily_standings(True)
        )
    
    dim_team_info = dim_team_pipeline.run(
        data=load_dim_team
        )
    
    player_stats_info = player_stats_pipeline.run(
        data=load_player_stats
        )
    
    teamlogs_info = teamlogs_pipeline.run(
        data=load_teamlogs
        )
    
    daily_schedule_info = daily_schedule_pipeline.run(
        data=load_daily_schedule
        )

    # Close connection
    con.close()