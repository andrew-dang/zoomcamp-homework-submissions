if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):
    """
    Transforms green taxi cab data. 

    Removes rows where the passenger count is equal to 0, or the trip distance is equal to 0.
    Convert lpep_pickup_datetime to a date, saving as a new column named lpep_pickup_date
    Change column names to snake case. 

    Args:
        data: The output from the upstream parent block
        args: The output from any additional upstream blocks (if applicable)

    Returns:
        pd.DataFrame
    """
    import re
    to_snake = re.compile('((?<=[a-z0-9])[A-Z]|(?!^)[A-Z](?=[a-z]))')
    
    # Remove 0 passengers
    print(f"Preprocessing :::: Rows before removing records with 0 passengers: {data.shape[0]}")
    data = data[data['passenger_count'] > 0]
    print(f"Preprocessing :::: Rows after removing records with 0 passengers: {data.shape[0]}")
    
    # Remove trip distance of 0 
    print(f"Preprocessing :::: Rows before removing records with trip distance of 0: {data.shape[0]}")
    data = data[data['trip_distance'] > 0]
    print(f"Preprocessing :::: Rows after removing records with trip distance of 0: {data.shape[0]}")

    # Create new date column
    data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date

    # Print unique values of "VendorID"
    unique_vendor_id = data['VendorID'].unique()
    
    for i, uid in enumerate(unique_vendor_id, start=1):
        print(f"Unique VendorID number {i}: {uid}")

    # Convert column names to snake case
    snake_cols = []
    conv_count = 0 
    for col in data.columns:
        new_col = to_snake.sub(r'_\1', col).lower()
        snake_cols.append(new_col)

        if new_col != col:
            conv_count += 1 

    
    data.columns = snake_cols
    print(f"{conv_count} columns were converted to snake case")

    return data


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'

@test 
def test_vendor_id(output, *args) -> None:
    assert output['vendor_id'].isin([1,2]).sum() == output.shape[0] , "'vendor_id' has invalid values"

@test 
def test_passenger_count(output, *args) -> None:
    assert output[output['passenger_count'] <= 0].shape[0] == 0, "There are records where the passenger count is not greater than 0"

@test 
def test_trip_distance(output, *args) -> None:
    assert output[output['trip_distance'] <= 0].shape[0] == 0, "There are records where the trip_distance is not greater than 0"