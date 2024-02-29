#!/bin/bash
fetch_nginx_tarball() {
    # for arm64 and amd64
    if [ $ARCH == "arm64" ]; then
        local version="1.22.1-arm-ubuntu-22.04.2"
    else
        #local version="1.14.2"
        local version="1.22.1-x86-64-ubuntu-22.04.2" # update nginx version
    fi
    local nginx_tarball_url="${LANG_GOODRAIN_ME:-http://lang.goodrain.me}/static/r6d/nginx/nginx-${version}.tar.gz"
    local NGINX_PATH="nginx"
    local BP_DIR=$1
    # install nginx if needed
    if [ ! -d "$NGINX_PATH" ]; then
        echo "-----> Installed Nginx ${version}"
        mkdir -p $NGINX_PATH/conf.d
        curl --silent --max-time 60 --location $nginx_tarball_url | tar xz --strip-components 2 -C $NGINX_PATH
    fi

    # update config files
    cp -a $BP_DIR/conf/nginx.conf $NGINX_PATH/conf/nginx.conf
    # add envrender script
    cp -a $BP_DIR/bin/envrender $NGINX_PATH/sbin/envrender
    if [ -f "nginx.conf" ]; then
        echo "-----> Detected custom nginx configuration: nginx.conf"
        mv nginx.conf $NGINX_PATH/conf.d/
    fi
    if [ -f "web.conf" ]; then
        echo "-----> Detected custom web configuration: web.conf"
        mv web.conf $NGINX_PATH/conf.d/
    elif [ -f "www/web.conf" ]; then
        echo "-----> Detected custom web configuration: www/web.conf"
        mv www/web.conf $NGINX_PATH/conf.d/
    else
        echo "-----> Use the default configuration: web.conf"
        cat >$NGINX_PATH/conf.d/web.conf <<EOF
server {
    listen       80;
    
    location / {
        root   /app/www;
        index  index.html index.htm;
    }
}
EOF
    fi

    cat >boot.sh <<EOF
#/bin/bash
# Linux OS always have sed cmd, but not envsubst for envrender
# Make conf files always can be render
sed -i -r "s#\/app#\$HOME#g" \$HOME/nginx/conf/nginx.conf
sed -i -r "s#\/app#\$HOME#g" \$HOME/nginx/conf.d/web.conf
sed -i -r  "s/(listen ).*/\1\$PORT;/" \$HOME/nginx/conf.d/web.conf
\$HOME/nginx/sbin/envrender \$HOME/nginx/conf.d/web.conf
touch \$HOME/nginx/logs/access.log
touch \$HOME/nginx/logs/error.log
ln -sf /dev/stdout \$HOME/nginx/logs/error.log
ln -sf /dev/stderr \$HOME/nginx/logs/access.log
echo "Launching nginx"
exec \$HOME/nginx/sbin/nginx -g "daemon off;user \$(whoami);" -c \$HOME/nginx/conf/nginx.conf
EOF
}

nodestatic_prepare() {
    local buildpath=$(read_json "$BUILD_DIR/nodestatic.json" ".path")
    # ADD ENV ROOT_PATH,User could define /path by it.
    mkdir -p /tmp/www/www/${ROOT_PATH} /tmp/buildxxx
    echo "-----> Synchronous static resources."
    if [ -n "$buildpath" ]; then
        mv $buildpath/* /tmp/www/www/${ROOT_PATH}
    else
        if [ -d "dists" ]; then
            mv dists/* /tmp/www/www/${ROOT_PATH}
        fi
    fi
    count=$(ls /tmp/www/www/ | wc -w)
    if [ "$count" == 0 ]; then
        error "No static file was generated. Check that the compilation process is correct."
        exit 1
    fi
    mv nginx /tmp/www
    mv boot.sh /tmp/www
    # mv /tmp/build/* /tmp/buildxxx
    mv /tmp/www/* /tmp/build
    if [ ! -f "/tmp/build/Procfile" ]; then
        cat >/tmp/build/Procfile <<EOF
web: bash boot.sh
EOF
    fi
}
