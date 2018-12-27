# buildpack for Python

云帮 Python 语言项目的源码构建核心部分是基于[Heroku buildpack for Python](https://github.com/heroku/heroku-buildpack-python) 来实现的。支持使用`Django`或`Flask`等框架。

## 工作原理

当buildpack检测到您代码的根目录下存在`requirements.txt`文件，该应用被识别为Python应用。Python由pip与其他依赖驱动。Web应用需要绑定到`$PORT`。

## 文档

以下文章了解更多：

- [云帮支持Python](https://www.rainbond.com/docs/stable/user-manual/language-support/python.html)


## 配置

### 推荐使用的Python版本

 通过`runtime.txt`文件来指定Python版本:
 
- `Python-2.7.15`
- `Python-3.6.6`
- `Python-3.7.0`

### 支持自定义Pypi镜像地址(https)

构建应用时配置环境变量

```bash
BUILD_PIP_INDEX_URL https://pypi.tuna.tsinghua.edu.cn/simple
```

## 授权

根据 MIT 授权获得许可。 请参阅LICENSE文件