# Buildpack for Go!

云帮 Go 语言源码构建核心部分是基于[Heroku buildpack for go](https://github.com/heroku/heroku-buildpack-go) 来实现的。

## 工作原理

当buildpack检查您的应用含有如下情况时，您的应用被识别为Go应用：

- 在根目录的`/Godeps`目录下有`Godeps.json`文件，标识应用由[godep](https://devcenter.heroku.com/articles/go-dependencies-via-godep)管理。
- 在根目录的`/vendor`目录下有`Govendor.json`文件，标识应用由[govendor](https://devcenter.heroku.com/articles/go-dependencies-via-govendor)管理。
- 在根目录的`/src`目录下包含`<文件名>.go`文件，标识应用由[gb](https://devcenter.heroku.com/articles/go-dependencies-via-gb)管理。

## 文档

以下文章了解更多：

- [云帮支持Go](http://www.rainbond.com/docs/stable/user-lang-docs/go/lang-go-overview.html)
- [使用Beego等框架](http://www.rainbond.com/docs/stable/user-lang-docs/go/lang-go-beego.html)

## 配置

### Go 版本

默认Go版本1.11.2

### Go Tools版本

- Dep 默认支持版本v0.4.1
- Glide 默认支持版本v0.12.3
- Govendor 默认支持版本v1.0.8
- GB 默认支持版本v0.4.4
- PkgErrors 默认支持版本v0.8.0
- HG 默认支持版本v3.9
- TQ 默认支持版本v0.5
- MattesMigrate 默认支持版本v3.0.0

## 授权

根据 MIT 授权获得许可。 请参阅LICENSE文件
