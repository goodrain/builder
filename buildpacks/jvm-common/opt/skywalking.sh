#!/usr/bin/env bash

if [[ $ES_ENABLE_SKY == "true" ]];then

    status 'ES_ENABLE_SKY is true'
#    JMX_EXPORTER_AGENT_VERSION=${JMX_EXPORTER_AGENT_VERSION:-0.15.0}
#    JMX_EXPORTER_AGENT_PATH=/app/.jmx-exporter
#    JMX_EXPORTER_HTTP_PORT=${JMX_EXPORTER_HTTP_PORT:-5556}
#    JMX_EXPORTER_CONFIG=${JMX_EXPORTER_CONFIG:-"/app/.jmx-exporter/config.yaml"}
#    export JAVA_OPTS="$JAVA_OPTS -javaagent:${JMX_EXPORTER_AGENT_PATH}/jmx_prometheus_javaagent-${JMX_EXPORTER_AGENT_VERSION}.jar=${JMX_EXPORTER_HTTP_PORT}:${JMX_EXPORTER_CONFIG}"
fi