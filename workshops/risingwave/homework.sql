-- Q0 
CREATE MATERIALIZED VIEW latest_dropoff_time AS 
    WITH t AS (
        SELECT 
            MAX(tpep_dropoff_datetime) AS latest_dropoff_time
        FROM trip_data
    )
    SELECT taxi_zone.Zone AS taxi_zone, latest_dropoff_time
    FROM t, trip_data
    JOIN taxi_zone
        ON trip_data.DOLocationID = taxi_zone.location_id
    WHERE trip_data.tpep_dropoff_datetime = latest_dropoff_time;

-- Q1
CREATE MATERIALIZED VIEW longest_average_trip_time AS
    WITH trip_time_stats AS (
        SELECT 
            PULocationID, 
            DOLocationID, 
            tpep_pickup_datetime,
            tpep_dropoff_datetime, 
            tpep_dropoff_datetime - tpep_pickup_datetime AS trip_duration
        FROM trip_data
    ),
    agg_trip_time_stats AS(
    SELECT 
        z1.Zone AS pickup_zone,
        z2.Zone AS dropoff_zone, 
        MAX(s.trip_duration) AS max_trip_duration, 
        MIN(s.trip_duration) AS min_trip_duration,
        AVG(s.trip_duration) AS avg_trip_duration
    FROM trip_time_stats AS s
    LEFT JOIN taxi_zone AS z1
        ON s.PULocationID = z1.location_id
    LEFT JOIN taxi_zone AS z2
        ON s.DOLocationID = z2.location_id
    GROUP BY pickup_zone, dropoff_zone
    ),
    l AS (
        SELECT
            MAX(avg_trip_duration) AS max_average_trip_time
        FROM agg_trip_time_stats
    )
    SELECT 
        a.pickup_zone,
        a.dropoff_zone,
        a.avg_trip_duration
    FROM agg_trip_time_stats AS a, l
    WHERE a.avg_trip_duration = l.max_average_trip_time;


-- Q2
CREATE MATERIALIZED VIEW num_trips_for_longest_average_trip_time AS
    SELECT 
        pickup_zone,
        dropoff_zone, 
        COUNT(*) AS num_trips 
    FROM (
        SELECT 
            z1.Zone AS pickup_zone, 
            z2.Zone AS dropoff_zone
        FROM trip_data AS t
        JOIN taxi_zone AS z1 
            ON t.PULocationID = z1.location_id
        JOIN taxi_zone AS z2
            ON t.DOLocationID = z2.location_id
        WHERE 
            z1.Zone = (SELECT pickup_zone FROM longest_average_trip_time LIMIT 1) and
            z2.Zone = (SELECT dropoff_zone FROM longest_average_trip_time LIMIT 1)
    )
    GROUP BY pickup_zone, dropoff_zone
    ;

-- Q3
