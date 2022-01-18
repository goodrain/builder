#!/bin/bash
# 利用 Liquibase 进行数据库表结构的管理
# 通过检测源码目录下指定文件夹下的 changelog 文件，来决定是否准备 Liquibase 环境
# Liquibase 的运行需要 java 环境支持，指定的 connector jar 包
# 目前仅支持 Mysql 类型数据库的对接

function detectSqlControl() {
    local lang=$1
    CHANGE_LOG_FILE=${CHANGE_LOG_FILE:-"rainsql/changelog.sql"}
    if [ -f $BUILD_DIR/${CHANGE_LOG_FILE} ]; then
        echo_title "Database version control file ${CHANGE_LOG_FILE} has been found.Preparing the version control tool"
        ([[ $1 != Java* ]] && [[ $1 != Gradle ]]) && getJavaRuntime
        getLiquibase
    fi
}

function dealWithConfig() {
    # Checks whether a configuration file exists named liquibase.properties
    # add config liquibase.hub.mode=off to liquibase.properties
    # to skip login liquibase hub cloud service
    LIQUIBASE_CONFIG_FILE=${LIQUIBASE_CONFIG_FILE:-"rainsql/liquibase.properties"}
    if [ -f $BUILD_DIR/${LIQUIBASE_CONFIG_FILE} ]; then
        echo_title "Useing custom liquibase config file ${LIQUIBASE_CONFIG_FILE}"
        # Just skip login liquibase hub cloud service
        if ! (grep "liquibase.hub.mode*" ${LIQUIBASE_CONFIG_FILE} >/dev/null); then
            echo "liquibase.hub.mode=off" >>${LIQUIBASE_CONFIG_FILE}
        fi
    else
        echo_title "Generating default liquibase config file ${LIQUIBASE_CONFIG_FILE}"
        # Currently only for mysql
        # The generated template configuration is rendered in runner
        cat > $BUILD_DIR/${LIQUIBASE_CONFIG_FILE} <<EOF
driver: com.mysql.cj.jdbc.Driver
url:jdbc:mysql://__MYSQL_HOST__:__MYSQL_PORT__/__MYSQL_DATABASE__
username: __MYSQL_USER__
password: __MYSQL_PASSWORD__
changeLogFile: changelog.sql
liquibase.hub.mode=off
EOF
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

function dealWithMysql() {
    # Both in builder and runner
    # Liquibase will get envriment variables and config Mysql connection
    # Env config will be overwrote by config file liquibase.properties
    # Env will not be used in liquibase opensource version
    # So we will not use this function too
    export_env_global LIQUIBASE_DRIVER 'com.mysql.cj.jdbc.Driver'
    export_env_global LIQUIBASE_COMMAND_USERNAME '${MYSQL_USER}'
    export_env_global LIQUIBASE_COMMAND_PASSWORD '${MYSQL_PASSWORD}'
    export_env_global LIQUIBASE_COMMAND_URL 'jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}'
    export_env_global LIQUIBASE_COMMAND_CHANGELOG_FILE 'changelog.sql'
}

function getLiquibase() {
    OSS_URL=${LANG_GOODRAIN_ME:-"http://lang.goodrain.me"}
    LIQUI_VERSION=4.7.0
    LIUQI_URL=${OSS_URL}/common/utils/liquibase/liquibase-${LIQUI_VERSION}.tar.gz
    [ -z "$DEBUG_INFO" ] && echo "" || echo "For SQL version control.Download liquibase from ${LIUQI_URL} "
    mkdir -p $BUILD_DIR/.liquibase
    curl --retry 3 --silent --show-error ${LIUQI_URL} | tar xz -C $BUILD_DIR/.liquibase
    export_env_global PATH $PATH:$BUILD_DIR/.liquibase
    # deal with the config file
    dealWithConfig
}
