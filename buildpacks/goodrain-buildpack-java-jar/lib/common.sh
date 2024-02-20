#!/usr/bin/env bash

DEFAULT_MAVEN_VERSION="3.3.9"

export_env_dir() {
  env_dir=$1
  whitelist_regex=${2:-''}
  blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH|JAVA_OPTS)$'}
  if [ -d "$env_dir" ]; then
    for e in $(ls $env_dir); do
      echo "$e" | grep -E "$whitelist_regex" | grep -qvE "$blacklist_regex" &&
      export "$e=$(cat $env_dir/$e)"
      :
    done
  fi
}

install_maven() {
  local installDir=$1
  local buildDir=$2
  mavenHome=$installDir/.maven

  definedMavenVersion=$(detect_maven_version $buildDir)

  if is_maven_needed ${mavenHome} ${definedMavenVersion}; then
    mavenVersion=${definedMavenVersion:-$DEFAULT_MAVEN_VERSION}

    status_pending "Installing Maven ${mavenVersion}"
    if is_supported_maven_version ${mavenVersion}; then
      mavenUrl="http://lang.goodrain.me/jvm/maven-${mavenVersion}.tar.gz"
      if [ -n "${CUSTOMIZE_RUNTIMES_MAVEN}" ]; then
        mavenUrl=${CUSTOMIZE_RUNTIMES_MAVEN_URL}
      fi
      download_maven ${mavenUrl} ${installDir} ${mavenHome}
      status_done
    else
      error_return "Error, you have defined an unsupported Maven version in the system.properties file.
The list of known supported versions are 3.1.1, 3.2.5, 3.3.9, 3.5.4, 3.6.3, 3.8.8 and 3.9.1."
      return 1
    fi
  fi
}

download_maven() {
  local mavenUrl=$1
  local installDir=$2
  local mavenHome=$3
  rm -rf $mavenHome
  if [ -n "${CUSTOMIZE_RUNTIMES_MAVEN}" ]; then
    mkdir $installDir/.maven
    curl --silent --max-time 60 --location ${mavenUrl} | tar xzm --strip-components 1 -C $installDir/.maven
    echo "download the customized version package"
  else
    curl --silent --max-time 60 --location ${mavenUrl} | tar xzm -C $installDir
  fi
  chmod +x $mavenHome/bin/mvn
}

is_supported_maven_version() {
  local mavenVersion=${1}
  if [ "$mavenVersion" = "$DEFAULT_MAVEN_VERSION" ]; then
    return 0
  elif [ "$mavenVersion" = "3.1.1" ]; then
    return 0
  elif [ "$mavenVersion" = "3.2.5" ]; then
    return 0
  elif [ "$mavenVersion" = "3.3.9" ]; then
    return 0
  elif [ "$mavenVersion" = "3.5.4" ]; then
    return 0
  elif [ "$mavenVersion" = "3.6.3" ]; then
    return 0
  elif [ "$mavenVersion" = "3.8.8" ]; then
    return 0
  elif [ "$mavenVersion" = "3.9.1" ]; then
    return 0
  else
    return 0
  fi
}

is_maven_needed() {
  local mavenHome=${1}
  local newMavenVersion=${2}
  if [ -d $mavenHome ]; then
    if [ -z "$newMavenVersion" ]; then
      return 1
    else
      mavenVersionLine=$($mavenHome/bin/mvn -v | sed -E -e 's/[ \t\r\n]//g')
      mavenVersion=$(expr "$mavenVersionLine" : "ApacheMaven\(3\.[0-2]\.[0-9]\)")
      test "$mavenVersion" != "$newMavenVersion"
    fi
  else
    return 0
  fi
}

detect_maven_version() {
  local baseDir=${1}
  if [ -f ${baseDir}/system.properties ]; then
    mavenVersion=$(get_app_system_value ${baseDir}/system.properties "maven.version")
    if [ -n "$mavenVersion" ]; then
      echo $mavenVersion
    else
      echo ""
    fi
  else
    echo ""
  fi
}

get_app_system_value() {
  local file=${1?"No file specified"}
  local key=${2?"No key specified"}

  # escape for regex
  local escaped_key=$(echo $key | sed "s/\./\\\./g")

  [ -f $file ] && \
  grep -E ^$escaped_key[[:space:]=]+ $file | \
  sed -E -e "s/$escaped_key([\ \t]*=[\ \t]*|[\ \t]+)([A-Za-z0-9\.-]*).*/\2/g"
}
