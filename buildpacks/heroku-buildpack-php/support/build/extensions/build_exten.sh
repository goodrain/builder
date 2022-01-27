#!/bin/bash

# 编译构建环境要求具有 jq-1.5 和 ossutil 工具，配置好 ossutil 的密钥，使之可以操作对象存储。

# PHP 源码编译所需的各种包的地址，都在 packages.json 文件中描述，首先确定有多少个包
pkg_num=$(jq '.packages[0]|length' ../packages.json)

# 制作一个函数，专门用于上传对象存储
function upload() {
    local file=$1
    local path=$2
    local oss_endpoint=oss://buildpack
    ossutil cp --force $file $oss_endpoint/$path
}

# 扩展包需要 php 构建环境，官方提供的编译脚本，会在每次编译完成后删除 php 目录中的内容，所以每次新的编译都要重新解压php压缩包
# 编译构建环境在 /app/.heroku 目录下预先下载好 php-5.5.38.tar.gz  php-7.0.29.tar.gz  php-7.1.27.tar.gz  php-7.2.16.tar.gz
# raphf 扩展是 pg 扩展的依赖项，想要编译成功，需要先安装
function php_untar() {
    local phpver=$1
    case $phpver in
    5.5.*)
        phptar=php-5.5.38.tar.gz
        raphfurl=https://buildpack.oss-cn-shanghai.aliyuncs.com/php-arm64/dist-cedar-14-stable/extensions/no-debug-non-zts-20121212/raphf-1.1.2.tar.gz
        ;;
    5.6.*)
        phptar=php-5.6.35.tar.gz
        raphfurl=https://buildpack.oss-cn-shanghai.aliyuncs.com/php-arm64/dist-cedar-14-stable/extensions/no-debug-non-zts-20131226/raphf-1.1.2.tar.gz
        ;;
    7.0.*)
        phptar=php-7.0.29.tar.gz
        raphfurl=https://buildpack.oss-cn-shanghai.aliyuncs.com/php-arm64/dist-cedar-14-stable/extensions/no-debug-non-zts-20151012/raphf-2.0.0.tar.gz
        ;;
    7.1.*)
        phptar=php-7.1.27.tar.gz
        raphfurl=https://buildpack.oss-cn-shanghai.aliyuncs.com/php-arm64/dist-cedar-14-stable/extensions/no-debug-non-zts-20160303/raphf-2.0.0.tar.gz
        ;;
    7.2.*)
        phptar=php-7.2.16.tar.gz
        raphfurl=https://buildpack.oss-cn-shanghai.aliyuncs.com/php-arm64/dist-cedar-14-stable/extensions/no-debug-non-zts-20170718/raphf-2.0.0.tar.gz
        ;;
    esac
    if [ ! -d /app/.heroku/php ]; then
        mkdir -p /app/.heroku/php
    fi
    pushd /app/.heroku
    tar xzf $phptar -C php
    curl -L $raphfurl | tar xz -C php
    popd
}

# 编译脚本的名字，需要和包名一致，所以需要测试是否存在同名脚本，如没有，则基于已有的新复制一个
function ensure_script() {
    local script_name=$1
    local path=$2
    if [ ! -f $path/$script_name ]; then
        other_script=$(ls $path/${script_name%-**}-* | head -1)
        echo "==== There is no  $script_name,copy from $other_script ===="
        cp $other_script $path/$script_name
    fi
}

# 编译完成的结果，需要完成打包并上传的流程，完成上传后，需要把 php 目录内容删除，供下次编译
function pack_upload_clean() {
    local tarfile=$1
    local upload_path=$2
    pushd /app/.heroku/php
    tar czf $tarfile ./*
    upload $tarfile $upload_path
    rm -rf ./*
    popd
}

# ================== main ====================
# 主程序是一个循环，遍历 packages.json 中的包
# 拆解 json 文件中的扩展包信息，加以处理

for ((i = 13; i <= $pkg_num; i++)); do
    # Example:"http://lang.goodrain.me/php-arm64/dist-cedar-14-stable/extensions/no-debug-non-zts-20180731/apcu-5.1.10.tar.gz"
    pkg_url=$(jq ".packages[0][$i].dist.url" ../packages.json)

    # 如果发现 url 中不包含 extensions 字段，说明不是扩展，可以跳出当前循环，后续不作处理
    # memcached 扩展打包完成，不再处理

    if [[ $pkg_url != */extensions/* ]]; then
        continue
    fi
    # Example:apcu-5.1.10.tar.gz
    pkg_achive_name=$(echo ${pkg_url##*/} | sed 's/\"//')
    # Example:apcu-5.1.10
    pkg_name=${pkg_achive_name%.tar.gz*}
    # Example:no-debug-non-zts-20180731
    php_api_ver=$(echo ${pkg_url} | awk -F "/" '{print $7}')
    # Example:7.2.*
    php_ver=$(jq --argjson i $i '.packages[0][$i].require."heroku-sys/php"' ../packages.json | sed 's/\"//g')
    # if [[ $php_ver == 7.2.* ]]; then
    #     continue
    # fi

    # 准备 php 构建环境
    echo "========================================="
    echo "==== Prepare php envriment $php_ver ....."
    echo "========================================="
    php_untar $php_ver

    # 确认是否存在构建脚本，如没有，则复制一个
    ensure_script $pkg_name $php_api_ver || exit 1
    # 编译扩展
    echo "========================================="
    echo "==== Compile exten pkg  $pkg_name   ....."
    echo "========================================="
    WORKSPACE_DIR=$(pwd) \
    STACK=cedar-14 \
    S3_PREFIX=php-arm64/dist-cedar-14-stable/extensions/ \
        bash $php_api_ver/$pkg_name /app/.heroku/php
    if [ $? != 0 ]; then
        echo "$php_api_ver/$pkg_name" >>failure_pkg.list
        rm -rf /app/.heroku/php/*
        rm -rf $pkg_name
        continue
    fi
    # 清理编译用的源码目录，不清理可能引起在其他 php 版本下构建时遭遇 api 版本不符的问题
    rm -rf $pkg_name
    # 编译完成则打包上传压缩包和 composer.json 文件
    echo "================================================================"
    echo "==== Uploading $pkg_achive_name to /extensions/$php_api_ver/$pkg_achive_name"
    echo "==== Uploading ext-${pkg_name}_php-${php_ver%.**}.composer.json "
    echo "================================================================"
    upload ext-${pkg_name}_php-${php_ver%.**}.composer.json php-arm64/dist-cedar-14-stable/
    rm ext-${pkg_name}_php-${php_ver%.**}.composer.json
    pack_upload_clean $pkg_achive_name php-arm64/dist-cedar-14-stable/extensions/$php_api_ver/
done
