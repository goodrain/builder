#!/bin/bash

slugignore::maven() {
    echo "*.java" > "${BUILD_DIR}/.slugignore"
    echo_title ".slugignore config success"
}

slugignore::golang() {
    echo "*.go" > "${BUILD_DIR}/.slugignore"
    echo_title ".slugignore config success"
}


initSlugIgnore(){
  local lang=`echo $1| tr A-Z a-z`
  if [ -f "${BUILD_DIR}/.slugignore" ];then
    echo_title ".slugignore be configured by user"
    return
  fi
  case $lang in
    java-maven)
      slugignore::maven
    ;;
    go|golang)
      slugignore::golang
    ;;
    *)
      :
    ;;
  esac
}