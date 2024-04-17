# Deploying Locally
1. After cloning the repository, in your terminal, navigate to the `local_deploy` folder, and build the required Docker images by executing the `docker compose build` command. 
2. Start containers with `docker compose up`.
3. The pipelines and code should already be in the Mage project, and the data would have been loaded into DuckDB. If the database is empty, you can run the `seed_duckdb` pipeline in Mage. 
4. Open up Metabase in your browser at the address `localhost:3000`. If you are required to provide a login, use the following credentials. If you need to add the DuckDB database, the Database file is located at `/container/directory/database.db`.
    - Email: public@user.com
    - Password: publicuser1
5. The dashboard should be available at the homepage. 