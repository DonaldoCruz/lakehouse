"""
E-Commerce Data Warehouse DAG

Orchestrates the complete data pipeline:
1. Spark ingestion (Bronze layer) (TODO: Setup a spark cluster to use the SparkSubmitOperator to ingest data on a schedule)
2. dbt snapshot (SCD Type 2)
3. dbt staging models
4. dbt dimension models
5. dbt fact models
6. dbt aggregate models
7. dbt tests

Schedule: Daily at 6AM UTC
"""

from airflow.sdk import DAG
from airflow.providers.standard.operators.bash import BashOperator
from datetime import datetime, timedelta
import pendulum
import os

YOUR_EMAIL = os.environ["YOUR_EMAIL"]

# Default arguments for all tasks
default_args = {
    "owner": "data_engineering",
    "depends_on_past": False,
    "email_on_failure": True,
    "email_on_retry": False,
    "email": [YOUR_EMAIL],
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "execution_timeout": timedelta(hours=2)
}

with DAG(
    dag_id="ecommerce_data_warehouse",
    default_args=default_args,
    description="E-Commerce Data Lakehouse ETL Pipeline",
    schedule="0 */1 * * *",
    start_date=pendulum(2026, 2, 21, 21, 0, tz='America/Indianapolis'),
    catchup=False,
    tags=["ecommerce", "warehouse", "dbt", "spark"],
    doc_md=__doc__
) as dag:
    
    # Task 2: dbt Snapshot (SCD Type 2)
    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command="cd  dbt_warehouse && dbt snapshot --profiles-dir ." # TODO Test this
    )
    
    