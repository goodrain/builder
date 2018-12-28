# save runtimes information

# $1 language
# $2 runtimes 
function Save_Runtimes(){
  lang=`echo $1| tr A-Z a-z`
  runtime=$2

  case $lang in
  php)
    if [[ $runtime != "" ]];then
      sed -i "s#\(\"php\": \"\).*\(\"\)#\1$runtime\2#" ${BUILD_DIR}/composer.lock 
    fi
  ;;
  python)
    if [[ $runtime != "" ]];then
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
    if [[ $runtime != "" ]];then
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
