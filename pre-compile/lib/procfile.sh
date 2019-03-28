# save procfile information

# web页面无法定义启动命令的语言，先查看是否有Procfile，如果没有再处理，否则忽略处理
# web页面可以定义启动命令的语言，先查看接口返回值是否为空，如果为空代表之前探测出用户已经定义Procfile，不处理，否则处理

is_spring_boot() {
  local buildDir=${1}
  test -f ${buildDir}/pom.xml &&
  test -n "$(grep "<groupId>org.springframework.boot" ${buildDir}/pom.xml)" &&
  test -n "$(grep "<artifactId>spring-boot" ${buildDir}/pom.xml)" &&
  test ! -n "$(grep "<packaging>war</packaging>" ${buildDir}/pom.xml)"
}

is_wildfly_swarm() {
  local buildDir=${1}
  test -f ${buildDir}/pom.xml &&
    test -n "$(grep "<groupId>org.wildfly.swarm" ${buildDir}/pom.xml)"
}
iswar() {
  local buildDir=${1}
  test -n "$(grep "<packaging>war</packaging>" ${buildDir}/pom.xml)"
}

procfile::jar(){
  local procfile="$1"
  if [ -z "$procfile" ]; then
    if [ ! -f "$BUILD_DIR/Procfile" ]; then
      echo_title "Use Rainbond Default Java-jar Procfile"
      echo "web: java \$JAVA_OPTS -jar ./*.jar" > $BUILD_DIR/Procfile
    fi
  else
      echo_title "Use custom Java-jar Procfile"
      echo "$procfile" > $BUILD_DIR/Procfile
  fi
}

procfile::war_web(){
  case $RUNTIMES_SERVER in
      tomcat7)
            echo_title "Use custom Java-war Webserver Webapp-Runner 7.0"
            echo "webapp-runner-7.0.57.2.jar" > $BUILD_DIR/webserver
      ;;
      tomcat8)
            echo_title "Use custom Java-war Webserver Webapp-Runner 8.0"
            echo "webapp-runner-8.0.18.0-M1.jar" > $BUILD_DIR/webserver
      ;;
      tomcat85)
            echo_title "Use custom Java-war Webserver Webapp-Runner 8.5"
            echo "webapp-runner-8.5.38.0.jar" > $BUILD_DIR/webserver
      ;;
      tomcat9)
            echo_title "Use custom Java-war Webserver Webapp-Runner 9.0"
            echo "webapp-runner-9.0.16.0.jar" > $BUILD_DIR/webserver
      ;;
      jetty7)
            echo_title "Use custom Java-war Webserver Jetty7"
            echo "jetty-runner-7.5.4.v20111024.jar" > $BUILD_DIR/webserver
      ;;
      jetty9)
            echo_title "Use custom Java-war Webserver Jetty9"
            echo "jetty-runner-9.4.0.v20161208.jar" > $BUILD_DIR/webserver
      ;;
      *)
        if [ ! -f "$BUILD_DIR/webserver" ]; then
            echo "webapp-runner-8.5.38.0.jar" > $BUILD_DIR/webserver
        fi
            echo_title "Use Default Java-war Webserver"
      ;;
      esac
}

