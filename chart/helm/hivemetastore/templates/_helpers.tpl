{{/*
 Copyright 2024-2025 NetCracker Technology Corporation

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "hive-metastore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hive-metastore.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "hive-metastore.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hive-metastore.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hive-metastore.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{ define "hivemetastore_image" -}}
{{ printf "%s:%v" (.Values.image.repository) (.Values.image.tag) }}
{{- end }}

{{/*
MinIO S3 Endpoint
*/}}
{{- define "s3.endpoint" -}}
    {{- .Values.s3.endpoint -}}
{{- end -}}

{{/*
MinIO S3 accesskey
*/}}
{{- define "s3.accessKey" -}}
    {{- .Values.s3.accessKey -}}
{{- end -}}

{{/*
MinIO S3 secretkey
*/}}
{{- define "s3.secretKey" -}}
    {{- .Values.s3.secretKey -}}
{{- end -}}

{{/*
Postgres Host
*/}}
{{- define "postgres.host" -}}
    {{- .Values.postgres.host -}}
{{- end -}}

{{/*
Postgres Port
*/}}
{{- define "postgres.port" -}}
    {{- .Values.postgres.port -}}
{{- end -}}

{{/*
Postgres Admin User
*/}}
{{- define "postgres.adminUser" -}}
    {{- .Values.postgres.adminUser -}}
{{- end -}}

{{/*
Postgres Admin Password
*/}}
{{- define "postgres.adminPassword" -}}
    {{- .Values.postgres.adminPassword -}}
{{- end -}}


{{/*
Hive User
*/}}
{{- define "postgres.hive.user" -}}
    {{- .Values.hive.user -}}
{{- end -}}

{{/*
Hive Password
*/}}
{{- define "postgres.hive.password" -}}
    {{- .Values.hive.password -}}
{{- end -}}

{{/*
    Postgres Connection URL
 */}}
  {{- define "postgres.psql.connection.url" -}}
  {{- if and .Values.tls.enabled .Values.postgres.psqlParams -}}
  {{ printf "postgresql://%s:%s@%s:%s?%s" (include "postgres.adminUser" .) (include "postgres.adminPassword" .) (include "postgres.host" .) (include "postgres.port" .) ( .Values.postgres.psqlParams ) }}
  {{- else -}}
  {{ printf "postgresql://%s:%s@%s:%s" (include "postgres.adminUser" .) (include "postgres.adminPassword" .) (include "postgres.host" .) (include "postgres.port" .)}}
  {{- end -}}
{{- end -}}

{{- define "jdbcParams" -}}
{{- if .Values.postgres.jdbcParams -}}
{{- $params := default "" (.Values.postgres.jdbcParams | replace "," .separator) -}}
{{ printf "?%s" $params }}
{{- end -}}
{{- end -}}

{{/*
Selector labels for qubership release
*/}}
{{- define "selector_labels" -}}
app.kubernetes.io/instance: {{ cat .Release.Name "-" .Release.Namespace | nospace | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ include "hive-metastore.name" . }}
{{- end }}

{{/*
Deployment only labels for qubership release
*/}}
{{- define "deployment_only_labels" -}}
app.kubernetes.io/instance: {{ cat .Release.Name "-" .Release.Namespace | nospace | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/version: {{ splitList ":" ( include "hivemetastore_image" . ) | last }}
app.kubernetes.io/technology: java-others
{{- end }}


{{/*
Deployment and service only labels for qubership release
*/}}
{{- define "deployment_and_service_only_labels" -}}
name: {{ include "hive-metastore.name" . }}
app.kubernetes.io/name: {{ include "hive-metastore.name" . }}
{{- end }}

{{/*
All object labels for qubership release
*/}}
{{- define "all_objects_labels" -}}
app.kubernetes.io/part-of: hive-metastore
{{- end }}

{{/*
Processed by grafana operator label for qubership release
*/}}
{{- define "grafana_operator_label" -}}
app.kubernetes.io/processed-by-operator: grafana-operator
{{- end }}

{{/*
Processed by prometheus operator label for qubership release
*/}}
{{- define "prometheus_operator_label" -}}
app.kubernetes.io/processed-by-operator: prometheus-operator
{{- end }}

{{/*
Processed by cert-manager label for qubership release
*/}}
{{- define "cert_manager_label" -}}
app.kubernetes.io/processed-by-operator: cert-manager
{{- end }}
{{/*
  only labels for qubership Release
*/}}
{{- define "qubership_release_only_label_component" -}}
app.kubernetes.io/component: backend
{{- end }}
{{- define "qubership_release_only_label_managed_by" -}}
app.kubernetes.io/managed-by: Helm
{{- end }}
