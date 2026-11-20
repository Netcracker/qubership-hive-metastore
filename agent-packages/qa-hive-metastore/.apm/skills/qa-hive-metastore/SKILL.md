---
name: qa-hive-metastore
description: Plan and verify testing of a Qubership Hive Metastore change when the repository has no automated tests — deploy-based verification of metastore schema init and upgrade, PostgreSQL credentials, S3 vs SeaweedFS warehouse initialisation, TLS, HA replicas and client compatibility with Trino, Spark and Airflow. Triggers when the user asks how to test a Hive Metastore chart or image change, or why the metastore will not start. Do NOT run automatically.
---

## Read this first

**This repository has no tests.** No unit tests, no integration tests, no Helm test hooks,
no Robot suite. The only static gate is `docker-transfer/validation.py`, which fails the
transfer image build when `values.yaml` defaults drift from `values.schema.json`.

That checker runs as:

```
python validation.py chart/helm/hivemetastore/values.yaml chart/helm/hivemetastore/values.schema.json
python sync.py chart/helm/hivemetastore/release-images.yaml chart/helm/hivemetastore/values.yaml
```

Practical consequence: **every behavioural claim about a change must come from a deployment.**
When you report coverage, say "verified by deployment in <env>" — never "tests pass".

---

## The component

Deploys **Apache Hive Metastore only** — no HiveServer2. Upstream pins:
`HADOOP_VERSION=3.4.3`, `HIVE_VERSION=4.2.1`, `SEAWEEDFS_VERSION=4.38`.
Metadata in PostgreSQL, warehouse in S3/MinIO or SeaweedFS.

Object names are pinned regardless of release name (`nameOverride` / `fullnameOverride` are
both `hive-metastore`), so tests may reuse the same Service DNS across installs.

Ports: `9083` service, `9028` metrics.

---

## The de-facto integration tests are the Helm jobs

These are where most defects actually surface. Treat each as a required check:

| Job | When it runs | What it proves | What it can hide |
| --- | --- | --- | --- |
| `hiveInitJob` | pre-install / pre-upgrade hook | DB reachable, schema init or upgrade succeeded | auto-upgrade masks a missing `upgradeSchema: true` |
| `s3InitJob` | when `s3InitJob.enabled` | warehouse directory created | **disabled by default** |

`hiveInitJob` auto-upgrades the schema when validation output matches
`Failed in schema version validation` or `is not compatible`, so a passing job does **not**
prove `hiveInitJob.upgradeSchema` was configured correctly. Assert the resulting schema version
when testing an upgrade.

`s3InitJob` is `enabled: false` by default — a clean install tests S3 wiring only if you
explicitly turn it on.

---

## Variants that must be exercised

| Variant | Keys | Why it matters |
| --- | --- | --- |
| Fresh install | defaults | schema created from scratch |
| Upgrade Hive 3 → 4 | `hiveInitJob.upgradeSchema: true`, `hiveInitJob.cleanupDB: false` | without the flag, only the auto-upgrade heuristic saves you |
| S3 warehouse | `s3.endpoint/accessKey/secretKey/warehouseDir`, `s3InitJob.enabled` | SigV4 path |
| SeaweedFS warehouse | `s3.warehouseDir: seaweedfs://…` | completely different code path — see below |
| TLS | `tls.enabled`, `tls.serverSideTls`, `tls.generateCerts.*` | keystore path hardcoded |
| HA | `replicaCount: 2+` | concurrent metastore instances against one PG |
| Read-only root FS | `securityContext.readOnlyRootFilesystem: true` | requires `emptyDir` at `/tmp` and `/java-security` |
| OpenShift | `PAAS_PLATFORM: OPENSHIFT` | `runAsUser`/`fsGroup` omitted |
| Cert rotation | `initJobCredentialsSecret`, `TRUST_CERTS_DIR` | entrypoint imports certs with `keytool`, failures are swallowed |

### SeaweedFS is a different path, not a variant

With a `seaweedfs://` warehouse URI:

- `s3InitJob` calls the **filer HTTP API** (`POST <filer>/<dir>`) and **ignores** `s3.endpoint`,
  `s3.accessKey`, `s3.secretKey` and `s3InitJob.awsSigV4`.
- `s3InitJob` does **not** understand SeaweedFS authentication at all — it connects over plain
  HTTP without credentials. Documented workaround: create the warehouse directory manually and
  keep `s3InitJob` disabled.

A test that sets SeaweedFS credentials and expects them to be honoured will pass for the wrong
reason.

---

## Known traps

- **Cert checking cannot be disabled on Hive ≥ 4.1.** `-Dcom.amazonaws.sdk.disableCertChecking`
  no longer works (AWS SDK v2). A self-signed endpoint needs a real truststore.
- **Database names are mangled.** The helper applies `replace "-" "_" | trunc 63 | trimSuffix "_"`
  to the namespace-derived name. Assert the real name, not the obvious one.
- **Read-only FS needs both mounts.** Missing `common-space` at `/tmp` or `/java-security`
  breaks the pod and the init jobs.
- **`metastore.keystore.path` is hardcoded** to `/opt/hive-metastore/certs/keystore.jks` when
  server-side TLS is on.
- **Credentials are files, not env.** `/etc/credentials/hive_username|hive_password`;
  s3 job reads `s3_accessKey|s3_secretKey`; secret `defaultMode: 0400`.
- **Client compatibility is not symmetric.** `README.md` shows a Spark example pinned to
  **Hive metastore 3.1.3** client with `schema.verification=false` against a 4.2.1 server.
  Always test the actual clients in the platform: **Trino**, **Spark**
  (`spark.sql.hive.metastore.version`), and **Airflow** (`metastore_default` connection).
- **Docs drift.** `installation.md` shows `s3InitJob.awsSigV4` default `"aws:minio:s3:s3"` while
  `values.yaml` is `"aws:sigv4:us-east-2:s3"`; docs mention `metrics.enable` while the chart
  uses `monitoring.enabled`. **`values.yaml` and `values.schema.json` are the ground truth.**

---

## What a deployment test must include

Since nothing is automated, a change has no coverage until you have demonstrated:

1. `helm template` renders for the changed values (and `helm lint` if available).
2. Fresh install completes and `hiveInitJob` succeeds — with the resulting schema version read
   from PostgreSQL, not inferred from job status.
3. The metastore responds on `9083` — verify with a **real client**: create and list a table
   through Trino and through Spark.
4. Warehouse path is created and writable for the chosen backend.
5. Upgrade from the previous release preserves existing tables (query them after upgrade).
6. If TLS is on: clients trust the certificate; `9028` metrics scrape succeeds.
7. If `replicaCount > 1`: both instances serve and a table created via one is visible via the
   other.

State explicitly which of these you did **not** verify, and why.

---

## Reviewing a change

- Did it touch the SQL/init path, the S3 job, TLS, or the container image?
- Is there a chart check that should fail for the old behaviour? If not, propose one — the
  cheapest durable protection in this repo is a `values.schema.json` constraint or an init-job
  assertion.
- Is the change compatible with the clients actually deployed (Trino, Spark, Airflow)? Verify,
  do not assume.
- Flag doctest drift: if the change alters a default, ensure `values.schema.json` and the
  validation script still agree, or the transfer image build breaks.
