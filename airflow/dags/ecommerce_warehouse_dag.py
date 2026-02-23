"""
E-Commerce Data Warehouse DAG

Orchestrates the complete data pipeline:
1. Spark ingestion (Bronze layer) (TODO: Setup a spark cluster to use the SparkSubmitOperator to ingest data on a schedule)
2. dbt staging models
3. dbt snapshot (SCD Type 2)
4. dbt dimension models
5. dbt fact models
6. dbt aggregate models
7. dbt tests
8. dbt docs

Schedule: Daily at 6AM UTC
"""

from airflow.sdk import DAG
from airflow.sdk import TaskGroup
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.python import PythonOperator
from datetime import datetime, timedelta
import pendulum
import os

YOUR_EMAIL = os.environ["YOUR_EMAIL"]

# Default arguments for all tasks
default_args = {
    "owner": "data_engineering",
    "depends_on_past": False,
    "email_on_failure": False,
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
    start_date=pendulum.datetime(2026, 2, 21, 21, 0, tz='America/Indianapolis'),
    catchup=False,
    tags=["ecommerce", "warehouse", "dbt", "spark"],
    doc_md=__doc__
) as dag:
    
    dbt_project_dir = "/opt/airflow/dbt"
    
    # Task 2: dbt staging models
    dbt_staging = BashOperator(
        task_id="staging",
        bash_command=f"""
            cd {dbt_project_dir} && \
            dbt run --select staging 
        """
    )
    
    # Task 3: dbt Snapshot (SCD Type 2)
    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command=f"""
            cd {dbt_project_dir} && \
            dbt snapshot
        """
    )
    
    # Task 4, 5, 6: Rest of dbt Models
    with TaskGroup(group_id="dbt_models") as dbt_models_group:

        # Dimension models
        dbt_dimensions = BashOperator(
            task_id="dimensions",
            bash_command=f"""
                cd {dbt_project_dir} && \
                dbt run --select dimensions
            """
        )
        
        # Fact models
        dbt_facts = BashOperator(
            task_id="facts",
            bash_command=f"""
                cd {dbt_project_dir} && \
                dbt run --select facts
            """
        )
        
        # Aggregate models
        dbt_aggregates = BashOperator(
            task_id="aggregates",
            bash_command=f"""
                cd {dbt_project_dir} && \
                dbt run --select aggregates
            """
        )

        # Defining order within task group
        dbt_dimensions >> dbt_facts >> dbt_aggregates
    
    # Task 7: dbt Tests
    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {dbt_project_dir} && dbt test"
    )
    
    # Task 8: dbt Documentation
    dbt_docs = BashOperator(
        task_id="db_generate_docs",
        bash_command=f"cd {dbt_project_dir} && dbt docs generate"
    )
    
    # Task 9: Data quality summary
    def print_summary(**kwargs):
        """
        Print summary of the pipeline run.
        """
        execution_date = kwargs["execution_date"]
        print(f"""
        ╔══════════════════════════════════════════════════════════════╗
        ║           E-Commerce Warehouse Pipeline Complete             ║
        ╠══════════════════════════════════════════════════════════════╣
        ║  Execution Date: {execution_date.strftime('%Y-%m-%d %H:%M:%S')}                      ║
        ║  Status: SUCCESS                                             ║
        ║                                                              ║
        ║  Layers Refreshed:                                           ║
        ║    ✓ Bronze (Spark Ingestion)                                ║
        ║    ✓ Silver (Staging + Dimensions)                           ║
        ║    ✓ Gold (Facts + Aggregates)                               ║
        ║                                                              ║
        ║                                                              ║
        ╚══════════════════════════════════════════════════════════════╝
        """)

    pipeline_summary = PythonOperator(
        task_id="pipeline_summary",
        python_callable=print_summary
    )

    # DAG Dependencies

    # Linear flow with parallel docs generation
    dbt_staging >> dbt_snapshot >> dbt_models_group >> dbt_test
    dbt_test >> [dbt_docs, pipeline_summary]
    