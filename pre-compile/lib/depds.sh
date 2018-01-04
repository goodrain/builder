# save dependencies/Extensions 

# $1 language
# $2 deps
function Save_Deps(){
  lang=`echo $1 | tr A-Z a-z`
  deps=$2

  case $lang in
  php)
    if [ ! -f ${BUILD_DIR}/${PHPfile} ];then
      runtime=`read_json '.runtimes'`

      if [ "$runtime" != "" ] ;then
        if [ "$deps" != "{}" ];then
           newdeps=`echo $deps | sed 's/^{/,/'`
           echo "{\"require\":{\"php\":\"${runtime}\"$newdeps}" | $JQBIN . > ${BUILD_DIR}/${PHPfile}
        else
           newdeps=`echo $deps | sed 's/{}/}/'`
           echo "{\"require\":{\"php\":\"${runtime}\"$newdeps}" | $JQBIN . > ${BUILD_DIR}/${PHPfile}
        fi
      else
        if [ "$deps" != "{}" ];then
            newdeps=`echo $deps | sed 's/^{/,/'`
            echo "{\"require\":{\"php\":${PHPDefault}$newdeps}" | $JQBIN . > ${BUILD_DIR}/${PHPfile}
        fi
      fi
    fi
  ;;
  python)
    #[ -f ${BUILD_DIR}/${Pythondeps} ] && hasGunicorn=`grep -i gunicorn ${BUILD_DIR}/${Pythondeps}`
    #if [ "$hasGunicorn" == "" ];then
    #  echo "gunicorn==19.3.0" >> ${BUILD_DIR}/${Pythondeps}
    #fi
  ;;
  ruby)
#    [ -f ${BUILD_DIR}/${Rubydeps} ] && hasPuma=`grep -i puma ${BUILD_DIR}/${Rubydeps}`
#    if [ "$hasPuma" == "" ];then
#      echo "gem 'puma'" >> ${BUILD_DIR}/${Rubydeps}
#      sed -i 's#https://rubygems.org#http://ruby.taobo.org/#' ${BUILD_DIR}/${Rubydeps}
#    fi
    : # 暂时不做处理
  ;;
  java-war|java-maven)
    : # 目前不做处理
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
