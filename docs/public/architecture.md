This document describes the architectural features of the qubership hive-metastore service. The following topics are covered in the document:

* [Overview](#overview)
  * [Hive-metastore](#hive-metastore)
* [Supported Deployment Scheme](#supported-deployment-scheme)
  * [HA Deployment Scheme](#ha-deployment-scheme)
  * [Non-HA Deployment Scheme](#non-ha-deployment-scheme)


# Overview

## Hive-metastore

The Hive-metastore is simply a relational database. 
It stores metadata related to tables/schemas you create to easily query big data stored. 
When you create a new Hive table, the information related to the schema (column names, data types) is stored in the Hive metastore relational database. 
Other information like input/output formats, partitions, and so on, are all stored in the metastore.

# Supported Deployment Scheme

## HA Deployment Scheme

Hive-metastore supports operation in the high availability mode.
In this mode, 2 hive-metastore hearths are created, which provide backup operation for the hive-metastore service. In this mode, each pod of the service operates in parallel mode, processing requests from Trino.

Scheme of work:
![alt text](/docs/internal/images/hive-metastore-ha-scheme.png "Hive-metastore HA scheme")

**Situations**: There are situations when one of the hive-metastore pods becomes unavailable. In such a case, the service works as shown in the following image.

Scheme of work:
![alt text](/docs/internal/images/hive-metastore-ha-scheme-1-pod-off.png "Hive-metastore HA scheme( 1 pod disable)")

## Non-HA Deployment Scheme

Hive-metastore in the non-HA mode has only one replica of each component. 

Scheme of work:
![alt text](/docs/internal/images/hive-metastore-non-ha-scheme.png "Hive-metastore non-HA scheme")
