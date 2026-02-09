from pyspark.sql import SparkSession
import os

S3_BUCKET = os.environ['BUCKET_NAME']

def get_spark_session() -> SparkSession:
    """
    Creates a spark session with various configs to be able to write
    iceberg tables with the nessie catalog.
    """
    spark = (
        SparkSession.builder
            .master('local')
            .appName('EcommerceWarehouse')
            # Adding Iceberg to spark.
            # Adding nessie catalog extension to spark.
            .config(
                'spark.jars.packages',
                'org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.10.1,'
                'org.projectnessie.nessie-integrations:nessie-spark-extensions-3.5_2.12:0.106.0,'
                'software.amazon.awssdk:bundle:2.41.23,'
                'software.amazon.awssdk:apache-client:2.41.23,'
                'software.amazon.awssdk:url-connection-client:2.41.23,'
            )
            # Configuring Iceberg nessie catalog
            .config( 'spark.sql.catalog.nessie', 'org.apache.iceberg.spark.SparkCatalog' )
            .config( 'spark.sql.catalog.nessie.type', 'nessie' )
            # Nessie server is usually on port 19120
            .config( 'spark.sql.catalog.nessie.uri', 'http://localhost:19120/api/v1' )
            .config( 'spark.sql.catalog.nessie.ref', 'main' )
            .config( 'spark.sql.catalog.nessie.authentication.type', 'NONE' )
            .config( 'spark.sql.catalog.nessie.warehouse', f's3://{S3_BUCKET}' )
            .config( 'spark.sql.catalog.nessie.io-impl', 'org.apache.iceberg.aws.s3.S3FileIO' )
            # Adding Iceberg and nessie specific SQL extenstions so that pyspark can understand certain SQL commands.
            .config( 
                'spark.sql.extensions', 
                'org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions,'
                'org.projectnessie.spark.extensions.NessieSparkSessionExtensions' 
            )
            .getOrCreate()
    )

    return spark
