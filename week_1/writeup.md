# Summary 
Below, I have included my answers for the homework questions, as well as some relevent SQL code used to get to the answer. 
A folder with code used to complete this week's homework has also been included. 

## Question 1: Which `docker run` tag has the following text: *Automatically remove the container when it exits*
`--rm`

## Question 2: What version of the package `wheel`` is installed in the python:3.9 Docker image?
Version `0.42.0` of the package `wheel` is installed. 

## Question 3: How many taxi trips were made on September 18, 2019?
A trip was considered to be made on this date if both the pickup and dropoff date were on September 18, 2019. 
Below is the query used to get the answer. 

```
SELECT 
    COUNT(*) AS num_trips
FROM green_taxi_data 
WHERE lpep_pickup_datetime::date = '2019-09-18' AND lpep_pickup_datetime::date = '2019-09-18';
```

**There were 15,612 trips made on September 18, 2019.**

## Question 4: Largest trip for each day
For this question we were explicitly asked to use the pickup time for the calculations. 
Therefore, trips that started on and finished on different days are still considered. 
Below is the query used to get the answer. 

```
SELECT 
    lpep_pickup_datetime::date,
	MAX(trip_distance) AS longest_trip
FROM green_taxi_data 
GROUP BY lpep_pickup_datetime::date
ORDER BY longest_trip DESC;
```

**The longest trip was made on September 26, 2019 (2019-09-26).**

## Question 5: Which 3 boroughs by pickup location had a sum of `total_amount` greater than 50,000 on 2019-09-18?
Below is the query used to get the answer. 

```
SELECT 
	a.borough, 
	a.daily_total_amount
FROM (
	SELECT 
		z."Borough" AS borough, 
		SUM(g.total_amount) AS daily_total_amount 
	FROM green_taxi_data AS g
	LEFT JOIN zones AS z
		ON g."PULocationID" = z."LocationID"
	WHERE g."lpep_pickup_datetime"::date = '2019-09-18'
	GROUP BY z."Borough"
) AS a
WHERE daily_total_amount > 50000
ORDER BY daily_total_amount DESC;
```

**The 3 boroughs are Brooklyn, Manhattan, and Queens.**

## Question 6: For the passengers picked up in September 2019 in the zone name Astoria which was the drop off zone that had the largest tip?
Below is the query used to get the answer. 

```
WITH astoria_pickup AS (
	SELECT 
		g."PULocationID" AS pickup_location,
		z1."Zone" AS pickup_zone,
		g."DOLocationID" AS dropoff_location,
		z2."Zone" AS dropoff_zone,
		g.tip_amount
	FROM green_taxi_data AS g
	LEFT JOIN zones AS z1
		ON g."PULocationID" = z1."LocationID"
	LEFT JOIN zones AS z2
		ON g."DOLocationID" = z2."LocationID"
	WHERE z1."Zone" = 'Astoria' 
		AND EXTRACT(month FROM g."lpep_pickup_datetime") = 9 
		AND EXTRACT(year FROM g."lpep_pickup_datetime") = 2019 
)
SELECT 
	dropoff_zone,
	MAX(tip_amount) AS largest_tip
FROM astoria_pickup
GROUP BY dropoff_zone
ORDER BY largest_tip DESC;
```

**JFK Airport was the dropoff zone that had the largest tip.**

## Question 7: Paste the output of the `terraform apply` command. 
The output of the command has been provided in the submission form. 

The Terraform code used for this question can be found in the `code` folder. The GCP credentials key for the service account created
for Terraform have intentionally been left out. Please note that the value for the variables in the `variables.tf` folder are 
placeholders and not reflective of the actual values used to execute the commands. 