The following topics are covered in this chapter:

* [Prerequisites](#prerequisites)
  * [Common](#common)
  * [Kubernetes](#kubernetes)
  * [OpenShift](#openshift)
* [Best Practices and Recommendations](#best-practices-and-recommendations)
  * [HWE](#hwe)
    * [Small](#small)
    * [Medium](#medium)
    * [Large](#large)
* [Parameters](#parameters)
  * [Hive-Metastore](#hive-metastore)
  * [Enable HTTPS/TLS](#enable-httpstls)
  * [Secure Connections from Hive Metastore](#secure-connections-from-hive-metastore)
    * [Adding CA Certificates to Hive Metastore's Default Java Truststore](#adding-ca-certificates-to-hive-metastores-default-java-truststore)
    * [Configure Connections to Use SSL/TLS](#configure-connections-to-use-ssltls)
      * [PostgreSQL](#postgresql)
      * [S3](#s3)
  * [Monitoring Configuration](#monitoring-configuration)
  * [S3 Initialization Job](#s3-initialization-job)
    * [AWS V4 Signature Configuration](#aws-v4-signature-configuration) 
    * [TLS](#tls)
* [Installation](#installation)
  * [Manual Deployment](#manual-deployment)
* [On-Prem](#on-prem)
    * [HA Scheme](#ha-scheme)
    * [Non-HA Scheme](#non-ha-scheme)
* [Upgrade](#upgrade)
* [Rollback](#rollback)

# Prerequisites

The prerequisites for the installation are as follows:

## Common

The common prerequisites are specified below.

* Helm >= 3
* PostgreSQL service is required.
* S3 storage. It must have bucket pre-created (for example, bucket `hive`, directory `warehouse`) or [S3 Initialization Job](#s3-initialization-job) must be used.

## Kubernetes

The prerequisites for Kubernetes are specified below.

* Kubernetes >= 1.13
* A namespace in Kubernetes should be created.  

## OpenShift

The prerequisites for OpenShift are specified below.

* If you are using the OpenShift cloud with restricted SCC, the Hive Metastore namespace must have specific annotations:

```bash
oc annotate --overwrite namespace <hive-metastore-namespace> openshift.io/sa.scc.uid-range="10002/10002"
oc annotate --overwrite namespace <hive-metastore-namespace> openshift.io/sa.scc.supplemental-groups="10002/10002"
```

Alternatively, it is possible to avoid setting annotations if you set the `runAsUser` parameter of security context to `~`:

```yaml
securityContext:
  capabilities:
    drop:
    - ALL
  seccompProfile:
    type: RuntimeDefault
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: ~ 
```

# Best Practices and Recommendations

The best practices and recommendations are given in the below sub-sections.

## HWE

The hardware requirements are specified below.

### Small

`Small` profile specifies the resources that are enough to start hive-metastore.

The profile resources are specified below:

|   Container    | CPU Limit | Memory Limit | Number of Containers |
|:--------------:|:---------:|:------------:|:--------------------:|
| Hive-Metastore |   700m    |      1G      |          1           |
| Hive Init Job  |   500m    |      512Mi   |          1           |
| Hive S3 Job    |    50m    |     64Mi     |          1           |

**Note**: The above resources are required for starting, not for working under load. For production, the resources should be increased.

### Medium

`Medium` profile specifies the approximate resources that are enough to run hive-metastore for dev purposes.
The profile resources are specified below:

|   Container    | CPU Limit | Memory Limit | Number of Containers |
|:--------------:|:---------:|:------------:|:--------------------:|
| Hive-Metastore |     1     |      2G      |          1           |
| Hive Init Job  |   500m    |      512Mi   |          1           |
| Hive S3 Job    |    50m    |     64Mi     |          1           |

**Note**: The above resources are enough for development purposes, not for working under production load. For production, the resources should be increased.

### Large

`Large` profile specifies the approximate resources that are enough to run hive-metastore for prod purposes.
The profile resources are specified below:

|   Container   | CPU Limit | Memory Limit | Number of Containers |
|:-------------:|:---------:|:------------:|:--------------------:|
|Hive-Metastore |     2     |      4G      |          2           |
| Hive Init Job |   500m    |    512Mi     |          1           |
| Hive S3 Job   |    50m    |     64Mi     |          1           |

# Parameters

The parameters are specified below.

## Hive-Metastore

The following table lists the configurable parameters of the Hive-Metastore chart and their default values.

**Note**: It is required to fill the user/password parameters.

| Parameter                                | Type              | Mandatory | Default value                                                                                                             | Description                                                                                                                                                                                                                                                                                                                                             |
|------------------------------------------|-------------------|-----------|---------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `image.repository`                       | string            | false     | `"ghcr.io/netcracker/qubership-hive-metastore"`                                                                           | The image repository.                                                                                                                                                                                                                                                                                                                                   |
| `image.pullPolicy`                       | string            | false     | `image.pullPolicy`                                                                                                        | The image pull policy.                                                                                                                                                                                                                                                                                                                                  |
| `image.tag`                              | string            | false     | `main`                                                                                                                    | This overrides the image tag, which is the hive-metastore version by default.                                                                                                                                                                                                                                                                           |
| `securityContext.runAsUser`              | string            | false     | `10002`                                                                                                                   | All processes' containers that run with the specified user.                                                                                                                                                                                                                                                                                             |
| `securityContext.runAsGroup`             | string            | false     | ``                                                                                                                        | All processes' containers that run with the specified user group.                                                                                                                                                                                                                                                                                       |
| `service.type`                           | string            | false     | `"ClusterIP"`                                                                                                             | The type of Kubernetes service.                                                                                                                                                                                                                                                                                                                         |
| `service.port`                           | string            | false     | `9083`                                                                                                                    | It specifies the Hive-metastore HTTP server port.                                                                                                                                                                                                                                                                                                       |
| `nodeSelector`                           | map               | false     | `{}`                                                                                                                      | This parameter allows you to specify on which nodes of the cluster the Hive-metastore substations should be deployed.                                                                                                                                                                                                                                   |
| `priorityClassName`                      | string            | false     | `~`                                                                                                                       | Priority class name for hive metastore pod.                                                                                                                                                                                                                                                                                                             |
| `tolerations`                            | array             | false     | `[]`                                                                                                                      | This parameter allows you to specify the tolerance to special conditions on cluster nodes.                                                                                                                                                                                                                                                              |
| `affinity`                               | map               | false     | `{}`                                                                                                                      | This parameter allows you to specify the preferences for placing hearths on cluster nodes.                                                                                                                                                                                                                                                              |
| `serviceAccount.create`                  | string            | false     | `true`                                                                                                                    | It specifies whether a service account should be created for Hive-metastore.                                                                                                                                                                                                                                                                            |
| `serviceAccount.name`                    | string            | false     | `""`                                                                                                                      | The Hive-metastore service account name to use. If not set and create is true, a name is generated using the fullname template.                                                                                                                                                                                                                         |
| `serviceAccount.annotations`             | map               | false     | `{}`                                                                                                                      | The annotations to be added to the service account.                                                                                                                                                                                                                                                                                                     |
| `s3.endpoint`                            | string            | true      | `""`                                                                                                                      | The MinIO S3 storage endpoint. Hive-Metastore uses S3 storage to store data.                                                                                                                                                                                                                                                                            |
| `s3.accessKey`                           | string            | true      | `""`                                                                                                                      | The MinIO access key.                                                                                                                                                                                                                                                                                                                                   |
| `s3.secretKey`                           | string            | true      | `""`                                                                                                                      | The MinIO secret key.                                                                                                                                                                                                                                                                                                                                   |
| `s3.warehouseDir`                        | string            | true      | `s3a://warehouse/hive`                                                                                                    | The directory in S3 storage, where Hive-Metastore should store its data.                                                                                                                                                                                                                                                                                |
| `hive.user`                              | string            | false     | `""`                                                                                                                      | The Hive Metastore to PG connection user that is set as owner of the Hive database. This user is created by `hiveInitJob`.                                                                                                                                                                                                                             |
| `hive.password`                          | string            | false     | `""`                                                                                                                      | The Hive Metastore to PG connection user password. The password of the user is created by `hiveInitJob`.                                                                                                                                                                                                                                                |
| `hive.db`                                | string            | false     | `metastore_db`                                                                                                            | The Hive Metastore database created in PG by `hiveInitJob`.                                                                                                                                                                                                                                                                                             |
| `postgres.adminUser`                     | string            | true      | `""`                                                                                                                      | The PG user with permission to create a role and a database. This user is used to prepare a database in PG.                                                                                                                                                                                                                                             |
| `postgres.adminPassword`                 | string            | true      | `""`                                                                                                                      | The password of the user set in `postgres.user`.                                                                                                                                                                                                                                                                                                        |
| `postgres.host`                          | string            | true      | `""`                                                                                                                      | The PG host, where the Hive Metastore DB is located.                                                                                                                                                                                                                                                                                                     |
| `postgres.port`                          | string            | true      | `""`                                                                                                                      | The PG port where the Hive Metastore DB is located.                                                                                                                                                                                                                                                                                                     |
| `postgres.driver`                        | string            | true      | `"org.postgresql.Driver"`                                                                                                 | The PG connection driver.                                                                                                                                                                                                                                                                                                                               |
| `postgres.psqlParams`                    | string            | false     | `""`                                                                                                                      | PostgreSQL connection parameters used by Hive Metastore database init job.                                                                                                                                                                                                                                                                              |
| `postgres.jdbcParams`                    | string            | false     | `""`                                                                                                                      | PostgreSQL connection parameters used by Hive Metastore.                                                                                                                                                                                                                                                                                                |
| `hiveInitJob.enabled`                    | bool              | false     | `"true"`                                                                                                                  | The parameter that enables the Pre-install/upgrade Helm job. The job creates a database in PG, initiates the Hive schema, and upgrades if necessary. The database related parameters are set in the `postgres` and `hive` sections.                                                                                                                     |
| `hiveInitJob.upgradeSchema`              | bool              | false     | `"false"`                                                                                                                 | Enables hive metastore database upgrade. Must be set to to true when upgrading to 4.* versions from 3.* versions without database cleanup.                                                                                                                                                                                                              |
| `hiveInitJob.cleanupDB`                  | bool              | false     | `"false"`                                                                                                                 | Enables the Hive metastore database cleanup. The database, the user along with it's grants will be dropped.                                                                                                                                                                                                                                             |
| `hiveInitJob.initAnnotations`            | string            | false     | `"helm.sh/hook": pre-install, pre-upgrade "helm.sh/hook-weight": "-10" helm.sh/hook-delete-policy": before-hook-creation` | The database init job annotations.                                                                                                                                                                                                                                                                                                                      |
| `hiveInitJob.priorityClassName`          | string            | false     | `~`                                                                                                                       | Priority class name for init job.                                                                                                                                                                                                                                                                                                                       |
| `s3InitJob.enabled`                      | bool              | false     | `"false"`                                                                                                                  | The parameter that enables the Pre-install/upgrade Helm job. The job creates a database in PG, initiates the Hive schema, and upgrades if necessary. The database related parameters are set in the `postgres` and `hive` sections.                                                                                                                     |
| `s3InitJob.disableTLSValidation`         | bool              | false     | `"false"`                                                                                                                 | Disables TLS certificate validation for S3 storage in the job.                                                                                                                                                                                                                                                                                          |                                                                                                                                                                                                                                                                                                                                                      
| `s3InitJob.awsSigV4`                     | string            | false     | `"aws:minio:s3:s3"`                                                                                                       | AWS V4 signature authentication configuration of the following format `<provider1[:prvdr2[:reg[:srv]]]>`. Used to authenticate requests to S3 storage. Configured to work with S3 MinIO by default. Details at https://curl.se/docs/manpage.html.                                                                                                       |
| `s3InitJob.initAnnotations`              | string            | false     | `"helm.sh/hook": pre-install, pre-upgrade "helm.sh/hook-weight": "-10" helm.sh/hook-delete-policy": before-hook-creation` | The database init job annotations.                                                                                                                                                                                                                                                                                                                      |
| `s3InitJob.priorityClassName`            | string            | false     | `~`                                                                                                                       | Priority class name for init job.                                                                                                                                                                                                                                                                                                                       |
| `log4j2Properties`                       | multi-line string | false     | `The default properties' examples are below the table.`                                                                   | The Log4j2 configuration. The metastore logging level is set by the `property.metastore.log.level` property.                                                                                                                                                                                                                                            |
| `monitoring.enabled`                     | bool              | true      | `true`                                                                                                                    | The string to submit a Grafana dashboard. The custom parameter is not present in the **values.yaml** file.                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                    
| `monitoring.interval`                    | string            | false     | `60s`                                                                                                                     | This parameter parameter responsible for the amount of time after which the pod metrics are polled.                                                                                                                                                                                                                                                     |                                                                                                                                            
| `prometheusRules.alert.enable`           | bool              | true      | `true`                                                                                                                    | This parameter submits Prometheus rules for the Hive-Metastore.                                                                                                                                                                                                                                                                                         |
| `prometheusRules.alert.cpuThreshold`     | int               | false     | `90`                                                                                                                      | This parameter specifies the percentage of CPU resources' limit that triggers a CPU threshold alert. Note that the resource limit should be set.                                                                                                                                                                                                        |
| `prometheusRules.alert.memoryThreshold`  | int               | false     | `90`                                                                                                                      | This parameter specifies the percentage of memory resources' limit that triggers a memory threshold alert. Note that the resource limit should be set.                                                                                                                                                                                                  |                                                                                                                                                                                                                     
| `tls.enabled`                            | bool              | false     | `false`                                                                                                                   | Enables secure connections from Hive Metastore to PG and S3.                                                                                                                                                                                                                                                                                            |
| `tls.serverSideTls`                      | bool              | false     | `false`                                                                                                                   | Enables TLS for Hive Metastore server if `tls.enabled` is `true`.                                                                                                                                                                                                                                                                                       |
| `tls.generateCerts.enabled`              | string            | false     | `false`                                                                                                                   | The parameter to integrate cert-manager.                                                                                                                                                                                                                                                                                                                |
| `tls.generateCerts.secretName`           | string            | false     | `hive-metastore-certificate`                                                                                              | The name of the certificate for a TLS operation.                                                                                                                                                                                                                                                                                                        |
| `tls.generateCerts.clusterIssuerName`    | string            | false     | `common-cluster-issuer`                                                                                                   | The name of the issuer to create a certificate for a TLS operation.                                                                                                                                                                                                                                                                                     |
| `tls.generateCerts.keystores.jks.create` | bool              | false     | `false`                                                                                                                   | Enables keystore and truststore automatic creation if `tls.enabled`, `tls.serverSideTls` and `tls.generateCerts.enabled` are enabled.                                                                                                                                                                                                                   |
| `extraSecrets`                           | map               | false     | `{}`                                                                                                                      | Allows to create custom secrets to pass them to pods during the deployments. The format for secret data is "key/value" where key (can be templated) is the name of the secret that will be created, value - an object with the standard 'data' or 'stringData' key (or both). The value associated with those keys must be a string (can be templated). |
| `extraVolumes`                           | array             | false     | `[]`                                                                                                                      | One or more additional volume mounts to add to Hive Metastore and DB init job pods.                                                                                                                                                                                                                                                                     |
| `extraVolumeMounts`                      | array             | false     | `[]`                                                                                                                      | One or more additional volume mounts to add to Hive Metastore and DB init job pods.                                                                                                                                                                                                                                                                     |
| `secretMounts`                           | array             | false     | `[]`                                                                                                                      | One or more existing volume mounts to add to Hive Metastore and DB init job pods.                                                                                                                                                                                                                                                                       |
| `env`                                    | array             | false     | `[]`                                                                                                                      | Additional env parameters for Hive Metastore Service.                                                                                                                                                                                                                                                                                                    |

```yaml
# Default log4j2 properties
log4j2Properties: |
  status = INFO
  name = MetastoreLog4j2
  packages = org.apache.hadoop.hive.metastore

  # list of properties
  property.metastore.log.level = INFO
  property.metastore.root.logger = console
  property.metastore.log.dir = \${sys:java.io.tmpdir}/\${sys:user.name}
  property.metastore.log.file = metastore.log
  property.hive.perflogger.log.level = INFO

  # list of all appenders
  appenders = console

  # console appender
  appender.console.type = Console
  appender.console.name = console
  appender.console.target = SYSTEM_ERR
  appender.console.layout.type = PatternLayout
  appender.console.layout.pattern = %d{ISO8601} %5p [%t] %c{2}: %m%n

  # list of all loggers
  loggers = DataNucleus, Datastore, JPOX, PerfLogger

  logger.DataNucleus.name = DataNucleus
  logger.DataNucleus.level = ERROR

  logger.Datastore.name = Datastore
  logger.Datastore.level = ERROR

  logger.JPOX.name = JPOX
  logger.JPOX.level = ERROR

  logger.PerfLogger.name = org.apache.hadoop.hive.ql.log.PerfLogger
  logger.PerfLogger.level = \${sys:hive.perflogger.log.level}

  # root logger
  rootLogger.level = \${sys:metastore.log.level}
  rootLogger.appenderRefs = root
  rootLogger.appenderRef.root.ref = \${sys:metastore.root.logger}
```

## Enable HTTPS/TLS

You can use two options to enable HTTPS/TLS.

1. Using manual certificate for Trino.

1.1 Generate self-signed certificates for the Hive-Metastore service.

1.2 Pass the following parameters to the chart:

```yaml 
secretMounts:
  - name: sert
    secretName: hive-metastore-certificate
    path: /opt/hive/certs/
tls:
  enabled: true
  serverSideTls: true
  certificates:
    jks_key: "password_jks"
    keystore.jks: "keystore_certificate"
    truststore.jks: "truststore_certificate"
```

2. Using Cert-manager to get the certificate.

**Note**: Cert-manager must be installed in the cluster for this to work.

2.1 Use cluster-issuer to create a certificate.

Pass the following parameters to the chart:

```yaml
secretMounts:
  - name: sert
    secretName: hive-metastore-certificate
    path: /opt/hive/certs/
tls:
  enabled: true
  serverSideTls: true
  generateCerts:
    enabled: true
    secretName: hive-metastore-certificate
    clusterIssuerName: common-cluster-issuer
    keystores:
      jks:
        create: true
  certificates:
    jks_key: "password_jks"
```

## Secure Connections from Hive Metastore

In order to secure connections from Hive Metastore using TLS/SSL:

- An appropriate CA certificate needs to be imported to Java default truststore depending on the certificate used by a service that Hive Metastore will be connecting.
- In case of PostgreSQL, the certificate also needs to be mounted to `/home/metastore/.postgresql/root.crt` path using `extraVolumes` and `extraVolumeMounts` as described below in options 2 and 3.
- Connection settings should be configured to use TLS/SSL.

### Adding CA Certificates to Hive Metastore's Default Java Truststore

There are three options for adding certificates to Hive Metastore.

**Note**: The certificate should be mounted to `opt/hive/trustcerts`. All certificates from that directory are added to Java default truststore - cacerts.

1. Enable certificate generation to use cert-manager certificates.

```yaml
tls:
  enabled: true
  generateCerts:
    enabled: true
    secretName: hive-metastore-cm-cert
    clusterIssuerName: common-cluster-issuer    <--------- issuer should be the same as for the connecting service's certificate
    keystores:
      jks:
        create: true
    subjectAlternativeName:
      additionalDnsNames: [ ]
      additionalIpAddresses: [ ]
```

2. Add certificates using `extraSecrets` deployment parameter. In this case, the added secret should be mounted into the coordinator and the workers pod.  
   Mounting details are set using the `extraVolumes` and `extraVolumeMounts` parameters. The Certificates should be mounted to `opt/hive/trustcerts`.
```yaml
extraSecrets:
   mysslcert: # secret name
      stringData: |
         mysslcert.crt: |
           -----BEGIN CERTIFICATE-----
           Secret
           Content
           Goes
           Here
           -----END CERTIFICATE-----

extraVolumes:
  - name: tls-custom-cert
    secret:
      secretName: mysslcert

extraVolumeMounts:
  - name: tls-custom-cert
    mountPath: /opt/hive/trustcerts/mysslcert.crt
    subPath: mysslcert.crt
    readOnly: true
```

3. Add an existing secret to truststore. In this case, only `extraVolumes` and `extraVolumeMounts` parameters need to be configured to mount the secret.
   For example, to use `defaultsslcertificate` (`ca-bundle.crt` part), it can be configured as described in option 2.

```yaml
extraVolumes:
  - name: defaultcert
    secret:
      secretName: defaultsslcertificate

extraVolumeMounts:
  - name: defaultcert
    mountPath: /opt/hive/trustcerts/ca-bundle.crt
    subPath: ca-bundle.crt
    readOnly: true
```

### Configure Connections to Use SSL/TLS

This section provides details about configuring connections to use SSL or TLS.

#### PostgreSQL

Hive Metastore service deployment connects to PostgreSQL in several ways - using Java code, PSQL tool and Hive Metastore's schema tool. 

1. In order to secure connections from Hive Metastore to PostgreSQL using TLS/SSL an appropriate CA certificate needs to be imported to Java default truststore and also mounted to `/home/metastore/.postgresql/root.crt` path.  
You can add the certificates as described above in [Adding CA Certificates to Hive Metastore's Default Java Truststore](#adding-ca-certificates-to-hive-metastores-default-java-truststore).
Configuration example:

```yaml
extraSecrets:
  pgcert:
    stringData: |
      pgcert.crt: |
        -----BEGIN CERTIFICATE-----
        Secret
        Content
        Goes
        Here
        -----END CERTIFICATE-----

extraVolumes:
  - name: tls-pg-cert
    secret:
      secretName: pgcert

extraVolumeMounts:
  - name: tls-pg-cert
    mountPath: /home/metastore/.postgresql/root.crt
    subPath: pgcert.crt
    readOnly: true
```

2. To enable secure connection to PostgreSQL, the following parameters should be added to `postgres` section of deployemnt parameters. 
```yaml
postgres:
  psqlParams: "sslmode=verify-ca"
  jdbcParams: "ssl=true,sslfactory=org.postgresql.ssl.DefaultJavaSSLFactory" 
```

To ignore certificate validation, `sslfactory` should be set to `org.postgresql.ssl.NonValidatingFactory`, `sslmode` to `allow`:
```yaml
postgres:
  psqlParams: sslmode=allow
  jdbcParams: ssl=true,sslfactory=org.postgresql.ssl.NonValidatingFactory
```

PosgreSQL in metastore site properties should be configured as follows:

```yaml
metastoreConfigsecret:
  metastoreSitePropertiesSecret: |
    <configuration>
    ...
      <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://{{ include "postgres.host" . }}:{{ include "postgres.port" . }}/{{ .Values.hive.db }}{{ include "jdbcParams" (dict "Values" .Values "separator" "&amp;")}}</value>
      </property>
    ...
    </configuration>
```

#### S3

To enable secure connection to S3 storage, add the certificate as described above in [Adding CA Certificates to Hive Metastore's Default Java Truststore](#adding-ca-certificates-to-hive-metastores-default-java-truststore).

Enable S3 in coreSiteProperties as follows:

```yaml
metastoreConfigsecret:
  coreSitePropertiesSecret: |
    <configuration>
    ...
      <property>
        <name>fs.s3a.connection.ssl.enabled</name>
        <value>true</value>
      </property>
    ...
    </configuration>
```

For S3 buckets auto creation mount S3 CA certificate using `extraSecrets` and set `CURL_CA_BUNDLE`:
```yaml
extraSecrets:
  s3cert:
    stringData: |
      s3.pem: |
        -----BEGIN CERTIFICATE-----
        Secret
        Content
        Goes
        Here
        -----END CERTIFICATE-----

extraVolumes:
  - name: s3-tls-cert
    secret:
      secretName: s3cert

extraVolumeMounts:
  - name: s3-tls-cert
    mountPath: /opt/apache-hive-metastore-4.0.1-bin/certs/s3.pem
    subPath: s3.pem
    readOnly: true

env:
  - name: CURL_CA_BUNDLE
    value: '/opt/apache-hive-metastore-4.0.1-bin/certs/'
```

To ignore certificate validation for S3, the following properties should be added:

```yaml
env:
  - name: JAVA_TOOL_OPTIONS
    value: '-Dcom.amazonaws.sdk.disableCertChecking'

s3InitJob:
  enabled: true
  disableTLSValidation: true
```

## Monitoring Configuration

Monitoring is represented by Grafana Dashboard. To get the Hive-Metastore dashboards configured, perform the following steps:

1. Enable the Grafana dashboard.

   ```yaml
   metrics:
     enable: true
   ```

2. Configure and enable the Prometheus pod monitor.

   ```yaml
    prometheusRules:
    alert:
      enabled: true
      cpuThreshold: 90
      memoryThreshold: 90
   ```

## S3 Initialization Job

Hive Metastore requires a warehouse directory in S3 storage. It is configured by `s3.warehouseDir` deployment parameter.  
To automatically create the bucket and path, `s3InitJob` should be enabled (`s3InitJob.enabled` parameter must be set to `true`). After the bucket and path are created, a mock file is uploaded to the path to keep the path from being removed. 
`Curl` communicates with S3 storage by AWS S3 REST API uses `curl`. `Curl` supports AWS V4 signature authentication for requests. 

```yaml
s3InitJob:
  enabled: true
  awsSigV4: "aws:minio:s3:s3"
  disableTLSValidation: true
  priorityClassName: ~
  initAnnotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": before-hook-creation
  resources:
    limits:
      cpu: 50m
      memory: 64Mi
    requests:
      cpu: 50m
      memory: 64Mi
```

Signature configuration string is set in `s3InitJob.awsSigV4` and is different for different S3 storages. 
By default, `s3InitJob.awsSigV4: "aws:minio:s3:s3"` to work with S3 MinIO. If a different S3 storage is used, the signature configuration should be updated according the below instruction.

### AWS V4 Signature Configuration

Configuration string format: <provider1[:prvdr2[:reg[:srv]]]>

- The provider argument is a string that is used by the algorithm, when creating outgoing authentication headers.
- The region argument is a string that points to a geographic area of a resources collection (region-code), when the region name is omitted from the endpoint.
- The service argument is a string that points to a function provided by a cloud (service-code), when the service name is omitted from the endpoint.

### TLS 

TLS configuration is described in [Configure Connections to Use SSL/TLS](#s3)

# Installation

The installation procedure is specified in the below sub-sections.

## Manual Deployment

Refer to the releases page to find the release tag.

1. Navigate to the desired release tag and download the `<repo_root>/chart/helm/hivemetastore` directory.
   
2. Edit the parameters in the **values.yaml** file. The configuration parameter details are described above. For example, modify the following parameters:

```yaml
   For example,

   ```yaml
   s3:
     endpoint: your.s3.endpoint.address.com
     accessKey: minioaccess
     secretKey: miniosecret
     warehouseDir: s3a://warehouse/hive
 
   hive:
     user: hive
     password: hive_password
     db: metastore_db
  
   postgres:
     user: postgres_user
     password: password
     host: pg-patroni.postgres-service.svc
     port: 5432
     driver: org.postgresql.Driver
```

4. Install the chart to the K8s namespace created in the [Prerequisites](#prerequisites) section.

   ```
   helm install <helm release name> <path to chart directory> --values <path to your.values.yaml file> --namespace <namespace to install hive-metastore> --debug
   #Example
   helm install hive-metastore . --debug
   ```

# On-Prem

The installation process for On-Prem is specified below.

## HA Scheme

Hive-metastore supports the high availability mode.

To do this, you need to specify several replicas for its operation when deploying.

Pass the following parameters to the chart:

```yaml
replicaCount: 2 # or more replicas
```

## Non-HA Scheme

To do this, pass the following parameters to the chart:

```yaml
replicaCount: 1 
```

# Upgrade

You can perform the upgrade process using [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/).
It is required to check the new release notes for incompatibility points of parameters with the new version of Hive-metastore.

**Note**: You must set the `hiveInitJob.upgradeSchema` parameter to true when updating from hive 3.* versions to hive 4.* versions and when Hive-metastore database is not cleaned.

**Note**: If you need to change the S3 connection properties, you must manually recreate the Postgres Hive-metastore database and reinstall Hive-metastore after removing the previous release from the namespace.
