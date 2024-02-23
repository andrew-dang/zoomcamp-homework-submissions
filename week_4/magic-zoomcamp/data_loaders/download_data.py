if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def download_data(*args, **kwargs):
    """
    Download data from GitHub Repo to a folder in the home directory of the local repo. 
    
    Returns:
        file_dict (dict): A dictionary containing the local path to downloaded data in the run. 
    """
    # Base URL to download files 
    import os
    import os.path
    

    BASE_URL = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download"
    
    

    # Get runtime variables to determine what file to load 
    colors = kwargs.get("colors")
    months = kwargs.get("months")
    years = kwargs.get("years")
    execution_date = kwargs.get("execution_date")

    # year = str(execution_date.year)
    # month = str(execution_date.month).zfill(2)

    # print(f"{year}-{month}")
    
    # Empty list for file names 
    file_dict = {}
    for color in colors:
        # Empty list to store file paths
        file_paths = []
        
        # Directory to save downloaded data
        DATA_DIR = f"/home/src/data/{color}"
        
        for year in years:
            for month in months:
                FILE_NAME = f"{color}_tripdata_{year}-{str(month).zfill(2)}.csv.gz"
                FILE_URL = f"{BASE_URL}/{color}/{FILE_NAME}"
                DEST_PATH = f"{DATA_DIR}/{FILE_NAME}"

                # Check if file exists
                if os.path.isfile(DEST_PATH):
                    print(f"File already on disk: {DEST_PATH}")
                    file_paths.append(DEST_PATH)
                    continue
                
                else:
                
                    print(f"Downloading file: {FILE_NAME}")
                    file_paths.append(DEST_PATH)

                    # Download files 
                    os.system(f"wget -q {FILE_URL} -P {DATA_DIR}")
        
        # Save file paths to dictionary 
        file_dict[color] = file_paths


    return file_dict
    




@test
def test_output(*args) -> None:
    """
    Template code for testing the output of the block.
    """
    pass