procfile::war(){
  local procfile="$1"
  if [ -z "$procfile" ]; then
    if [ ! -f "$BUILD_DIR/Procfile" ]; then
      case $RUNTIMES_SERVER in
        tomcat7)
          echo_title "Use Default Java-War Webserver Webapp-Runner 7.0"
          echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT ./*.war" > $BUILD_DIR/Procfile
        ;;
        tomcat8)
          echo_title "Use Default Java-War Webserver Webapp-Runner 8.0"
          echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT ./*.war" > $BUILD_DIR/Procfile
        ;;
        tomcat85)
          echo_title "Use Default Java-War Webserver Webapp-Runner 8.5"
          echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT ./*.war" > $BUILD_DIR/Procfile
        ;;
        tomcat9)
          echo_title "Use Default Java-War Webserver Webapp-Runner 9.0"
          echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT ./*.war" > $BUILD_DIR/Procfile
        ;;
        jetty7)
          echo_title "Use Default Java-War Webserver Jetty7"
          echo "web: java \$JAVA_OPTS -jar ./jetty-runner.jar  --port \$PORT ./*.war" > $BUILD_DIR/Procfile
        ;;
        jetty9)
          echo_title "Use Default Java-War Webserver Jetty9"
          echo "web: java \$JAVA_OPTS -jar ./jetty-runner.jar  --port \$PORT ./*.war" > $BUILD_DIR/Procfile
        ;;
        *)
          echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT ./*.war" > $BUILD_DIR/Procfile
          echo_title "Use Default Java-War Webserver"
        ;;
        esac
    fi
  else
      echo_title "Use custom Java-war Procfile"
      echo "$procfile" > $BUILD_DIR/Procfile
  fi
  
  procfile::war_web $RUNTIMES_SERVER

}

procfile::maven(){
  local procfile="$1"
  if [ -z "$procfile" ]; then
    if [ ! -f "$BUILD_DIR/Procfile" ]; then
      echo_title "Use Rainbond Default Java-Maven Procfile"
      if iswar $BUILD_DIR;then
          echo "war" > $BUILD_DIR/.iswar
          case $RUNTIMES_SERVER in
              tomcat7)
                echo_title "Use custom Java-Maven Webserver Webapp-Runner 7.0"
                echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT target/*.war" > $BUILD_DIR/Procfile
                echo "webapp-runner-7.0.57.2.jar" > $BUILD_DIR/webserver
              ;;
              tomcat8)
                echo_title "Use custom Java-Maven Webserver Webapp-Runner 8.0"
                echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT target/*.war" > $BUILD_DIR/Procfile
                echo "webapp-runner-8.0.18.0-M1.jar" > $BUILD_DIR/webserver
              ;;
              tomcat85)
                echo_title "Use custom Java-Maven Webserver Webapp-Runner 8.5"
                echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT target/*.war" > $BUILD_DIR/Procfile
                echo "webapp-runner-8.5.38.0.jar" > $BUILD_DIR/webserver
              ;;
              tomcat9)
                echo_title "Use custom Java-Maven Webserver Webapp-Runner 9.0"
                echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT target/*.war" > $BUILD_DIR/Procfile
                echo "webapp-runner-9.0.16.0.jar" > $BUILD_DIR/webserver
              ;;
              jetty7)
                echo_title "Use custom Java-Maven Webserver Jetty7"
                echo "web: java \$JAVA_OPTS -jar ./jetty-runner.jar  --port \$PORT target/*.war" > $BUILD_DIR/Procfile
                echo "jetty-runner-7.5.4.v20111024.jar" > $BUILD_DIR/webserver
              ;;
              jetty9)
                echo_title "Use custom Java-Maven Webserver Jetty9"
                echo "web: java \$JAVA_OPTS -jar ./jetty-runner.jar  --port \$PORT target/*.war" > $BUILD_DIR/Procfile
                echo "jetty-runner-9.4.0.v20161208.jar" > $BUILD_DIR/webserver
              ;;
              *)
                if [ ! -f "$BUILD_DIR/webserver" ]; then
                  echo "webapp-runner-8.5.38.0.jar" > $BUILD_DIR/webserver
                fi
                echo "web: java \$JAVA_OPTS -jar ./webapp-runner.jar  --port \$PORT target/*.war" > $BUILD_DIR/Procfile
                echo_title "Use Default Java-Maven Webserver"
              ;;
            esac
      elif is_spring_boot $BUILD_DIR; then
          echo "web: java -Dserver.port=\$PORT \$JAVA_OPTS -jar target/*.jar" > $BUILD_DIR/Procfile
      elif is_wildfly_swarm $BUILD_DIR; then
          echo "web: java -Dswarm.http.port=\$PORT \$JAVA_OPTS -jar target/*.jar" > $BUILD_DIR/Procfile  
      fi
    fi
  else
      echo_title "Use custom Java-Maven Procfile"
      echo "$procfile" > $BUILD_DIR/Procfile
  fi
}

procfile::php(){
  local procfile="$1"
  if [ -z "$procfile" ]; then
      echo_title "Use Rainbond Default PHP Procfile($RUNTIMES_SERVER)"
      case $RUNTIMES_SERVER in
        nginx)
          echo "web: vendor/bin/heroku-php-nginx" > $BUILD_DIR/Procfile
        ;;
        *)
          echo "web: vendor/bin/heroku-php-apache2" > $BUILD_DIR/Procfile
        ;;
      esac
  else
      echo_title "Use custom PHP Procfile"
      echo "$procfile" > $BUILD_DIR/Procfile
  fi
}

procfile::python(){
  local procfile="$1"
  if [ -z "$procfile" ]; then
    if [ ! -f "$BUILD_DIR/Procfile" ]; then
      # 查找django配置文件
      managefile=`find $BUILD_DIR -maxdepth 3 -type f -name 'manage.py' -printf '%d\t%P\n' | sort -nk1 | cut -f2 | head -1`
      if [ -f $BUILD_DIR/$managefile ];then
        modulename=`grep -o -E "\w+.settings" $BUILD_DIR/$managefile  | sed 's/.settings/.wsgi/'`
      else
        # 非django项目，查看是否为flask项目
        filelist=`find $BUILD_DIR -maxdepth 1 -type f -name '*.py' -printf '%d\t%P\n' | sort -nk1 | cut -f2`
        if [ "$filelist" != "" ];then
          for f in $filelist
          do
            module=`grep "Flask(__name__)"  ${BUILD_DIR}/$f  | awk -F '=' '{print $1}'`
            if [ "$module" != "" ];then
              file=`echo $f | sed 's/.py//'`
              modulename=${file}:${module} # 找到flask模块名
              break
            else
              continue
            fi
          done
        fi
      fi
      if [ "$modulename" == "" ];then
        : # 暂时不做任何修改
        echo "not django and flask project"
      else
        echo "web: gunicorn $modulename --max-requests=5000 --workers=4 --log-file - --access-logfile - --error-logfile -" > $BUILD_DIR/Procfile
      fi
    fi
  else
      echo_title "Use custom Python Procfile"
      echo "$procfile" > $BUILD_DIR/Procfile
  fi
}

procfile::nodejs(){
  local procfile="$1"
  if [ -z "$procfile" ]; then
    if [ ! -f "$BUILD_DIR/Procfile" ]; then
      echo_title "Use Rainbond Default NodeJS Procfile"
      default_procfile=`$JQBIN --raw-output ".scripts.start // \"\"" $BUILD_DIR/package.json`
      echo "web: $default_procfile" >$BUILD_DIR/Procfile
    fi
  else
      echo_title "Use custom NodeJS Procfile"
      echo "$procfile" > $BUILD_DIR/Procfile
  fi
}

procfile::golang(){
  local procfile="$1"
  if [ ! -z "$procfile" ]; then
      echo_title "Use custom Golang Procfile"
      echo "$procfile" > $BUILD_DIR/Procfile
  fi
}

R6D_Procfile(){
  local lang=`echo $1| tr A-Z a-z`
  local procfile="$2"
  case $lang in
    java-jar)
      procfile::jar "$procfile"
    ;;
    java-war)
      procfile::war "$procfile"
    ;;
    java-maven)
      procfile::maven "$procfile"
    ;;
    php)
      procfile::php "$procfile"
    ;;
    python)
      procfile::python "$procfile"
    ;;
    node.js)
      procfile::nodejs "$procfile"
    ;;
    go|golang)
      procfile::golang "$procfile"
    ;;
    static|nodejsstatic)
    : 
    ;;
    *)
      :
    ;;
  esac
}