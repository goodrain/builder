# save runtimes information

# $1 language
# $2 runtimes 

runtimes::jar(){
  # 指定JDK版本
  local runtime=${1}
  if [ -z "$runtime" ]; then
      if [ ! -f "${BUILD_DIR}/$JAVARuntimefile" ];then
          echo "java.runtime.version=1.8" > ${BUILD_DIR}/$JAVARuntimefile
      fi
  else
    case $runtime in
        1.6)
          echo "java.runtime.version=1.6" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        1.7)
          echo "java.runtime.version=1.7" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        1.9)
          echo "java.runtime.version=1.9" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        10)
          echo "java.runtime.version=10" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        11)
          echo "java.runtime.version=11" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        12)
          echo "java.runtime.version=12" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        13)
          echo "java.runtime.version=13" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        *)
          echo "java.runtime.version=1.8" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
    esac
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
    case $runtime in
        1.6)
          echo "java.runtime.version=1.6" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        1.7)
          echo "java.runtime.version=1.7" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        1.9)
          echo "java.runtime.version=1.9" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        10)
          echo "java.runtime.version=10" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        11)
          echo "java.runtime.version=11" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        12)
          echo "java.runtime.version=12" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        13)
          echo "java.runtime.version=13" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        *)
          echo "java.runtime.version=1.8" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
    esac
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
    case $runtime in
        1.6)
          echo "java.runtime.version=1.6" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        1.7)
          echo "java.runtime.version=1.7" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        1.9)
          echo "java.runtime.version=1.9" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        10)
          echo "java.runtime.version=10" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        11)
          echo "java.runtime.version=11" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        12)
          echo "java.runtime.version=12" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        13)
          echo "java.runtime.version=13" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        *)
          echo "java.runtime.version=1.8" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
    esac
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
    case $runtime in
        1.6)
          echo "java.runtime.version=1.6" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        1.7)
          echo "java.runtime.version=1.7" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        1.9)
          echo "java.runtime.version=1.9" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        10)
          echo "java.runtime.version=10" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        11)
          echo "java.runtime.version=11" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        12)
          echo "java.runtime.version=12" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        13)
          echo "java.runtime.version=13" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
        *)
          echo "java.runtime.version=1.8" > ${BUILD_DIR}/$JAVARuntimefile
        ;;
    esac
  fi
  echo_title "Detection Java-Maven runtime $(cat ${BUILD_DIR}/$JAVARuntimefile | grep runtime)"
  if [ "$runtime" == "1.6" ] || [ "$runtime" == "1.5" ]; then
    echo_title "Detection old Java($runtime), Java-Maven runtime ${runtime}"
    echo "maven.version=3.2.5" >> ${BUILD_DIR}/$JAVARuntimefile
  else
    echo "maven.version=${maven}" >> ${BUILD_DIR}/$JAVARuntimefile
  fi
  echo_title "Detection Maven $(cat ${BUILD_DIR}/$JAVARuntimefile | grep maven)"
}

runtimes::php(){
  local runtime=${1}
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
      7.1.16)
        echo "php-7.1.16" > ${BUILD_DIR}/$PHPRuntimefile
      ;;
      7.1|7.1.33)
        echo "php-7.1.33" > ${BUILD_DIR}/$PHPRuntimefile
      ;;
      7.2|7.2.26)
        echo "php-7.2.26" > ${BUILD_DIR}/$PHPRuntimefile
      ;;
      7.3|7.3.13)
        echo "php-7.3.13" > ${BUILD_DIR}/$PHPRuntimefile
      ;;
      5.6|5.6.35)
        echo "php-5.6.35" > ${BUILD_DIR}/$PHPRuntimefile
      ;;
      *)
        #TODO
        # 暂时不处理
        #echo "php-5.6.35" > ${BUILD_DIR}/$PHPRuntimefile
        :
      ;;
    esac
  fi
  if [ ! -z "$hhvm" ]; then
    echo_title "Detection PHP runtime hhvm-${hhvm}"
    echo "hhvm-3.5.1" >> ${BUILD_DIR}/$PHPRuntimefile
  fi
}

runtimes::python(){
  local runtime=${1}
  if [ ! -z "$runtime" ]; then
    echo_title "Detection Python runtime ${runtime}"
    echo "$runtime" > ${BUILD_DIR}/$PythonRuntimefile
  else
    if [ ! -f "${BUILD_DIR}/$PythonRuntimefile" ]; then
      echo "python-3.6.10" > ${BUILD_DIR}/$PythonRuntimefile
    fi
    echo_title "Detection Python default runtime $(cat ${BUILD_DIR}/$PythonRuntimefile)"
  fi
}

runtimes::nodejs(){
  local runtime=${1}
  if [ ! -z "$runtime" ]; then
    echo_title "Detection NodeJS runtime ${runtime}"
    old_runtime_version=$(cat ${BUILD_DIR}/$NodejsRuntimefile | grep "\"node\"" | awk -F: '{print $2}')
    if [ -z "${old_runtime_version}" ];then
        sed -i "/\"version\":/a\  \"engines\": {\n\    \"node\": \"${runtime}\"\n\  }," ${BUILD_DIR}/$NodejsRuntimefile
    elif [ "${old_runtime_version}" == "," ];then
        sed -i "s#${old_runtime_version}#\"${runtime}\",#g" ${BUILD_DIR}/$NodejsRuntimefile
    else
        sed -i "s#${old_runtime_version}#\"${runtime}\"#g" ${BUILD_DIR}/$NodejsRuntimefile
    fi
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