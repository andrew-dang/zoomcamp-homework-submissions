if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter


@data_exporter
def export_data(file_dict: dict, *args, **kwargs):
    """
    Use dlt to export taxi data to Postgres

    Args:
       file_dict (dict): Dictionary containing file paths for each service type to be uploaded

    """
    import pandas as pd
    import dlt 
    from dlt.destinations import postgres
    import time

    # Go through each color to get the list of files to upload
    for color in file_dict.keys():
        file_paths = file_dict[color]


        # Define dtypes as it is different from csv to csv
        if color == 'green':
            df_dtypes = {
                "VendorID": pd.Int64Dtype(),
                "store_and_fwd_flag": object,
                "RatecodeID": pd.Int64Dtype(),
                "PULocationID": pd.Int64Dtype(), 
                "DOLocationID": pd.Int64Dtype(),
                "passenger_count": pd.Int64Dtype(),
                "trip_distance": float,
                "fare_amount": float,
                "extra": float, 
                "mta_tax": float,
                "tip_amount": float,
                "tolls_amount": float, 
                "improvement_surcharge": float,
                "total_amount": float,
                "payment_type": pd.Int64Dtype(),
                "trip_type": pd.Int64Dtype(),
                "congestion_surcharge": float
                }

            parse_dates = ['lpep_pickup_datetime', 'lpep_dropoff_datetime']
            date_format = "%Y-%m-%d %H:%M:%S"

            # dataset is the postgres schema

            pipeline = dlt.pipeline(
                pipeline_name='green_pipeline',
                destination=postgres(credentials="postgresql://dev:dev@postgres:5432/production"),  
                dataset_name='dev',
                export_schema_path="/schemas/export"
            )

            for file_path in file_paths:
                print(f"Loading data from file to Postgres: {file_path}")
                load_start = time.time()

                pipeline.run(
                    pd.read_csv(
                        file_path, 
                        chunksize=100, 
                        dtype=df_dtypes, 
                        parse_dates=parse_dates, 
                        date_format=date_format
                        ),
                    table_name='src_green_tripdata',
                    write_disposition="append"
                )
                
                load_end = time.time()
                print(f"Time to load file: {load_end - load_start}")
        
        elif color == 'yellow':
            df_dtypes = {
                "VendorID": pd.Int64Dtype(),
                "store_and_fwd_flag": object,
                "RatecodeID": pd.Int64Dtype(),
                "PULocationID": pd.Int64Dtype(), 
                "DOLocationID": pd.Int64Dtype(),
                "passenger_count": pd.Int64Dtype(),
                "trip_distance": float,
                "fare_amount": float,
                "extra": float, 
                "mta_tax": float,
                "tip_amount": float,
                "tolls_amount": float, 
                "improvement_surcharge": float,
                "total_amount": float,
                "payment_type": pd.Int64Dtype(),
                "congestion_surcharge": float,
                "airport_fee": float
                }

            parse_dates = ['tpep_pickup_datetime', 'tpep_dropoff_datetime']
            date_format = "%Y-%m-%d %H:%M:%S"

            # dataset is the postgres schema

            pipeline = dlt.pipeline(
                pipeline_name='yellow_pipeline',
                destination=postgres(credentials="postgresql://dev:dev@postgres:5432/production"),  
                dataset_name='dev',
                export_schema_path="/schemas/export"
            )

            for file_path in file_paths:
                print(f"Loading data from file to Postgres: {file_path}")
                load_start = time.time()

                pipeline.run(
                    pd.read_csv(
                        file_path, 
                        chunksize=100, 
                        dtype=df_dtypes, 
                        parse_dates=parse_dates, 
                        date_format=date_format
                        ),
                    table_name='src_yellow_tripdata',
                    write_disposition="append"
                )

                load_end = time.time()
                print(f"Time to load file: {load_end - load_start}")
        else:
            
            @dlt.resource(name="fhv_data")
            def read_fhv(file_path):
                for df in pd.read_csv(file_path, chunksize=100):
                    
                    # lowercase column names to make it consistent across files 
                    df.columns = df.columns.str.lower()

                    # cast field types for consistency across files
                    dtype_dict = {
                        "dispatching_base_num": str,
                        "pulocationid":pd.Int64Dtype(),
                        "dolocationid": pd.Int64Dtype(), 
                        "sr_flag": pd.Float64Dtype(),
                        "affiliated_base_number": str
                    }

                    df = df.astype(dtype_dict)

                    # Datetime columns
                    df['pickup_datetime'] = pd.to_datetime(df['pickup_datetime'])
                    df['dropoff_datetime'] = pd.to_datetime(df['dropoff_datetime'])

                    print("Another chunk inserted")

                    yield df

            pipeline = dlt.pipeline(
                pipeline_name='fhv_pipeline',
                destination=postgres(credentials="postgresql://dev:dev@postgres:5432/production"), 
                dataset_name='dev',
                export_schema_path="/schemas/export"
            )

            for file_path in file_paths:
                print(f"Loading data from file to Postgres: {file_path}")
                load_start = time.time()

                pipeline.run(
                    read_fhv(file_path),
                    table_name='src_fhv_tripdata',
                    write_disposition="append",
                )

                load_end = time.time()
                print(f"Time to load file: {load_end - load_start}")
