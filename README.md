## Table of Contents

* [Overview](#overview)
* [Architecture](docs/public/architecture.md)
* [Installation Guide](docs/public/installation.md)

## Overview

Qubership Hive-Metastore is a comprehensive solution for deploying [Hive-Metastore](https://hive.apache.org/) in Kubernetes.

In Kubernetes Qubership Hive-Metastore uses Minio S3 storage to use data and PostgreSQL to store metadata.

The table below shows services in K8s that can potentially replaces services in Hadoop cluster.

**Note** [Apache Hive](https://github.com/apache/hive) contains two large parts, hive-metastore and hiveServer2. This project contains only hive-metastore and does not hiveServer2 libraries. Hive-metastore libraries can be found at https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore-server .

## Repository structure

* `chart` - helm charts for Qubership Hive-Metastore.
* `docker` - files for building Qubership Hive-Metastore docker image
* `docs` - Qubership Hive-Metastore documentation.

### How to debug and troubleshoot

After deploying to K8s, `log4j2-properties` configmap is created, where it is possible to change hive logging level.

#### Connecting to hive-metastore

It is possible to connect to deployed Qubership Hive-Metastore using [Trino](https://github.com/trinodb/trino) or [Spark](https://github.com/apache/spark). Example PySpark configuration can be found below

```python
from pyspark.sql import SparkSession
...
spark = SparkSession \
    .builder.master("local") \
    .appName("MyApp.com") \
    .config("spark.sql.warehouse.dir", "s3a://hive/warehouse") \
    .config("spark.sql.hive.metastore.version", "3.1.3") \
    .config("spark.sql.hive.metastore.jars", "maven") \
    .config("spark.hadoop.hive.metastore.uris", "thrift://hive_address") \
    .config("spark.hadoop.hive.metastore.schema.verification", "false") \
    .config("spark.hadoop.hive.metastore.schema.verification.record.version", "false") \
    .config("spark.hadoop.hive.metastore.use.SSL", "false") \
    .config('spark.hadoop.fs.s3.buckets.create.enabled', 'true') \
    .config('spark.hadoop.fs.s3a.endpoint', 'https://s3.endpoint.address.com') \
    .config('spark.hadoop.fs.s3a.access.key', 's3accesskey') \
    .config('spark.hadoop.fs.s3a.secret.key', 's3secretkey') \
    .config('spark.hadoop.fs.s3a.connection.ssl.enabled', 'false') \
    .config('spark.hadoop.fs.s3a.impl', 'org.apache.hadoop.fs.s3a.S3AFileSystem') \
    .config('spark.hadoop.fs.s3a.path.style.access', 'true') \
    .config('spark.driver.extraJavaOptions', '-Dcom.amazonaws.sdk.disableCertChecking') \
    .config('spark.executor.extraJavaOptions', '-Dcom.amazonaws.sdk.disableCertChecking') \
    .enableHiveSupport() \
    .getOrCreate()
```