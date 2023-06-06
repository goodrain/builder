#!/usr/bin/env bash

# set default_java_mem_opts
case ${MEMORY_SIZE} in
    "micro")
       export default_java_mem_opts="-Xms90m -Xmx90m -Xss512k  -XX:MaxDirectMemorySize=12M"
       echo "Optimizing java process for 128M Memory...." >&2
       ;;
    "small")
       export default_java_mem_opts="-Xms180m -Xmx180m -Xss512k -XX:MaxDirectMemorySize=24M "
       echo "Optimizing java process for 256M Memory...." >&2
       ;;
    "medium")
       export default_java_mem_opts="-Xms360m -Xmx360m -Xss512k -XX:MaxDirectMemorySize=48M"
       echo "Optimizing java process for 512M Memory...." >&2
       ;;
    "large")
       export default_java_mem_opts="-Xms720m -Xmx720m -Xss512k -XX:MaxDirectMemorySize=96M "
       echo "Optimizing java process for 1G Memory...." >&2
       ;;
    "2xlarge")
       export default_java_mem_opts="-Xms1420m -Xmx1420m -Xss512k -XX:MaxDirectMemorySize=192M"
       echo "Optimizing java process for 2G Memory...." >&2
       ;;
    "4xlarge")
       export default_java_mem_opts="-Xms2840m -Xmx2840m -Xss512k -XX:MaxDirectMemorySize=384M "
       echo "Optimizing java process for 4G Memory...." >&2
       ;;
    "8xlarge")
       export default_java_mem_opts="-Xms5680m -Xmx5680m -Xss512k -XX:MaxDirectMemorySize=768M"
       echo "Optimizing java process for 8G Memory...." >&2
       ;;
    16xlarge|32xlarge|64xlarge)
       export default_java_mem_opts="-Xms8G -Xmx8G -Xss512k -XX:MaxDirectMemorySize=1536M"
       echo "Optimizing java process for biger Memory...." >&2
       ;;
    *)
       export default_java_mem_opts=""
       echo "The environment variable \$MEMORY_SIZE was not identified,The Java process will not be optimized...." >&2
       ;;
esac

# Adapt to Rainbond v5.14.1 custom memory resources
if [ -z ${MEMORY_SIZE} ] && [ -n ${CUSTOM_MEMORY_SIZE} ];then
  jmx_mem=$(echo ${CUSTOM_MEMORY_SIZE} | awk '{printf("%.0f",$1*0.7)}')
  direct_mem=$(echo ${CUSTOM_MEMORY_SIZE} | awk '{printf("%.0f",$1*0.09375)}')
  if [ $jmx_mem==0 ];then
    export default_java_mem_opts=""
    echo "Since there is no limit on instance memory, JVM memory is not set" >&2
  else
    export default_java_mem_opts="-Xms${jmx_mem}m -Xmx${jmx_mem}m -Xss512k -XX:MaxDirectMemorySize=${direct_mem}M"
    echo -e "Based on a custom memory value of ${CUSTOM_MEMORY_SIZE} MB, the optimized JVM memory setting is: \n ${default_java_mem_opts}" >&2
  fi
fi

export JAVA_HOME="$HOME/.jdk"
export LD_LIBRARY_PATH="$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH"
export PATH="$HOME/.heroku/bin:$JAVA_HOME/bin:$PATH"
limit=$(ulimit -u)

if [[ "${JAVA_OPTS}" == *-Xmx* ]]; then
  export JAVA_TOOL_OPTIONS=${JAVA_TOOL_OPTIONS:-"-Dfile.encoding=UTF-8"}
else
  default_java_opts="${default_java_mem_opts} -Dfile.encoding=UTF-8"
  export JAVA_OPTS="${default_java_opts} $JAVA_OPTS"
  if [[ "${DYNO}" != *run.* ]]; then
    export JAVA_TOOL_OPTIONS=${JAVA_TOOL_OPTIONS:-${default_java_opts}}
  fi
  if [[ "${DYNO}" == *web.* ]]; then
    echo "Setting JAVA_TOOL_OPTIONS defaults based on dyno size. Custom settings will override them."
  fi
fi
