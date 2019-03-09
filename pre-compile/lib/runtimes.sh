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

runtimes::python(){
  # 指定Python版本
  local runtime=$1
  if [ -z "$runtime" ]; then
      # Todo check python-$runtime
      echo ""
  else
      echo_title "Rewrite python runtime: python-${runtime}"
      echo "python-$runtime" > ${BUILD_DIR}/$PythonRuntimefile
  fi
}

runtimes::jar(){
  # 指定JDK版本
  local runtime=${1:-1.8}
  echo_title "Detection Java-jar runtime ${runtime}"
  echo "java.runtime.version=$runtime" > ${BUILD_DIR}/$JAVARuntimefile
}

runtimes::war(){
  # 指定JDK版本
  local runtime=${1:-1.8}
  echo_title "Detection Java-war runtime ${runtime}"
  echo "java.runtime.version=$runtime" > ${BUILD_DIR}/$JAVARuntimefile
}

runtimes::maven(){
  local runtime=${1:-1.8}
  local maven=${RUNTIMES_MAVEN:-3.3.9}
  echo_title "Detection Java-Maven runtime ${runtime}"
  echo "java.runtime.version=$runtime" > ${BUILD_DIR}/$JAVARuntimefile
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
    runtimes::python $runtime
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