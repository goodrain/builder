#!/usr/bin/env bash

if [[ $ES_ENABLE_SPRING_CLOUD == "true" ]];then
  export SW_AGENT_COLLECTOR_BACKEND_SERVICES=${SW_AGENT_COLLECTOR_BACKEND_SERVICES:-skywalking-oap.spring-cloud-system.svc.cluster.local:11800}
  NACOS_ADDR=${NACOS_ADDR:-nacos.spring-cloud-system.svc.cluster.local:8848}
  ES_APP_NAME=$(echo "$SERVICE_NAME" | rev | cut -d'-' -f2- | rev) # 团队下的应用英文名
  ES_SERVICE_NAME=$(echo "$SERVICE_NAME" | rev | cut -d'-' -f1 | rev) # 团队下的应用下的组件英文名
  curl -X POST "http://$NACOS_ADDR/nacos/v2/console/namespace" -d "namespaceId=${ES_APP_NAME}&namespaceName=${ES_APP_NAME}"
  echo "spring:
    application:
      name: ${ES_SERVICE_NAME}
    cloud:
      sentinel:
        datasource:
          rbd_flow:
            nacos:
              serverAddr: ${NACOS_ADDR}
              dataId: ${ES_SERVICE_NAME}-flow-rules
              ruleType: flow
              groupId: SENTINEL_GROUP
              dataType: json
        transport:
          port: 8719
          dashboard: ${SENTINEL_ADDR:-sentinel.spring-cloud-system.svc.cluster.local:8080}
      nacos:
        config:
          file-extension: yaml
          refresh-enabled: true
          enabled: true
          server-addr: ${NACOS_ADDR}
          namespace: ${ES_APP_NAME}
          group: DEFAULT_GROUP
          extension-configs:
            - data-id: rbd-gateway-routes.yaml
              group: GATEWAY_GROUP
              refresh: true
        discovery:
          server-addr: ${NACOS_ADDR}
          namespace: ${ES_APP_NAME}
          enabled: true" > local-spring-cloud.yaml
  export JAVA_OPTS="$JAVA_OPTS -javaagent:/app/.skywalking/skywalking-agent/skywalking-agent.jar -Dskywalking.agent.service_name=${ES_APP_NAME}::${ES_SERVICE_NAME} -Dspring.config.additional-location=local-spring-cloud.yaml"
fi