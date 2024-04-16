if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data(*args, **kwargs):
    """
    Template code for loading data from any source.

    Returns:
        Anything (e.g. data frame, dictionary, array, int, str, etc.)
    """
    import dlt
    from mage_nba_watchability_index.utils.dlt_resources import dlt_nba as dn

    # Player stats didn't load initially
    player_stats_pipeline = dlt.pipeline(
        pipeline_name="player_stats_to_db", 
        destination='bigquery',
        dataset_name="nba_api",
        )

    # Run the pipeline
    player_stats_info = player_stats_pipeline.run(
        data=dn.load_player_stats
        )


@test
def test_output(*args) -> None:
    """
    Template code for testing the output of the block.
    """
    pass
