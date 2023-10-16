#!/usr/bin/env bash

if [[ $ES_ENABLE_SPRING_CLOUD == "true" ]];then
  export SW_AGENT_COLLECTOR_BACKEND_SERVICES=${SW_AGENT_COLLECTOR_BACKEND_SERVICES:-skywalking-oap.spring-cloud-system.svc.cluster.local:11800}
  NACOS_ADDR=${NACOS_ADDR:-nacos.spring-cloud-system.svc.cluster.local:8848}
  NS_NAME=${TENANT_ID} # 命名空间名称
  APP_NAME=${SERVICE_ID} # 应用名称
  curl -X POST "http://$NACOS_ADDR/nacos/v2/console/namespace" -d "namespaceId=${NS_NAME}&namespaceName=${NS_NAME}"
  echo "spring:
    cloud:
      nacos:
        discovery:
          server-addr: ${NACOS_ADDR}
          namespace: ${NS_NAME}
          enabled: true" > local-spring-cloud.yaml
  export JAVA_OPTS="$JAVA_OPTS -javaagent:/app/.skywalking/skywalking-agent/skywalking-agent.jar -Dskywalking.agent.service_name=${NS_NAME}::${APP_NAME} -Dspring.config.additional-location=local-spring-cloud.yaml"
fi