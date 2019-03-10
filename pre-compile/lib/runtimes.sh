# save runtimes information

# $1 language
# $2 runtimes 
function Save_Runtimes(){
  lang=`echo $1| tr A-Z a-z`
  runtime=$2

  case $lang in
  php)
   : # 与依赖一起处理 
  ;;
  python)
    if [[ ! -f ${BUILD_DIR}/$PythonRuntimefile && $runtime != "" ]];then
      echo "python-$runtime" > ${BUILD_DIR}/$PythonRuntimefile
    fi
  ;;
  ruby)
    : # 目前不做处理
  ;;
  java-war|java-maven)
    if [[ ! -f ${BUILD_DIR}/$JAVARuntimefile && $runtime != "" ]];then
      if [ -f $BUILD_DIR/pom.xml ]; then
        set +e
        java_version=$(grep -oE '<java.version>[0-9.]+</java.version>' ${BUILD_DIR}/pom.xml | tail -n 1 | awk -F '[<>]' '{print $3}')
        set -e
        [ "x$java_version" == "x" ] && java_version="1.8"
        echo "java.runtime.version=$java_version" > ${BUILD_DIR}/$JAVARuntimefile
      
        if [ "$java_version" == "1.6" ] || [ "$java_version" == "1.5" ]; then
          echo "maven.version=3.2.5" >> ${BUILD_DIR}/$JAVARuntimefile
        else
          echo "maven.version=3.3.9" >> ${BUILD_DIR}/$JAVARuntimefile
        fi
      fi
    fi
  ;;
  go|golang)
    if [[ ! -f ${BUILD_DIR}/$GolangRuntimefile && $runtime != "" ]];then
      echo "go$runtime" > ${BUILD_DIR}/$GolangRuntimefile
    fi
  ;;
  node.js)
    : # 目前不做处理
  ;;
  static)
    : # 目前不做处理
  ;;
  *)
    :
  ;;
  esac
}



runtimes::jar(){
  # 指定JDK版本
  local runtime=${1}
  if [ -z "$runtime" ]; then
      if [ ! -f "${BUILD_DIR}/$JAVARuntimefile" ];then
          echo "java.runtime.version=1.8" > ${BUILD_DIR}/$JAVARuntimefile
      fi
  else
    echo "java.runtime.version=$runtime" > ${BUILD_DIR}/$JAVARuntimefile
  fi
  echo_title "Detection Java-jar runtime $(cat ${BUILD_DIR}/$JAVARuntimefile)"
}

runtimes::war(){
  # 指定JDK版本
  local runtime=${1}
  if [ -z "$runtime" ]; then
      if [ ! -f "${BUILD_DIR}/$JAVARuntimefile" ];then
          echo "java.runtime.version=1.8" > ${BUILD_DIR}/$JAVARuntimefile
      fi
  else
    echo "java.runtime.version=$runtime" > ${BUILD_DIR}/$JAVARuntimefile
  fi
  echo_title "Detection Java-War runtime $(cat ${BUILD_DIR}/$JAVARuntimefile)"
}

runtimes::gradle(){
  # 指定JDK版本
  local runtime=${1}
  if [ -z "$runtime" ]; then
      if [ ! -f "${BUILD_DIR}/$JAVARuntimefile" ];then
          echo "java.runtime.version=1.8" > ${BUILD_DIR}/$JAVARuntimefile
      fi
  else
    echo "java.runtime.version=$runtime" > ${BUILD_DIR}/$JAVARuntimefile
  fi
  echo_title "Detection Java-Gradle runtime $(cat ${BUILD_DIR}/$JAVARuntimefile)"
}

runtimes::maven(){
  local runtime=${1}
  local maven=${RUNTIMES_MAVEN:-3.3.9}
  if [ -z "$runtime" ]; then
      if [ ! -f "${BUILD_DIR}/$JAVARuntimefile" ];then
          echo "java.runtime.version=1.8" > ${BUILD_DIR}/$JAVARuntimefile
      fi
  else
    echo "java.runtime.version=$runtime" > ${BUILD_DIR}/$JAVARuntimefile
  fi
  echo_title "Detection Java-Maven runtime $(cat ${BUILD_DIR}/$JAVARuntimefile)"
  if [ "$runtime" == "1.6" ] || [ "$runtime" == "1.5" ]; then
    echo_title "Detection old Java($runtime), Java-Maven runtime ${runtime}"
    echo "maven.version=3.2.5" >> ${BUILD_DIR}/$JAVARuntimefile
  else
    echo "maven.version=${maven}" >> ${BUILD_DIR}/$JAVARuntimefile
  fi
}

