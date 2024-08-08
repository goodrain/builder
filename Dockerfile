FROM registry.cn-hangzhou.aliyuncs.com/goodrain/stack-image:22
ARG RELEASE_DESC

# 时区设置
ENV TZ=Asia/Shanghai
RUN sed -i "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config && \
    mkdir /root/.ssh

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
    wget -q https://buildpack.oss-cn-shanghai.aliyuncs.com/common/utils/jqe-$(arch) -O /usr/bin/jqe && chmod +x /usr/bin/jqe

# Default Support Chinese
ENV LANG=zh_CN.utf8

# Non-root user will cause permission error.
# For example. changes to /etc/hosts will be denied.
# USER rain

ENV HOME /app
ENV RELEASE_DESC=${RELEASE_DESC}

ENTRYPOINT ["/tmp/builder/build.sh"]
