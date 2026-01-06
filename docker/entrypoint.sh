#!/usr/bin/env bash
# Copyright 2024-2025 NetCracker Technology Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

WRITABLE_CACERTS="/java-security/cacerts"
ORIGINAL_CACERTS="${JAVA_HOME}/lib/security/cacerts"

echo "Copying system cacerts to writable space..."
cp "${ORIGINAL_CACERTS}" "${WRITABLE_CACERTS}"

export JAVA_TOOL_OPTIONS="${JAVA_TOOL_OPTIONS} -Djavax.net.ssl.trustStore=${WRITABLE_CACERTS} -Djavax.net.ssl.trustStorePassword=changeit"
set +e
if [[ "$(ls ${TRUST_CERTS_DIR})" ]]; then
    for filename in ${TRUST_CERTS_DIR}/*; do
        echo "Import $filename certificate to Java cacerts"
        ${JAVA_HOME}/bin/keytool -import -trustcacerts -keystore "${WRITABLE_CACERTS}" -storepass changeit -noprompt -alias "$(basename ${filename})" -file "${filename}"
    done;
fi
set -e

/opt/hive-metastore/bin/start-metastore -p "${HIVE_SERVICE_PORT:-9083}"