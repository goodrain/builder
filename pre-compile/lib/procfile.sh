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

# $1 language
function Save_Procfile(){
  lang=`echo $1| tr A-Z a-z`
  procfile=$2

  case $lang in
  php)
    if [ ! -f $BUILD_DIR/Procfile  ];then
      case $procfile in
      apache)
        echo "web: vendor/bin/heroku-php-apache2" > $BUILD_DIR/Procfile
      ;;
      nginx)
        echo "web: vendor/bin/heroku-php-nginx" > $BUILD_DIR/Procfile
      ;;
      *)
        : # 用户已经定义，不做任何修改
      ;;
      esac
    fi
  ;;
  python)
    if [ ! -f $BUILD_DIR/Procfile  ];then
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
  ;;
  ruby)
#    if [ ! -f $BUILD_DIR/Procfile  ];then
#      railsversion=`grep -E -i "\ *gem\ *'rails'" $BUILD_DIR/Gemfile  | grep -E -o '[0-9]+(.[0-9]+)?(.[0-9]+)?'|awk -F '.' '{print $1}'`
#      cp ./conf/rails${railsversion}.ru $BUILD_DIR/puma.ru
#      echo "web: bundle exec puma -C puma.rb" > $BUILD_DIR/Procfile
#    fi
    : # 暂时不做处理
  ;;
  java-war)
    # java-war的Procfile由buildpack处理
    case $procfile in
    tomcat7)
      echo "webapp-runner-7.0.57.2.jar" > $BUILD_DIR/webserver
    ;;
    tomcat8)
      echo "webapp-runner-8.0.18.0-M1.jar" >$BUILD_DIR/webserver
    ;;
    jetty7)
      echo "jetty-runner-7.5.4.v20111024.jar" > $BUILD_DIR/webserver
    ;;
    esac
  ;;
   java-maven)
    if [ ! -f $BUILD_DIR/Procfile ] ; then
      tomcat=`grep webapp-runner $BUILD_DIR/pom.xml`
      jetty=`grep jetty-runner $BUILD_DIR/pom.xml`
      if [ "$tomcat" ];then
        echo "web: java \$JAVA_OPTS -jar target/dependency/webapp-runner.jar   --port \$PORT target/*.war" > $BUILD_DIR/Procfile
      fi
      
      if [ "$jetty" ];then
        echo "web: java \$JAVA_OPTS -jar target/dependency/jetty-runner.jar --port \$PORT target/*.war" > $BUILD_DIR/Procfile
      fi
      
      cd $BUILD_DIR
      
      if is_spring_boot $BUILD_DIR; then
        echo "web: java -Dserver.port=\$PORT \$JAVA_OPTS -jar target/*.jar" > $BUILD_DIR/Procfile
      elif is_wildfly_swarm $BUILD_DIR; then
        echo "web: java -Dswarm.http.port=\$PORT \$JAVA_OPTS -jar target/*.jar" > $BUILD_DIR/Procfile
      fi
    fi
     
  ;;
  node.js)
    if [ ! -f $BUILD_DIR/Procfile ];then
      if [ "$procfile" == "" ];then
        procfile=`$JQBIN --raw-output ".scripts.start // \"\"" $BUILD_DIR/package.json`
      fi
      echo "web: $procfile" >$BUILD_DIR/Procfile
    fi
  ;;
  static)
   : # 目前不做处理
  ;;
  *)
    :
  ;;
  esac
}
