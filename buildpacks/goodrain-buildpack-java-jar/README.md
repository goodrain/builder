# JAVA JAR APP buildpack

## 代码检测

- 代码根目录需要有 LANGUAGE 文件，内容为 `java-jar`

## 默认环境

- jdk 1.8

## 运行

Procfile文件内容

```bash
web: java -cp config/:lib/*.jar:bin/.class Example
```
请根据目录的实际情况写`Procfile` 的内容
