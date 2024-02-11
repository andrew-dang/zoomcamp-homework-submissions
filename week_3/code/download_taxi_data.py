import os 

base_url = 'https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2022'

for month in range(1,13):
    # Add leading 0 for first 9 months
    month = str(month)

    if len(month) == 1:
        month = month.zfill(2)
    
    # Build url
    url = base_url + f'-{month}.parquet'

    # Download data
    print(f"Downloading data from {url}")
    os.system(f"wget {url}")
    