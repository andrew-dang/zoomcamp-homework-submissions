# NBA Watchability Index
Welcome to my DataTalksClub 2024 Data Engineering Zoomcamp project submission.
The goal of this project was to develop an index which uses a number of computed metrics as inputs to quantify how competitive an NBA game might be, and thus how watchable it might be.    
Currently, this watchability index factors in things like the strength of each team, the number of star players each roster is fielding, the teams head-to-head record, and the average point differential in their previous games. All this information is fed into the index in order to come up with a single number to measure how watchable a game might be. 

## About the Data
NBA.com has made the data available through their API, and Swar Patel has made a [Python library](https://github.com/swar/nba_api) to enable easy access to the API for Python developers. 