#!/usr/bin/env bash

if [[ $ES_ENABLE_SPRING_CLOUD == "true" ]];then
    export JAVA_OPTS="$JAVA_OPTS -javaagent:/app/.skywalking/skywalking-agent/skywalking-agent.jar -Dskywalking.collector.backend_service=skywalking.spring-cloud-system.svc.cluster.local:12800"
fi