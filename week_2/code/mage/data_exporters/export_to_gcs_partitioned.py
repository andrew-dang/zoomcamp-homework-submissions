import pyarrow as pa 
import pyarrow.parquet as pq 
import os

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = "/home/src/terraform-runner.json"

bucket_name = "zoomcamp-2024-412415-demo-bucket"
project_id = "zoomcamp-2024-412415"
table_name = "nyc_green_taxi_data"
root_path = f'{bucket_name}/{table_name}'


@data_exporter
def export_data(data, *args, **kwargs):
    """
    Export NYC taxi data to GCS as partitioned parquet

    Args:
        data: The output from the upstream parent block
        args: The output from any additional upstream blocks (if applicable)

    Output (optional):
        Optionally return any object and it'll be logged and
        displayed when inspecting the block run.
    """
    
    # Convert date column to datetime type; required for PyArrow
    data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date 

    # PyArrow uses a Table object to perform partitioning
    table = pa.Table.from_pandas(data)

    # Define a filesystem
    gcs = pa.fs.GcsFileSystem()

    pq.write_to_dataset(
        table, 
        root_path=root_path,
        partition_cols=['lpep_pickup_date'],
        filesystem=gcs
    )