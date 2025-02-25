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

FROM alpine:latest AS unpacker

ENV HADOOP_DEP=/opt/dependencies
ENV HADOOP_VERSION=3.3.6
ENV HIVE_VERSION=4.0.1

RUN apk add --no-cache curl

RUN mkdir -p ${HADOOP_DEP} && \
    curl -k https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar xvz -C ${HADOOP_DEP} && \
    curl -k https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore-server/$HIVE_VERSION/hive-standalone-metastore-server-$HIVE_VERSION-bin.tar.gz | tar xvz -C ${HADOOP_DEP} && \
    curl -k -L https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/1.0.1/jmx_prometheus_javaagent-1.0.1.jar --output ${HADOOP_DEP}/jmx_prometheus_javaagent-1.0.1.jar && \
    curl -k -L https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.4/postgresql-42.7.4.jar --output ${HADOOP_DEP}/postgresql-42.7.4.jar && \
    curl -k -L https://repo1.maven.org/maven2/org/jdom/jdom2/2.0.6.1/jdom2-2.0.6.1.jar --output ${HADOOP_DEP}/jdom2-2.0.6.1.jar && \
    curl -k -L https://repo1.maven.org/maven2/org/codehaus/jackson/jackson-mapper-asl/1.9.13-cloudera.3/jackson-mapper-asl-1.9.13-cloudera.3.jar --output ${HADOOP_DEP}/jackson-mapper-asl-1.9.13-cloudera.3.jar
    
RUN mkdir -p /opt/postgresql-42.7.4 /opt/jackson-mapper-asl

RUN mv ${HADOOP_DEP}/hadoop-$HADOOP_VERSION /opt/hadoop && \
    mv ${HADOOP_DEP}/apache-hive-metastore-4.0.1-bin /opt/hive-metastore && \
    mv ${HADOOP_DEP}/jmx_prometheus_javaagent-1.0.1.jar /opt/hive-metastore/lib/jmx_prometheus_javaagent-1.0.1.jar && \
    mv ${HADOOP_DEP}/postgresql-42.7.4.jar /opt/postgresql-42.7.4/postgresql-42.7.4.jar && \
    mv ${HADOOP_DEP}/jdom2-2.0.6.1.jar /opt/hadoop/share/hadoop/tools/lib/jdom2-2.0.6.1.jar && \
    mv ${HADOOP_DEP}/jackson-mapper-asl-1.9.13-cloudera.3.jar /opt/jackson-mapper-asl/jackson-mapper-asl-1.9.13-cloudera.3.jar

RUN rm -r opt/hadoop/share/doc && \
    rm opt/hive-metastore/lib/postgresql-42.5.1.jar && \
    rm opt/hadoop/share/hadoop/tools/lib/jdom2-2.0.6.jar && \
    rm opt/hadoop/share/hadoop/common/lib/jackson-mapper-asl-1.9.13.jar && \
    rm opt/hadoop/share/hadoop/hdfs/lib/jackson-mapper-asl-1.9.13.jar && \
    chmod -R 755 opt

RUN ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/postgresql-42.7.4/postgresql-42.7.4.jar /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/postgresql-42.7.4/postgresql-42.7.4.jar /opt/hive-metastore/lib/ && \
    ln -s /opt/jackson-mapper-asl/jackson-mapper-asl-1.9.13-cloudera.3.jar /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/jackson-mapper-asl/jackson-mapper-asl-1.9.13-cloudera.3.jar /opt/hadoop/share/hadoop/hdfs/lib/

RUN mkdir -p /opt/hive-metastore-metrics/metrics \
    && sed -i '/export HADOOP_OPTS="\$METASTORE_HADOOP_OPTS \$HADOOP_OPTS"/a\  export HADOOP_OPTS="\$HADOOP_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9025 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -javaagent:\/opt\/hive-metastore\/lib\/jmx_prometheus_javaagent-1.0.1.jar=9028:\/opt\/hive-metastore\/conf\/jmx-exporter-config.yaml -Dcom.sun.management.jmxremote.ssl=false"' /opt/hive-metastore/bin/ext/metastore.sh

FROM eclipse-temurin:17-jre-noble

ENV HIVE_USER_NAME=metastore
ENV TRUST_CERTS_DIR=/opt/hive-metastore/trustcerts
ENV HIVE_HOME=/opt/hive-metastore
ENV HADOOP_HOME=/opt/hadoop

USER root

COPY --chmod=0755 docker/entrypoint.sh /opt/entrypoint.sh

RUN set -ex && \
apt-get update && apt-get install -y procps postgresql-client --no-install-recommends

RUN groupadd ${HIVE_USER_NAME} --gid 10002 && \
    useradd ${HIVE_USER_NAME} --uid 10002 --gid 10002 --create-home && \
    mkdir -p /usr/lib/${HIVE_USER_NAME} /data/${HIVE_USER_NAME} && \
    chown -R "${HIVE_USER_NAME}:${HIVE_USER_NAME}" /usr/lib/${HIVE_USER_NAME} /data/${HIVE_USER_NAME}

COPY --from=unpacker /opt /opt

RUN mkdir -p ${TRUST_CERTS_DIR} && \
    chmod 777 ${JAVA_HOME}/lib/security/cacerts && \
    chmod -R 777 ${TRUST_CERTS_DIR}

USER ${HIVE_USER_NAME}
WORKDIR $HIVE_HOME
ENTRYPOINT [ "/opt/entrypoint.sh" ]
