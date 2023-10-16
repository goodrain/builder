#!/usr/bin/env bash

if [[ $ES_ENABLE_SKY == "true" ]];then
    export JAVA_OPTS="$JAVA_OPTS -javaagent:/app/.skywalking/skywalking-agent/skywalking-agent.jar -Dskywalking.collector.backend_service=8.130.132.137:11800"
fi