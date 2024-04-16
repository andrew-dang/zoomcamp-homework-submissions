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
1. Create a Service Account for Terraform. Create and download the access key for this Service Account. It will need the following permissions:
    - Artifact Registry Administrator
    - BigQuery Admin
    - Cloud Filestore Editor 
    - Cloud Filestore Service Agent
    - Cloud SQL Admin 
    - Project IAM Admin 
    - Secret Manager Admin
    - Secret Manager Secret Accessor
    - Serverless VPC Access Admin 
    - Service Account User
    - Service Usage Admin
    - Compute Network Admin
2. Create a secret in Secret Manager. The secret name should be `service_account_credentials`. The value of this secret should be the JSON file containing the credentials of the Terraform Service Account. You should upload the entire JSON file.
3. In your terminal, navigate to the `terraform` folder. Export your credentials with the command `export GOOGLE_CREDENTIALS='/path/to/terraform_service_account.json`. 
4. Run `terraform init`. 
    - Note: Before moving on to the next step, be sure to make the following changes in the `variables.tf` file to correspond with your project and geographic location:
        - project_id
        - region 
        - zone
5. Run `terraform apply`. There will likely be errors. If it is related to an API needing to be enabled, navigate to the API within the Cloud Console and enable those APIs. If it is related to a missing image in the Artifact Registry, or a non-existant secret, the steps below outline how to fix these errors. 
    - **Missing Docker Image**
        - Create the Docker image to run Mage in the cloud, and push to the Artifact Registry. In a terminal, open the `cloud_deploy` folder and run the following commands by replacing the values between the <> with the values relevant to your project. 
            - `docker build -f MageDockerfile -t mage_dlt_nba:latest .` 
            - `docker tag mage_dlt_nba:latest <REGION>-docker.pkg.dev/<PROJECT_ID>/<ARTIFACT_REGISTRY_REPO>/mageai:latest`
            - `docker push <REGION>-docker.pkg.dev/<PROJECT_ID>/<ARTIFACT_REGISTRY_REPO>/mageai:latest`
    - **Missing Secret** 
        - Within the Cloud Console, navigate to the Secret Manager API. 
        - Click on "CREATE SECRET". 
        - The name of the secret should be`service_account_credentials`. Upload the JSON file for your Terraform Service Account. 
        - Click "CREATE SECRET" at the bottom of the UI. 
6. After the above changes, run `terraform apply` again. 
7. Navigate to Cloud Run. Allow all traffic for the Mage app. 
8. Open up the terminal. Get the ETL code for the project by running the following commands. 
    - `git clone <repo>`
    - `mv <source> <dest> -r`
9. Edit `profiles.yml` file within the dbt project. 
10. Create two pipelines: `seed_bigquery` and `daily_load_bigquery` 
    - **seed_bigquery**
        - In the edit pipeline UI, move the `load_bq` block and the `dbt_build` block into the editor. Connect these two in the tree. Run this entire pipeline once. 
    - **daily_load_bigquery**
        - In the edit pipeline UI, move the `daily_load_bq` block and the `dbt_build` block into the editor. Connect these two in the tree.
        - Create a trigger for this pipeline. Use a custom frequency. Input the following CRON string `5 16 * * *`. Enable this trigger. The daily load will run every day at 12:05pm EST. 
11. Connect to Looker Studio and develop similar dashboard as the link above. 