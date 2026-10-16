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

attempt_setup_fake_passwd_entry() {
  # Check whether there is a passwd entry for the container UID
  local myuid; myuid="$(id -u)"
  # If there is no passwd entry for the container UID, attempt to fake one.
  # It's to resolve the OpenShift random UID case. The approach is the same as in the Spark image.
  # Hadoop fails to log in without a passwd entry for the UID.
  # See also: https://github.com/docker-library/postgres/pull/448
  if ! getent passwd "$myuid" &> /dev/null; then
      local wrapper
      for wrapper in {/usr,}/lib{/*,}/libnss_wrapper.so; do
        if [ -s "$wrapper" ]; then
          NSS_WRAPPER_PASSWD="$(mktemp)"
          NSS_WRAPPER_GROUP="$(mktemp)"
          export LD_PRELOAD="$wrapper" NSS_WRAPPER_PASSWD NSS_WRAPPER_GROUP
          local mygid; mygid="$(id -g)"
          printf '%s:x:%s:%s:%s:%s:/bin/false\n' "${HIVE_USER_NAME:-metastore}" "$myuid" "$mygid" "anonymous uid" "${HIVE_HOME:-/opt/hive-metastore}" > "$NSS_WRAPPER_PASSWD"
          printf '%s:x:%s:\n' "${HIVE_USER_NAME:-metastore}" "$mygid" > "$NSS_WRAPPER_GROUP"
          break
        fi
      done
  fi
}

attempt_setup_fake_passwd_entry

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