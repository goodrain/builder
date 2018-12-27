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
node  4.x (支持到 4.9.1)
node  5.x (支持到5.12.0)
node  6.x (支持到6.14.4)
node  7.x (支持到7.10.1)
node  8.x (支持到8.11.4)
node  9.x (支持到9.11.2)
node 10.x (支持到10.9.0)
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