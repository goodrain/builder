FROM rainbond/cedar14:20211224

LABEL MAINTAINER ="guox <guox@goodrain.com>"

# 时区设置
ENV TZ=Asia/Shanghai
RUN sed -i "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config && \
    mkdir /root/.ssh

ADD ./id_rsa /root/.ssh/id_rsa
ADD ./id_rsa.pub /root/.ssh/
ADD ./builder/ /tmp/builder
ADD ./pre-compile/ /tmp/pre-compile
ADD ./buildpacks /tmp/buildpacks

RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_rsa && \
    mkdir /app && \
    addgroup --quiet --gid 200 rain && \
    useradd rain --uid=200 --gid=200 --home-dir /app --no-create-home && \
    /tmp/builder/install-buildpacks && \
    chown rain.rain -R /tmp/pre-compile /tmp/builder /tmp/buildpacks && \
    chown -R rain:rain /app && \
    wget -q https://buildpack.oss-cn-shanghai.aliyuncs.com/common/utils/jqe-$(arch) -O /usr/bin/jqe && chmod +x /usr/bin/jqe && \
    apt-get update && apt-get install build-essential && \ 
    wget http://www.zlib.net/fossils/zlib-1.2.9.tar.gz && \
    tar xvf zlib-1.2.9.tar.gz && cd zlib-1.2.9 && \
    ./configure && make && make install && \
    ln -sf /usr/local/lib/libz.so.1.2.9 /lib/x86_64-linux-gnu/libz.so.1
    

# Default Support Chinese
ENV LANG=zh_CN.utf8

# Non-root user will cause permission error.
# For example. changes to /etc/hosts will be denied.
# USER rain

ENV HOME /app
ENV RELEASE_DESC=__RELEASE_DESC__

ENTRYPOINT ["/tmp/builder/build.sh"]
