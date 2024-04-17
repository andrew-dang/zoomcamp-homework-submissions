# Problem Statement -  NBA Watchability Index
During an NBA season, 1,230 games are played. Even the most die hard fans would have a difficult time watching every single game. And not every game was made equal. Some games are more exciting to watch, and others can be downright boring.   

The goal of this project was to develop an index which uses a number of computed metrics as inputs to quantify how competitive a regular season NBA game might be, and thus how watchable it might be.  

Currently, this watchability index factors in things like the strength of each team, the number of star players each roster is fielding, the teams head-to-head record, and the average point differential in their previous games. All this information is fed into the index in order to come up with a single number to measure how watchable a game might be. 

You find a Looker Studio dashboard [here](https://lookerstudio.google.com/s/vtKFqGkKAt8).

I plan to continue building upon this project and create streaming pipelines to track how watchable a game is as the game is happening live. 

*Note: The idea behind this project was spawned partway through the 2024 DataTalksClub Data Engineering Zoomcamp. At the time of submission, the regular season has wrapped up and I am unsure how the API responses change once he Playoffs begin*

## About the Data
NBA.com has made the data available through their API, and Swar Patel has made a [Python library](https://github.com/swar/nba_api) to enable easy access to the API for Python developers. All the data used for this project was collected using this API. 

## Deploying the Project
This project can be deployed locally or on the cloud. In the local deployment, this project leverages dlt for loading data from the API into DuckDB which is our data warehouse in this scenario, dbt for data transformations, and Apache Metabase for data visualization. The pipelines are orchestrated using Mage, and the various infrastructure components are spun up using Docker Compose. 

Deploying on the cloud is slightly different. BigQuery is used in place of DuckDB as the data warehouse, and Looker Studio is used for data visualization. The other major difference is that the NBA API blocks API calls made from machines in the cloud. The work around is to use proxies. Unfortunately I have not had any luck with free proxies. To recreate this project, I would advise emulating the solution developed for local deployment. 

There are separate README files within the `local_deploy` and `cloud_deploy` folders with additional instructions for deployment. 