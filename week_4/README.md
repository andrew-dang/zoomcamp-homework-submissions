## Week 4 - Analytics Engineering 
This week, we used dbt (data build tool) to orchestrate the transformation of raw data that was previously loaded into a database or data warehouse. 
For my homework submission, dlt (data load tool) was used to load NYC taxi data into a PostgreSQL database. dbt was then used to transform the data,
including removing duplicated records, and making the datasets from different service types (Green, Yellow, FHV) consistent in terms of field names and field data types so they could be unioned into one table. Once all the datasets were integrated, Metabase was used to create a dashboard to summarize the data. 
