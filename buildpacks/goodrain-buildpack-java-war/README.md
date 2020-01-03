# JAVA WAR APP buildpack

## 代码检测

- 代码根目录需要有 .war 文件

## 默认环境

- jdk 1.8
- webapp-runner-7.0.57.2  (tomcat)

## 运行

Procfile文件默认内容

```bash
web: java $JAVA_OPTS -jar ./webapp-runner.jar --port $PORT ./*.war
```

## 离线构建

```
BUILD_OFFLINE: 离线构建
BUILD_WEBSERVER_URL: 自定义WEBSERVER_URL下载地址
```