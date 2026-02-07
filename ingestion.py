from pyspark.sql import SparkSession

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
                'org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:2.13,'
                'org.projectnessie.nessie-integrations:nessie-spark-extensions-3.5_2.12:2.13'
            )
            # Configuring Iceberg nessie catalog
            .config( 'spark.sql.catalog.nessie', 'org.apache.iceberg.spark.SparkCatalog' )
            .config( 'spark.sql.catalog.nessie.type', 'nessie' )
            # Nessie server is usually on port 19120
            .config( 'spark.sql.catalog.nessie.uri', 'http://localhost:19129/api/v1' )
            .config( 'spark.sql.catalog.nessie.ref', 'main' )
    )
