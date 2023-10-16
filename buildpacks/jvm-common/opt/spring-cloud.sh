#!/usr/bin/env bash

if [[ $ES_ENABLE_SPRING_CLOUD == "true" ]];then
  NACOS_ADDR=${NACOS_ADDR:-nacos.spring-cloud-system.svc.cluster.local:8848}
  curl -X POST "http://$NACOS_ADDR/nacos/v2/console/namespace" -d "namespaceId=${SERVICE_ID}&namespaceName=${SERVICE_ID}"

  export JAVA_OPTS="$JAVA_OPTS -javaagent:/app/.skywalking/skywalking-agent/skywalking-agent.jar -Dskywalking.collector.backend_service=skywalking.spring-cloud-system.svc.cluster.local:12800"
fi