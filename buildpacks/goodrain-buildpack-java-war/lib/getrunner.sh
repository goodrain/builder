#!/usr/bin/env bash

source /tmp/buildpacks/functions/common.sh

try_dl_res(){
  local url=${1}
  if [ -z "$url" ]; then
    echo "Download $url is Null"
    exit 1
  fi
  for((i=1;i<=3;i++));do
    code=$(curl "$url" -L --silent --fail --retry 5 --retry-max-time 15 -o /tmp/xxx.tar.gz --write-out "%{http_code}")
    if [ "$code" != "200" ]; then
      echo "Unable to download from $url: $code,try $i"
    else
      break
    fi
  done
}

dl_webapp_runner(){
    local version=${1:-webapp-runner-8.5.38.0.jar}

    if [ ! -z "$ONLINE" ]; then
        # 在线构建默认使用OFFLINE
        WEBSERVER_BASE_URL="http://maven.goodrain.me/com/github/jsimone/webapp-runner"
    fi
    WEBSERVER_BASE_URL=${WEBSERVER_BASE_URL:-"${LANG_GOODRAIN_ME:-http://lang.goodrain.me}/java/webapp-runner"}
    WEBSERVER_URL_90=${WEBSERVER_URL_9:-"$WEBSERVER_BASE_URL/webapp-runner-9.0.16.0.jar"}
    WEBSERVER_URL_85=${WEBSERVER_URL_85:-"$WEBSERVER_BASE_URL/webapp-runner-8.5.38.0.jar"}
    WEBSERVER_URL_80=${WEBSERVER_URL_8:-"$WEBSERVER_BASE_URL/webapp-runner-8.0.52.0.jar"}
    WEBSERVER_URL_70=${WEBSERVER_URL_7:-"$WEBSERVER_BASE_URL/webapp-runner-7.0.91.0.jar"}

    get_dl_version=$(echo $version | awk -F '[-]' '{print $3}' | awk -F '.jar' '{print $1}')
    if [ ! -z "$WEBSERVER_URL" ]; then
        # 使用自定义地址
        DOWNLOAD_URL="$WEBSERVER_URL"
    else
        if [ ! -z "$ONLINE" ];then
            # 使用在线安装
            DOWNLOAD_URL="${WEBSERVER_BASE_URL}/${get_dl_version}/webapp-runner-${get_dl_version}.jar"
        else
            # 离线安装
            get_offline_version=$(echo $version | awk -F '[.-]' '{print $3"."$4}')
            if [ "$get_offline_version" == "7.0" ]; then
                DOWNLOAD_URL=$WEBSERVER_URL_70
            elif [ "$get_offline_version" == "8.0" ]; then
                DOWNLOAD_URL=$WEBSERVER_URL_80
            elif [ "$get_offline_version" == "9.0" ]; then
                DOWNLOAD_URL=$WEBSERVER_URL_90
            else
                DOWNLOAD_URL=$WEBSERVER_URL_85
            fi   
        fi
    fi
    if [ -n "${CUSTOMIZE_RUNTIMES_SERVER}" ]; then
      DOWNLOAD_URL=${CUSTOMIZE_RUNTIMES_SERVER_URL}
    fi
    status_pending "Start download webapp-runner ${version}"
    [ ! -z "$DEBUG_INFO" ] && status_pending "Download webapp-runner from $DOWNLOAD_URL" ||  status_pending "Download webapp-runner ${version}"
    try_dl_res $DOWNLOAD_URL
    wget --tries=3 -q "$DOWNLOAD_URL" -O "${BUILD_DIR}/webapp-runner.jar" 
    if [ $? -ne 0 ]; then
        error "Download webapp-runner from $DOWNLOAD_URL failed"
    else
        status_done
    fi
}


dl_jetty_runner(){
    local version=${1:-jetty-runner-9.4.0.v20161208.jar}
    
    if [ ! -z "$ONLINE" ]; then
        # 在线构建默认使用OFFLINE
        WEBSERVER_BASE_URL="http://maven.goodrain.me/org/eclipse/jetty/jetty-runner"
    fi
    WEBSERVER_BASE_URL=${WEBSERVER_BASE_URL:-"${LANG_GOODRAIN_ME:-http://lang.goodrain.me}/java/jetty-runner"}
    WEBSERVER_URL_754=${WEBSERVER_URL_9:-"$WEBSERVER_BASE_URL/jetty-runner-7.5.4.v20111024.jar"}
    WEBSERVER_URL_940=${WEBSERVER_URL_85:-"$WEBSERVER_BASE_URL/jetty-runner-9.4.0.v20161208.jar"}

    get_dl_version=$(echo $version | awk -F '[-]' '{print $3}' | awk -F '.jar' '{print $1}')
    if [ ! -z "$WEBSERVER_URL" ]; then
        # 使用自定义地址
        DOWNLOAD_URL="$WEBSERVER_URL"
    else
        if [ ! -z "$ONLINE" ];then
            # 使用在线安装
            DOWNLOAD_URL="${WEBSERVER_BASE_URL}/${get_dl_version}/jetty-runner-${get_dl_version}.jar"
        else
            # 离线安装
            get_offline_version=$(echo $version | awk -F '[.-]' '{print $3"."$4"."$5}')
            if [ "$get_offline_version" == "7.5.4" ]; then
                DOWNLOAD_URL=$WEBSERVER_URL_754
            else
                DOWNLOAD_URL=$WEBSERVER_URL_940
            fi   
        fi
    fi
    [ ! -z "$DEBUG_INFO" ] && status_pending "Download jetty-runner from $DOWNLOAD_URL" ||  status_pending "Download jetty-runner ${version}"
    try_dl_res $DOWNLOAD_URL
    wget --tries=3 -q $DOWNLOAD_URL -O ${BUILD_DIR}/jetty-runner.jar && status_done || error "Download jetty-runner from $DOWNLOAD_URL failed"
}