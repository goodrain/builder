fetch_nginx_tarball() {
    local version="1.14.2"
    local nginx_tarball_url="http://lang.goodrain.me/static/r6d/nginx/nginx-${version}.tar.gz"
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
    
    if [ -f "www/web.conf" ]; then
        echo "-----> Detected custom configuration: web.conf"
        mv www/web.conf $NGINX_PATH/conf.d/
    else
        echo "-----> Use the default configuration: web.conf"
        cat > $NGINX_PATH/conf.d/web.conf <<EOF
server {
    listen       80;
    
    location / {
        root   /app/www;
        index  index.html index.htm;
    }
}
EOF
    fi

    cat >>boot.sh <<EOF
sed -i -r  "s/(listen ).*/\1\$PORT;/" /app/nginx/conf.d/web.conf
touch /app/nginx/logs/access.log
touch /app/nginx/logs/error.log
ln -sf /dev/stdout /app/nginx/logs/error.log
ln -sf /dev/stderr /app/nginx/logs/access.log
echo "Launching nginx"
exec /app/nginx/sbin/nginx -g 'daemon off;'
EOF
}

nodestatic_prepare(){
    local buildpath=$(read_json "$BUILD_DIR/nodestatic.json" ".path")
    mkdir -p /tmp/www/www /tmp/buildxxx
    echo "-----> Synchronous static resources."
    if [ -n "$buildpath" ]; then
        mv $buildpath/* /tmp/www/www/
    else
        if [ -d "dists" ]; then
            mv dists/* /tmp/www/www/
        fi
    fi
    mv nginx /tmp/www
    mv boot.sh /tmp/www
    mv /tmp/build/* /tmp/buildxxx
    mv /tmp/www/* /tmp/build
    if [ ! -f "/tmp/build/Procfile" ]; then
        cat > /tmp/build/Procfile <<EOF
web: sh boot.sh
EOF
    fi
}