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
      echo "java.runtime.version=$runtime" > ${BUILD_DIR}/$JAVARuntimefile
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
