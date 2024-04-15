# NBA Watchability Index
Welcome to my DataTalksClub 2024 Data Engineering Zoomcamp project submission.  

The goal of this project was to develop an index which uses a number of computed metrics as inputs to quantify how competitive an NBA game might be, and thus how watchable it might be.  

Currently, this watchability index factors in things like the strength of each team, the number of star players each roster is fielding, the teams head-to-head record, and the average point differential in their previous games. All this information is fed into the index in order to come up with a single number to measure how watchable a game might be. 

You find a Looker Studio dashboard [here](https://lookerstudio.google.com/s/vtKFqGkKAt8).

## About the Data
NBA.com has made the data available through their API, and Swar Patel has made a [Python library](https://github.com/swar/nba_api) to enable easy access to the API for Python developers. All the data used for this project was collected using this API. 

## Recreating the Project
### Deploying Locally
There are some limitations to this project when deployed on the cloud. The NBA.com blocks API calls made from the major cloud vendors, which means a proxy may be required when running the pipelines on the cloud. To account for those without a proxy, I have created an option to run this project locally using Docker Compose. 

#### Local Deployment Instructions 
1. After cloning the repository, in your terminal, navigate to the `local_deploy` folder, and build the required Docker images by executing the `docker compose build` command. 
2. Start containers with `docker compose up`.
3. The pipelines and code should already been in the Mage project, and the data would have been loaded into DuckDB. If it has not, you can run the `seed_duckdb` pipeline in Mage. 
4. Open up Metabase in your browser at the address `localhost:3000`. If you are required to provide a login, use the following credentials. If you need to add the DuckDB database, the Database file is located at `/container/directory/database.db`.
    - Email: public@user.com
    - Password: publicuser1
5. Navigate to dashboard. 



### Cloud Deployment
This project can also be deployed in GCP. The Terraform files have been made available. Below are some additional steps to setup the project. 

#### Cloud Deployment Instructions
1. Create a Service Account for Terraform. It will need the following permissions:
    - 
    - 
2. Create a secret in Secret Manager. The secret name should be `service_account_credentials`. The value of this secret should be the private key of the Terraform Service Account. 
3. Create the Docker image to run Mage in the cloud, and push to the Artifact Registry. In a terminal, open the `cloud_deploy` folder and run the following commands by replacing the values between the <> with the values relevant to your project. 
    - `docker build -f MageDockerfile -t mage_dlt_nba:latest .`
    - `docker tag mage_dlt_nba:latest <REGION>-docker.pkg.dev/<PROJECT_ID>/<ARTIFACT_REGISTRY_REPO>/mageai:latest`
    - `docker push <REGION>-docker.pkg.dev/<PROJECT_ID>/<ARTIFACT_REGISTRY_REPO>/mageai:latest`
4. Run `terraform apply`. 
5. Run the `seed_bigquery` and `daily_load_bigquery` pipelines. 
6. Connect to Looker Studio and develop similar dashboard as the link above. 
