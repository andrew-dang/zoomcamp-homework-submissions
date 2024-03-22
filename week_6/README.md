## Q1 
Below is the output of the `rpk version` command. 

```
v22.3.5 (rev 28b2443)
```

## Q2
Below is the output after executing the `rpk topic create test-topic` command. 

```
TOPIC       STATUS
test-topic  OK
```

## Q3
Output of last command (`bootstrap_connected()` method) was `True`.

## Q4
It took 0.67 seconds to send data to the test topic.  
Based on the output, it took more time to send the messages than flushing. 

## Q5
It took 79.08 seconds to send all the green trip records. 

## Q6
After parsing the record, the output is as follows:
`Row(lpep_pickup_datetime='2019-10-01 00:26:02', lpep_dropoff_datetime='2019-10-01 00:39:58', PULocationID=112, DOLocationID=196, passenger_count=1.0, trip_distance=5.88, tip_amount=0.0)`

## Q7
The busiest destination is East Harlem North. 