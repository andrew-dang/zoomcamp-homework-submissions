if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data(*args, **kwargs):
    """
    Get data from several NBA API endpoints, perform some very basic
    transformations, and load the data to BigQuery.
    """
    import dlt
    import time
    import duckdb
    from mage_nba_watchability_index.utils.dlt_resources import dlt_nba as dn
    
    con = duckdb.connect('/home/src/mage_nba_watchability_index/dbt/nba_watchability_index/duckdb_files/database.db')

    # Create pipelines 
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

    # Run the pipelines 
    dim_player_info = dim_player_pipeline.run(
        data=dn.load_dim_player
        )
    
    print("Player info loaded.")
    
    # Wait 1 second between pipelines
    time.sleep(1)
    standings_info = standings_pipeline.run(
        data=dn.load_daily_standings
        )
    
    # Wait 1 second between pipelines
    time.sleep(1)
    player_stats_info = player_stats_pipeline.run(
        data=dn.load_player_stats
        )

    print("Player stats loaded.")
    
    # Wait 1 second between pipelines
    time.sleep(1)
    teamlogs_info = teamlogs_pipeline.run(
        data=dn.load_teamlogs
        )
    
    print("Teamlogs loaded.")
    
    # Wait 1 second between pipelines
    time.sleep(1)
    daily_schedule_info = daily_schedule_pipeline.run(
        data=dn.load_daily_schedule
        )
    
    print("Today's schedule loaded.")

    con.close()


@test
def test_output(*args) -> None:
    """
    Template code for testing the output of the block.
    """
    pass
