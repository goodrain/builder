# Heroku buildpack for Node.js

云帮 Node.js 语言源码构建核心部分是基于[Heroku buildpack for Nodejs](https://github.com/heroku/heroku-buildpack-nodejs) 来实现的。

## 工作原理

当buildpack在您代码的根目录下检测到`package.json`文件，您的应用被识别为Node.js程序。若`package.json`文件不存在请手动或使用 `npm init` 命令创建并配置需要的依赖和其它信息。

## 文档

以下文章了解更多：

- [云帮支持Node.js](http://www.rainbond.com/docs/stable/user-lang-docs/ndjs/lang-ndjs-overview.html)


## 配置

### 支持版本

```
node  8.x (支持到 8.17.0)
node  10.x (支持到 10.24.1)
node  11.x (支持到 11.15.0)
node  12.x (支持到 12.22.12)
node  13.x (支持到 13.14.0)
node  14.x (支持到 14.21.3)
node  15.x (支持到 15.14.0)
node  16.x (支持到 16.20.0)
node  17.x (支持到 17.9.1)
node  18.x (支持到 18.16.0)
node  19.x (支持到 19.9.0)
node  20.x (支持到 20.0.0)
yarn  1.x (支持到1.9.4)
iojs  3.x (支持到3.3.1)
iojs  2.x (支持到2.5.0)
```

可以在 `package.json` 里使用 engines 指定版本：

```bash
{
      "name": "demo",							#自定义名称
      "description": "this is a node demo",		#描述
      "version": "0.0.1",						#自定义版本
      "engines": {								#engines
        "node": "10.9.0"							#node版本
      }
}
```

> 提示：npm 版本的指定是非必要的，因为npm与node时绑定的

## **环境变量**

NODE_ENV 环境变量默认是 production。

```bash
# 默认 NODE_ENV 是 production
NODE_ENV=${NODE_ENV:-production}
```

## 授权

根据 MIT 授权获得许可。 请参阅LICENSE文件