runtimes::php(){
  local runtime=${1:-5.6.35}
  local hhvm=${RUNTIMES_HHVM}
  if [ ! -z "$runtime" ]; then
    echo_title "Detection PHP runtime php-${runtime}"
    case $runtime in
      5.5|5.5.38)
        echo "php-5.5.38" > ${BUILD_DIR}/$PHPRuntimefile
      ;;
      7.0|7.0.29)
        echo "php-7.0.29" > ${BUILD_DIR}/$PHPRuntimefile
      ;;
      7.1|7.1.16)
        echo "php-7.1.16" > ${BUILD_DIR}/$PHPRuntimefile
      ;;
      *)
        echo "php-5.6.35" > ${BUILD_DIR}/$PHPRuntimefile
      ;;
    esac
  fi
  if [ ! -z "$hhvm" ]; then
    echo_title "Detection PHP runtime hhvm-${hhvm}"
    echo "hhvm-3.5.1" >> ${BUILD_DIR}/$PHPRuntimefile
  fi
}

runtimes::python(){
  local runtime=${1:-python-3.6.6}
  if [ ! -z "$runtime" ]; then
    echo_title "Detection Python runtime ${runtime}"
    echo "$runtime" > ${BUILD_DIR}/$PythonRuntimefile
  else
    if [ ! -f "${BUILD_DIR}/$PythonRuntimefile" ]; then
      echo "$runtime" > ${BUILD_DIR}/$PythonRuntimefile
    fi
    echo_title "Detection Python default runtime ${runtime}"
  fi
}

runtimes::nodejs(){
  local runtime=${1}
  if [ ! -z "$runtime" ]; then
    echo_title "Detection NodeJS runtime ${runtime}"
    old_runtime_version=$(cat ${BUILD_DIR}/$NodejsRuntimefile | grep "\"node\"" | awk '{print $2}')
    sed -i "s#${old_runtime_version}#\"${runtime}\"#g" ${BUILD_DIR}/$NodejsRuntimefile
    echo "$runtime" > ${BUILD_DIR}/runtime.txt
  fi
}

runtimes::golang(){
  local runtime=${1}
  if [ ! -z "$runtime" ]; then
    echo_title "Detection Golang runtime ${runtime}"
    echo "go$runtime" > ${BUILD_DIR}/$GolangRuntimefile
  else
    if [ ! -f "${BUILD_DIR}/$GolangRuntimefile" ]; then
      echo "go1.11.2" > ${BUILD_DIR}/$GolangRuntimefile
    fi
    echo_title "Detection Golang default runtime $(cat ${BUILD_DIR}/$GolangRuntimefile)"
  fi
}

runtimes::static(){
  local runtime=${1}
  local RUNTIMES_SERVER=${RUNTIMES_SERVER:-nginx}
  echo_title "Detection Static runtime server ${RUNTIMES_SERVER}"
  case $RUNTIMES_SERVER in
    apache)
      echo "apache" > ${BUILD_DIR}/$StaticRuntimefile
    ;;
    *)
      echo "nginx" > ${BUILD_DIR}/$StaticRuntimefile
    ;;
  esac
}

R6D_Runtimes(){
  local lang=`echo $1| tr A-Z a-z`
  local runtime=$2
  case $lang in
    java-jar)
      runtimes::jar $runtime
    ;;
    java-war)
      runtimes::war $runtime
    ;;
    java-maven)
      runtimes::maven $runtime
    ;;
    php)
      runtimes::php $runtime
    ;;
    python)
      runtimes::python $runtime #目前不由预编译处理，由buildpack处理
    ;;
    node.js|nodejsstatic)
      runtimes::nodejs $runtime
    ;;
    go|golang)
      runtimes::golang $runtime
    ;;
    static)
      runtimes::static $runtime
    ;;
    gradle)
      runtimes::gradle $runtime
    ;;
    *)
      :
    ;;
  esac
}