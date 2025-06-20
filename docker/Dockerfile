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

ENV HADOOP_VERSION=3.3.6
ENV HIVE_VERSION=4.0.1
ENV MAVEN_REPO=https://repo1.maven.org/maven2


RUN apk add --no-cache curl

RUN mkdir -p /opt/hadoop /opt/hive-metastore && \
    curl -k https://dlcdn.apache.org/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar xvz --strip-components=1 -C /opt/hadoop && \
    curl -k $MAVEN_REPO/org/apache/hive/hive-standalone-metastore-server/$HIVE_VERSION/hive-standalone-metastore-server-$HIVE_VERSION-bin.tar.gz | tar xvz --strip-components=1 -C /opt/hive-metastore && \
    curl -k -L $MAVEN_REPO/io/prometheus/jmx/jmx_prometheus_javaagent/1.0.1/jmx_prometheus_javaagent-1.0.1.jar --output /opt/hive-metastore/lib/jmx_prometheus_javaagent-1.0.1.jar && \
    mkdir -p /opt/postgresql-42.7.7 && \
    curl -k -L $MAVEN_REPO/org/postgresql/postgresql/42.7.7/postgresql-42.7.7.jar --output /opt/postgresql-42.7.7/postgresql-42.7.7.jar && \
    curl -k -L $MAVEN_REPO/org/jdom/jdom2/2.0.6.1/jdom2-2.0.6.1.jar --output /opt/hadoop/share/hadoop/tools/lib/jdom2-2.0.6.1.jar && \
    mkdir -p /opt/jackson-mapper-asl && \
    curl -k -L $MAVEN_REPO/org/codehaus/jackson/jackson-mapper-asl/1.9.13-cloudera.3/jackson-mapper-asl-1.9.13-cloudera.3.jar --output /opt/jackson-mapper-asl/jackson-mapper-asl-1.9.13-cloudera.3.jar && \
    curl -k -L $MAVEN_REPO/io/netty/netty-handler/4.1.118.Final/netty-handler-4.1.118.Final.jar --output /opt/netty-handler-4.1.118.Final/netty-handler-4.1.118.Final.jar && \
    curl -k -L $MAVEN_REPO/io/airlift/aircompressor/0.27/aircompressor-0.27.jar --output /opt/aircompressor-0.27/aircompressor-0.27.jar && \
    curl -k -L $MAVEN_REPO/org/eclipse/jetty/jetty-server/9.4.57.v20241219/jetty-server-9.4.57.v20241219.jar --output /opt/jetty-server-9.4.57.v20241219/jetty-server-9.4.57.v20241219.jar && \
    curl -k -L $MAVEN_REPO/io/netty/netty-codec-http2/4.1.100.Final/netty-codec-http2-4.1.100.Final.jar --output /opt/netty-codec-http2-4.1.100.Final/netty-codec-http2-4.1.100.Final.jar && \
    rm -r opt/hadoop/share/doc && \
    rm -r opt/hadoop/share/hadoop/yarn && \
    rm opt/hive-metastore/lib/postgresql-42.5.1.jar && \
    rm opt/hive-metastore/lib/netty-handler-4.1.94.Final.jar && \
    rm opt/hive-metastore/lib/aircompressor-0.21.jar && \
    rm opt/hadoop/share/hadoop/common/lib/jetty-server-9.4.51.v20230217.jar && \
    rm opt/hive-metastore/lib/jetty-server-9.4.45.v20220203.jar && \
    rm opt/hadoop/share/hadoop/common/lib/netty-codec-http2-4.1.89.Final.jar && \
    rm opt/hadoop/share/hadoop/tools/lib/jdom2-2.0.6.jar && \
    rm opt/hadoop/share/hadoop/common/lib/jackson-mapper-asl-1.9.13.jar && \
    rm opt/hadoop/share/hadoop/hdfs/lib/jackson-mapper-asl-1.9.13.jar && \
    chmod -R 755 opt && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/postgresql-42.7.7/postgresql-42.7.7.jar /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/postgresql-42.7.7/postgresql-42.7.7.jar /opt/hive-metastore/lib/ && \
    ln -s /opt/netty-handler-4.1.118.Final/netty-handler-4.1.118.Final.jar /opt/hive-metastore/lib/ && \
    ln -s /opt/aircompressor-0.27/aircompressor-0.27.jar /opt/hive-metastore/lib/ && \
    ln -s /opt/jetty-server-9.4.57.v20241219/jetty-server-9.4.57.v20241219.jar /opt/hive-metastore/lib/ && \
    ln -s /opt/jetty-server-9.4.57.v20241219/jetty-server-9.4.57.v20241219.jar /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/netty-codec-http2-4.1.100.Final/netty-codec-http2-4.1.100.Final.jar /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/jackson-mapper-asl/jackson-mapper-asl-1.9.13-cloudera.3.jar /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/jackson-mapper-asl/jackson-mapper-asl-1.9.13-cloudera.3.jar /opt/hadoop/share/hadoop/hdfs/lib/ && \
    mkdir -p /opt/hive-metastore-metrics/metrics \
    && sed -i '/export HADOOP_OPTS="\$METASTORE_HADOOP_OPTS \$HADOOP_OPTS"/a\  export HADOOP_OPTS="\$HADOOP_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9025 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -javaagent:\/opt\/hive-metastore\/lib\/jmx_prometheus_javaagent-1.0.1.jar=9028:\/opt\/hive-metastore\/conf\/jmx-exporter-config.yaml -Dcom.sun.management.jmxremote.ssl=false"' /opt/hive-metastore/bin/ext/metastore.sh

FROM eclipse-temurin:17-jre-noble

ENV HIVE_USER_NAME=metastore
ENV TRUST_CERTS_DIR=/opt/hive-metastore/trustcerts
ENV HIVE_HOME=/opt/hive-metastore
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_YARN_HOME=/opt/hadoop

USER root

COPY --chmod=0755 docker/entrypoint.sh /opt/entrypoint.sh

RUN set -ex && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        procps \
        postgresql-client \
        openssl \
        libssl3t64 

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
