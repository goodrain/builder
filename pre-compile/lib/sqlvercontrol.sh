#!/bin/bash
# 利用 Liquibase 进行数据库表结构的管理
# 通过检测源码目录下指定文件夹下的 changelog 文件，来决定是否准备 Liquibase 环境
# Liquibase 的运行需要 java 环境支持，指定的 connector jar 包
# 目前仅支持 Mysql 类型数据库的对接

function detectSqlControl() {
    local lang=$1
    schema_dir=${SCHEMA_DIR:-"Schema"}
    if [ -d $BUILD_DIR/${schema_dir} ]; then
        echo_title "Database schema version control dir ${schema_dir} has been found."
        echo_title "Preparing the version control tool"
        ([[ $1 != Java* ]] && [[ $1 != Gradle ]]) && getJavaRuntime
        getLiquibase
    fi
}

function getJavaRuntime() {
    OSS_URL=${LANG_GOODRAIN_ME:-"http://lang.goodrain.me"}
    if [ $ARCH == "x86_64" ]; then
        JRE_TAR_PATH="jdk/cedar-14/OpenJDK11U-jre_x86_64_linux.tar.gz"
    elif [ $ARCH == "arm64" ]; then
        JRE_TAR_PATH="jdk/cedar-14/arm64/OpenJDK11U-jre_aarch64_linux.tar.gz"
    fi
    JRE_URL=${OSS_URL}/${JRE_TAR_PATH}
    [ -z "$DEBUG_INFO" ] && echo "" || echo "For SQL version control.Download Jre from ${JRE_URL} "
    mkdir -p $BUILD_DIR/.jdk
    curl --retry 3 --silent --show-error ${JRE_URL} | tar xz --strip-components 1 -C $BUILD_DIR/.jdk
    export_env_global PATH $PATH:$BUILD_DIR/.jdk/bin
}

function getLiquibase() {
    OSS_URL=${LANG_GOODRAIN_ME:-"http://lang.goodrain.me"}
    LIQUI_VERSION=4.7.0
    LIUQI_URL=${OSS_URL}/common/utils/liquibase/liquibase-${LIQUI_VERSION}.tar.gz
    [ -z "$DEBUG_INFO" ] && echo "" || echo "For SQL version control.Download liquibase from ${LIUQI_URL} "
    mkdir -p $BUILD_DIR/.liquibase
    curl --retry 3 --silent --show-error ${LIUQI_URL} | tar xz -C $BUILD_DIR/.liquibase
    export_env_global PATH $PATH:$BUILD_DIR/.liquibase/bin
}
