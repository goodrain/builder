Static  buildpack
========================

云帮静态网页项目的源码构建核心部分是基于 [Heroku buildpack for static ](https://github.com/heroku/heroku-buildpack-static)实现的。

工作原理
-------

当buildpack在您应用的代码根目录下检测到`index.html` 文件，它会识别应用为Static(静态网页)。

文档
-------

以下文章了解更多：

- [云帮支持Html](http://www.rainbond.com/docs/stable/user-lang-docs/html/lang-html-overview.html)


## 授权

根据 MIT 授权获得许可。 请参阅LICENSE文件
