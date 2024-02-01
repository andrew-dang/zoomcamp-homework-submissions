## Question 1: Data Loading - What is the shape of the data? 
After all three months have been read in, the data has 266,855 rows and 20 columns. 

## Question 2: Data Transformation - Upon filtering the dataset where the passenger count is greater than 0 and the trip distance is greater than zero, how many rows are left?
After filtering the dataset, there are 139,370 rows remaining. 

## Question 3: Data Transformation - Which of the following creates a new column lpep_pickup_date by converting lpep_pickup_datetime to a date?
The correct command to create a new column and converting `lpep_pickup_datetime` to a date is listed below: 
- `data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date`

## Question 4: Data Transformation - What are the existing values of `VendorID` in the dataset? 
The unique `VendorID` values in the dataset uploaded are 1 or 2. 

## Question 5: Data Transformation - How many columns need to be renamed to snake case?
Four columns needed to be renamed to snake case. The following columns were the ones that were converted. 
- `VendorID` -> `vendor_id`
- `RatecodeID` -> `ratecode_id`
- `PULocationID` -> `pu_location_id` 
- `DOLocationID` -> `do_location_id`

## Question 6: Data Exporting - Once exported, how many partitions (folders) are present in Google Cloud?
After exporting to Google Cloud Storage, there were 95 partitions present. 