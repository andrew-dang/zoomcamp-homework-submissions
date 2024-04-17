# Cloud Deployment Instructions
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
2. Copy and paste the key into `terraform/secrets/service_account_credentials` folder. 
3. In your terminal, navigate to the `terraform` folder. Export your credentials with the command `export GOOGLE_CREDENTIALS='/path/to/terraform_service_account.json`. 
4. Run `terraform init`. 
    - Note: Before moving on to the next step, be sure to make the following changes in the `variables.tf` file to correspond with your project and geographic location:
        - project_id
        - region 
        - zone
        - docker_image
5. Run `terraform apply`. It will prompt you for a password - type one in and hit enter. There will likely be errors. If it is related to an API needing to be enabled, navigate to the API within the Cloud Console and enable those APIs. If it is related to a missing image in the Artifact Registry, or a non-existant secret, the steps below outline how to fix these errors. You may also need to grant another Service Account the `Secret Manager Secret Accessor` permissions. If prompted, please do so. 
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
6. After the above changes, run `terraform apply` again. It will once again prompt yout for a password. Type one in an hit enter. 
7. In the Cloud Console, navigate to Cloud Run. Click on the service that is listed. Go to the Networking tab, and under Ingress Control, select All. Click Save.  
8. After you have changed the network settings, clicl on the URL for the Cloud Run app to access Mage. 
9. Navigate to the terminal with the Mage UI. We are now going to clone this repo and move the relevant files to the correct destinations. 
    - `git clone https://github.com/andrew-dang/zoomcamp-homework-submissions/`
    - `mv -v zoomcamp-homework-submissions/week_7_capstone/cloud_deploy/mage_nba_watchability_index/dbt/* default_repo/dbt`
    - `mv -v zoomcamp-homework-submissions/week_7_capstone/cloud_deploy/mage_nba_watchability_index/utils/* default_repo/utils`
    - `mv zoomcamp-homework-submissions/week_7_capstone/cloud_deploy/mage_nba_watchability_index/data_loaders/daily_load.py default_repo/data_loaders`
    - `mv zoomcamp-homework-submissions/week_7_capstone/cloud_deploy/mage_nba_watchability_index/data_loaders/api_to_bigquery.py default_repo/data_loaders`
10. Edit `profiles.yml` file at `home/src/default_repo/dbt/nba_watchability_index/profiles.yml`. You want to change the following values:
    - project
    - keyfile
11. Change the value of the `MY_PROXY` variable in the file at `home/src/default_repo/utils/dlt_resources.py`.
12. Create two pipelines: `seed_bigquery` and `daily_load_bigquery` 
    - **seed_bigquery**
        - In the edit pipeline UI, move the `api_to_bigquery` block and add a generic dbt block into the editor. Run the `dbt build` command. Connect these two blocks in the tree. Run this entire pipeline once. 
    - **daily_load_bigquery**
        - In the edit pipeline UI, move the `daily_load_bq` block and add a generic dbt block into the editor. Run the `dbt build` command. Connect these two blocks in the tree.
        - Create a trigger for this pipeline. Use a custom frequency. Input the following CRON string `5 16 * * *`. Enable this trigger. The daily load will run every day at 12:05pm EST. 
13. Connect to Looker Studio and develop similar dashboard as the link above. 