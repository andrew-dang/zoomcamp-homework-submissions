# Week 3 Homework 
The 2022 Green Taxi Data was downloaded using the `download_taxi_data.py` file in the `code` folder. 
The SQL queries used to answer the homework questions can be found in the `bigquery.sql` file. 

The parquet files containing the Green Taxi Data was uploaded to GCS, at which point an external table was created in BigQuery. 
Materialized tables were later created using this external table as a source as per instructions. 

### Question 1
**What is count of records for the 2022 Green Taxi Data?**
There are 840,402 records for the 2022 Green Taxi Data. 

### Question 2
**Write a query to count the distinct number of PULocationIDs for the entire dataset on both the tables.**
**What is the estimated amount of data that will be read when this query is executed on the External Table and the Table?**
0 MB for the External Table and 6.41MB for the Materialized Table. 

### Question 3
**How many records have a fare_amount of 0?**
There are 1,622 record that have a fare_amount of 0. 

### Question 4
**What is the best strategy to make an optimized table in BigQuery if your query will always order the results by PUlocationID and filter based on lpep_pickup_datetime? (Create a new table with this strategy)**
If you are always filtering on `lpep_pickup_datetime` and ordering the results by `PULocationID`, then partitioning on `lpep_pickup_datetime` and clustering on `PULocationID` would be optimal. 

### Question 5
**Write a query to retrieve the distinct PULocationID between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive)**
Use the materialized table you created earlier in your from clause and note the estimated bytes. Now change the table in the from clause to the partitioned table you created for question 4 and note the estimated bytes processed. What are these values?

It was estimated that *12.82 MB* would be processed when running this query against the *non-partitioned* table. It was estimated that *1.12 MB* would be processed when running this query against the *partitioned* table. 

### Question 6
**Where is the data stored in the External Table you created?**
The data in an External Table resides in the external data source, which in this case is a GCP Bucket. 

### Question 7
** True or False - It is best practice in Big Query to always cluster your data**
False. You are unlikely to experience any performance benefits with clustering when the data is less than 1 GB. The additional overhead may increase query execution time. 

### Question 8
**Write a SELECT count(*) query FROM the materialized table you created. How many bytes does it estimate will be read? Why?**
BigQuery caches query results. Generally, query results ran against an external data source are not cached, unless this external data source is Cloud Storage. The first question was also a `SELECT COUNT(*)` query, and so the results were cached and no additional data needed to be processed. 