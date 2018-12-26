FROM rainbond/cedar14:20180416

LABEL MAINTAINER ="zhengys <zhengys@goodrain.com>"

# 时区设置
RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata

# git ssh 禁止提示添加host key
RUN sed -i "s/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/g" /etc/ssh/ssh_config

# 复制ssh key
RUN mkdir /root/.ssh
ADD ./id_rsa /root/.ssh/id_rsa
ADD ./id_rsa.pub /root/.ssh/
RUN chmod 700 /root/.ssh && chmod 600 /root/.ssh/id_rsa


RUN mkdir /app
RUN addgroup --quiet --gid 200 rain && \
    useradd rain --uid=200 --gid=200 --home-dir /app --no-create-home

ADD ./builder/ /tmp/builder
#RUN /tmp/builder/install-buildpacks

ADD ./pre-compile/ /tmp/pre-compile
ADD ./buildpacks /tmp/buildpacks
RUN chown rain.rain -R /tmp/pre-compile /tmp/builder /tmp/buildpacks

RUN chown -R rain:rain /app

USER rain

ENV HOME /app
ENV RELEASE_DESC=__RELEASE_DESC__

ENTRYPOINT ["/tmp/builder/build.sh"]
