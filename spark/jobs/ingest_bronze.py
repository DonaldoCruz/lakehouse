from spark.config.spark_config import get_spark_session

from pyspark.sql import SparkSession
from pyspark.sql.types import StructType
from pyspark.sql import functions as sf 

def ingest_csv_to_bronze(spark: SparkSession, file_name: str, table_name: str, schema: StructType = None):
    """
    Read CSV and write to Bronze layer Iceberg table.

    Parameters
    ----------
    spark: SparkSession
        SparkSession
    file_name: str
        Name of CSV file in data/raw/
    table_name: str
        Target Iceberg table name
    schema: StrucType
        Optional explicit schema (recommended for production)
    """
    file_path = f'./data/raw/{file_name}'
    
    df = spark.read \
        .option('header', 'true') \
        .option('inferSchema', 'true' if schema is None else 'false') \
        .option('encoding', 'UTF-8') \
        .csv(path=file_path, schema=schema)
    
    # Add metadata columns
    df = df \
        .withColumns({
            '_ingested_at': sf.current_timestamp(),
            '_source_file': sf.lit(file_name)
        })
    
    df.writeTo(f'nessie.bronze.{table_name}') \
        .using('iceberg') \
        .createOrReplace()
    
    print(f'Ingested {df.count():,} rows to nessie.bronze.{table_name}')
    
    return df.count()


def main():
    spark_session = get_spark_session()
    
    # Creating bronze namespace if it does not exist
    spark_session.sql('CREATE NAMESPACE IF NOT EXISTS nessie.bronze;')
    
    # Defining ingestion mapping
    tables = [
        ('olist_customers_dataset.csv', 'customers'),
        ('olist_geolocation_dataset.csv', 'geolocation'),
        ('olist_order_items_dataset.csv', 'order_items'),
        ('olist_order_payments_dataset.csv', 'payments'),
        ('olist_order_reviews_dataset.csv', 'reviews'),
        ('olist_orders_dataset.csv', 'orders'),
        ('olist_products_dataset.csv', 'products'),
        ('olist_sellers_dataset.csv', 'sellers'),
        ('product_category_name_translation.csv', 'category_translation')
    ]
    
    results = {}
    for file_name, table_name in tables:
        try:
            count =ingest_csv_to_bronze(spark_session, file_name, table_name)
            results[table_name] = {'status': 'success', 'rows': count}
        except Exception as e:
            results[table_name] = {'status': 'failed', 'error': str(e)}
            print(f'Failed to ingest {file_name}: {e}')

    # Summary
    print('\n' + '='*50)
    print('INGESTION SUMMARY')
    print('='*50)
    
    for table, result in results.items():
        status = "✓" if result["status"] == "success" else "✗"
        info = f"{result.get('rows', 0):,} rows" if result["status"] == "success" else result.get("error", "")
        print(f"{status} {table}: {info}")

    spark_session.stop()

if __name__ == '__main__':
    main()
