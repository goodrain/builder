### 选择JDK

Create a `system.properties` file in the root of your project directory and set `java.runtime.version=1.8`.

Example:

    $ ls
    Procfile pom.xml src

    $ echo "java.runtime.version=1.8" > system.properties

    $ git add system.properties && git commit -m "Java 8"

    $ git push heroku master
    ...
    -----> Java app detected
    -----> Installing OpenJDK 1.8... done
    -----> Installing Maven 3.3.3... done
    ...

### 选择Maven版本

You can define a specific version of Maven for Heroku to use by adding the
[Maven Wrapper](https://github.com/takari/maven-wrapper) to your project. When
this buildpack detects the precense of a `mvnw` script and a `.mvn` directory,
it will run the Maven Wrapper instead of the default `mvn` command.

If you need to override this, the `system.properties` file also allows for a `maven.version` entry
(regardless of whether you specify a `java.runtime.version` entry). For example:

```
java.runtime.version=1.8
maven.version=3.3.9
```

### 自定义 Maven

There are three config variables that can be used to customize the Maven execution:

+ `MAVEN_CUSTOM_GOALS`: set to `clean dependency:list install` by default
+ `MAVEN_CUSTOM_OPTS`: set to `-DskipTests` by default
+ `MAVEN_JAVA_OPTS`: set to `-Xmx1024m` by default


### 环境变量

```
BUILD_DEBUG_INFO: 显示下载runtime url
BUILD_MAVEN_MIRROR_OF: Maven mirrorof
BUILD_MAVEN_MIRROR_URL: Maven mirror url
BUILD_MAVEN_MIRROR_DISABLE: 禁用Maven mirror
BUILD_MAVEN_SETTINGS_URL: Maven 配置url
BUILD_MAVEN_CUSTOM_OPTS: 默认-DskipTests
BUILD_MAVEN_CUSTOM_GOALS: 默认clean dependency:list install
BUILD_MAVEN_JAVA_OPTS: 默认MAVEN_JAVA_OPTS
```