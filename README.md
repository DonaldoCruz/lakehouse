**Production Lakehouse Project**

This is the start of building a production grade lakehouse, to learn, and show modern lakehouse design skills and patterns. The data used in this project was from Kaggle https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce.

# Prerequisites
* Java was required because Apache Spark requires a Java Virtual Machine (JVM)
* Using ```docker-compose.yml```, I setup the Nessie catalog used by the Iceberg table format, as well as a local Trino cluster with one coordinator and one worker.

# Ingestion - PySpark
* Installed PySpark
* Configured PySpark using a ```SparkSession``` from the ```pyspark.sql``` module to be able to write tables into AWS S3 using the Iceberg table format with a Nessie catalog (```spark/config/spark_config.py```).
* In the  ```spark/config/spark_config.py```, the ```get_spark_session``` function returns a ```SparkSession```, which is then used in the ```spark/jobs/ingest_bronze.py```.
* The ```ingest_csv_to_bronze``` function in the ```spark/jobs/ingest_bronze.py``` file is used to ingest the CSV files from the Kaggle Olist dataset into AWS S3.

# Transformations - dbt
* At the beginning there was a bit of confusion when determining which dbt to use, **dbt core** or **dbt fusion**.
* The backend of **dbt fusion** is written in Rust which makes it a lot faster than **dbt core**, whose backend is built with python.
* **dbt fusion** lacks many data connectors such as Spark and Trino, so I decided to go with **dbt core**.

# SQL Query Engine - Trino
* **dbt** needs something to use to create the models in the lakehouse, it can use **Spark**, **Trino**, and many other connectors, but I decided to go with the Trino distributed SQL query engine because it was easy to setup using docker compose. I also have had experience with it from following the tutorial from a Medium article by Vu Trinh (```https://medium.com/@vutrinh274```) where he setup a local lakehouse.
* This is also a local lakehouse, but I wanted to create it from scratch without following a guide and to try and understand the concepts better.

# Iceberg Catalog - Project Nessie
* I setup a simple instance of a nessie server using docker compose.

# Orchestration - Apache Airflow 
* The main reason why I went with Apache Airflow is because I wanted to get more experience with it, from setting it up using docker compose, to creating DAGs (Directed Acyclic Graphs) with many tasks.
* 
![Most recent Airflow Runs](./images/airflow.img)
