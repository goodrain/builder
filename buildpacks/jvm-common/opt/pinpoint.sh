#!/usr/bin/env bash

if [[ $ES_ENABLE_APM == "true" ]];then
    ES_TRACE_AGENT_ID=${SERVICE_ID:0:10}
    PINPOINT_AGETN_VERSION=1.7.2
    PINPOINT_AGENT_PATH=/app/.pinpoint
    COLLECTOR_TCP_HOST=${COLLECTOR_TCP_HOST:-127.0.0.1}
    COLLECTOR_TCP_PORT=${COLLECTOR_TCP_PORT:-9994}
    COLLECTOR_UDP_SPAN_LISTEN_HOST=${COLLECTOR_UDP_SPAN_LISTEN_HOST:-127.0.0.1}
    COLLECTOR_UDP_SPAN_LISTEN_PORT=${COLLECTOR_UDP_SPAN_LISTEN_PORT:-9996}
    COLLECTOR_UDP_STAT_LISTEN_HOST=${COLLECTOR_UDP_STAT_LISTEN_HOST:-127.0.0.1}
    COLLECTOR_UDP_STAT_LISTEN_PORT=${COLLECTOR_UDP_STAT_LISTEN_PORT:-9995}
    export JAVA_OPTS="$JAVA_OPTS -javaagent:${PINPOINT_AGENT_PATH}/pinpoint-bootstrap-${PINPOINT_AGETN_VERSION}-SNAPSHOT.jar -Dpinpoint.agentId=${ES_TRACE_AGENT_ID:-${SERVICE_ID:0:10}} -Dpinpoint.applicationName=${ES_TRACE_APP_NAME:-${SERVICE_NAME:-$HOSTNAME}}"
    sed -i -r -e "s/(profiler.collector.ip)=.*/\1=${COLLECTOR_TCP_HOST}/" \
            -e "s/(profiler.collector.tcp.port)=.*/\1=${COLLECTOR_TCP_PORT}/" \
            -e "s/(profiler.collector.span.port)=.*/\1=${COLLECTOR_UDP_SPAN_LISTEN_PORT}/" \
            -e "s/(profiler.collector.stat.port)=.*/\1=${COLLECTOR_UDP_STAT_LISTEN_PORT}/" "${PINPOINT_AGENT_PATH}/pinpoint.config"
fi