-- Creating external table referring to gcs path
CREATE OR REPLACE EXTERNAL TABLE `zoomcamp-2024-412415.demo_dataset.external_green_tripdata`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://zoomcamp-2024-412415-demo-bucket/green/green_tripdata_2022-*.parquet']
);

-- Create a materialized table from external table
CREATE OR REPLACE TABLE zoomcamp-2024-412415.demo_dataset.green_tripdata_non_partitoned AS
SELECT * FROM zoomcamp-2024-412415.demo_dataset.external_green_tripdata;

/* Q1: Count of records for 2022 Green Taxi Data? */
SELECT
    COUNT(*)
FROM 
    zoomcamp-2024-412415.demo_dataset.external_green_tripdata
;

-- Preview states there are 840,402 rows, consisting of 114.11 MB of data

/* Q2: Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.
What is the estimated amount of data that will be read when this query is executed on the External Table and the Table? */
SELECT 
    COUNT(DISTINCT PULocationID) AS unique_pu_location
FROM 
    zoomcamp-2024-412415.demo_dataset.external_green_tripdata;

-- Estimated amount of data: 0 MB


SELECT 
    COUNT(DISTINCT PULocationID) AS unique_pu_location
FROM 
    zoomcamp-2024-412415.demo_dataset.green_tripdata_non_partitoned;

-- Estimated amount of data: 6.41 MB

-- 0 MB for the External Table and 6.41MB for the Materialized Table

/* Q3: How many records have a fare_amount of 0? */
SELECT 
    COUNT(*) 
FROM 
    zoomcamp-2024-412415.demo_dataset.green_tripdata_non_partitoned
WHERE fare_amount = 0;

-- There are 1,622 trips with a fare amount of 0

/* Q4: What is the best strategy to make an optimized table in Big Query if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? */
-- Partition by lpep_pickup_datetime Cluster on PUlocationID

-- Create partitioned table 
CREATE OR REPLACE TABLE zoomcamp-2024-412415.demo_dataset.green_tripdata_partitoned_clustered
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY VendorID AS
SELECT * FROM zoomcamp-2024-412415.demo_dataset.external_green_tripdata;

/* Q5: Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive) */
-- Non-partitioned and non-clustered table vs. partitioned and clustered table. 
SELECT 
    COUNT(DISTINCT PULocationID) as trips
FROM 
    zoomcamp-2024-412415.demo_dataset.green_tripdata_non_partitoned
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30'
;
-- Estimated bytes processed: 12.82 MB
-- 12.82 MB for non-partitioned table and 1.12 MB for the partitioned table


SELECT 
    COUNT(DISTINCT PULocationID) as trips
FROM 
    zoomcamp-2024-412415.demo_dataset.green_tripdata_partitoned_clustered
WHERE DATE(lpep_pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30'
;
-- Estimated bytes processed: 1.12 MB

/* Q6: Where is the data stored in the External Table you created? */
-- In this case, the data stored in the external table is stored in GCS

/* Q7: It is best practice in Big Query to always cluster your data: */
-- False - you are unlikely to realize any benefits from clustering when your data is <1 GB

/* Q8: Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read? Why? */
