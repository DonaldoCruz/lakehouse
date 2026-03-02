# Lakehouse Project

This is a personal lakehouse project, to learn, and show modern lakehouse design skills and patterns. The data used in this project was from Kaggle https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce.

## Architecture
```
                           ┌──────────────────────────────────────┐
                           │           Apache Airflow             │
                           └──────────────────────────────────────┘
                                            │
    ┌───────────────────────────────────────┼───────────────────────────────────────┐
    │                                       │                                       │
    ▼                                       ▼                                       ▼
┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐    ┌────────┐
│ CSV    │───▶│ Spark  │───▶│ Bronze │───▶│  dbt   │───▶│ Silver │───▶│  Gold  │
│ Files  │    │Ingest  │    │        │    │        │    │        │    │        │
└────────┘    └────────┘    └────────┘    └────────┘    └────────┘    └────────┘
                                 │                           │            │
                                 └───────────────────────────┴────────────┘
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │     AWS S3 + Iceberg        │
                                    │     Nessie Catalog          │
                                    │     Trino Queries           │
                                    └─────────────────────────────┘
```

![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?style=for-the-badge&logo=apacheairflow&logoColor=white)
![Apache Iceberg](https://img.shields.io/badge/Apache%20Iceberg-3A76F0?style=for-the-badge&logo=apacheiceberg&logoColor=white)
![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
![AWS S3](https://img.shields.io/badge/AWS%20S3-569A31?style=for-the-badge&logo=amazons3&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Nessie](https://img.shields.io/badge/Nessie-4A9B6E?style=for-the-badge&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Trino](https://img.shields.io/badge/Trino-DD00A1?style=for-the-badge&logo=trino&logoColor=white)

## Tech Stack
| Component | Technology |
|-----------|------------|
| Storage | AWS S3 |
| Table Format | Apache Iceberg |
| Catalog | Nessie |
| Query Engine | Trino |
| Transformations | dbt |
| Orchestration | Airflow |
| Ingestion | PySpark |

## Prerequisites
* Java was required because Apache Spark requires a Java Virtual Machine (JVM)
* Using ```docker-compose.yml```, I setup the Nessie catalog used by the Iceberg table format, as well as a local Trino cluster with one coordinator and one worker.

## Ingestion - PySpark ![Apache Spark](https://img.shields.io/badge/Apache%20Spark-E25A1C?style=for-the-badge&logo=apachespark&logoColor=white)
* Installed PySpark
* Configured PySpark using a ```SparkSession``` from the ```pyspark.sql``` module to be able to write tables into AWS S3 using the Iceberg table format with a Nessie catalog (```spark/config/spark_config.py```).
* In the  ```spark/config/spark_config.py```, the ```get_spark_session``` function returns a ```SparkSession```, which is then used in the ```spark/jobs/ingest_bronze.py```.
* The ```ingest_csv_to_bronze``` function in the ```spark/jobs/ingest_bronze.py``` file is used to ingest the CSV files from the Kaggle Olist dataset into AWS S3.

## Transformations - dbt ![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
* At the beginning there was a bit of confusion when determining which dbt to use, **dbt core** or **dbt fusion**.
* The backend of **dbt fusion** is written in Rust which makes it a lot faster than **dbt core**, whose backend is built with python.
* **dbt fusion** lacks many data connectors such as Spark and Trino, so I decided to go with **dbt core**.

## SQL Query Engine - Trino ![Trino](https://img.shields.io/badge/Trino-DD00A1?style=for-the-badge&logo=trino&logoColor=white)
* **dbt** needs something to use to create the models in the lakehouse, it can use **Spark**, **Trino**, and many other connectors, but I decided to go with the Trino distributed SQL query engine because it was easy to setup using docker compose. I also have had experience with it from following the tutorial from a Medium article by Vu Trinh (```https://medium.com/@vutrinh274```) where he setup a local lakehouse.
* This is also a local lakehouse, but I wanted to create it from scratch without following a guide and to try and understand the concepts better.

## Iceberg Catalog - Project Nessie ![Nessie](https://img.shields.io/badge/Nessie-4A9B6E?style=for-the-badge&logoColor=white)
* I setup a simple instance of a nessie server using docker compose.

## Orchestration - Apache Airflow ![Apache Airflow](https://img.shields.io/badge/Apache%20Airflow-017CEE?style=for-the-badge&logo=apacheairflow&logoColor=white)
* The main reason why I went with Apache Airflow is because I wanted to get more experience with it, from setting it up using docker compose, to creating DAGs (Directed Acyclic Graphs) with many tasks.
* 
![Most recent Airflow Runs](./images/airflow.img)
