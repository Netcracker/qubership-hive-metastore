This guide provides information about the main security parameters and its configuration in the Hive-Metastore service.

## Exposed Ports

List of ports used by Hive-Metastore are as follows: 

| Port | Service                       | Description                                                                                                                                                                                                                                                                                |
|------|-------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 9028 | Hive-Metastore                         | Port for monitoring.                                                                                                                                                                                                                                         |
| 9083 | Hive-Metastore                         | Service port.                                                                                                                                                                                                                                |


## Secure Protocols

It is possible to enable TLS in Patform Hive-Metastore. This process is described in the respective [Installation](/docs/public/installation.md#enable-httpstls) guide.

## Changing Credentials

Qubership Hive-Metastore does not contain a user management mechanism and there is no ability to change the credentials in runtime.

Credentials for the underlying services are managed in the underlying services. You can configure them in Qubership Hive-Metastore parameters. For more details refer to the [Hive Metastore Installation Procedure](/docs/public/installation.md#deployment-using-dppubhelm_deployer).

There is no mechanism in Qubership Hive-Metastore to manage the credentials for Qubership Hive-Metastore. If the external system is used to manage Qubership Hive-Metastore users, the credentials can be managed there. 

## Session Management

Qubership Hive-Metastore does not support session management. For these purposes, it is recommended to integrate Qubership Hive-Metastore with external user management systems.
