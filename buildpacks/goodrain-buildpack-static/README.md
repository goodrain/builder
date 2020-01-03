# Static  buildpack

Rainbond静态html项目的源码构建核心部分是基于[Heroku buildpack for static ](https://github.com/heroku/heroku-buildpack-static)实现的。

## 工作原理

当buildpack在您应用的代码根目录下检测到`index.html` 文件，它会识别应用为Static(静态网页)。

## 其他

### web服务器
Nginx默认使用最新稳定版本 v1.14.2
Apache默认使用稳定版本 v2.2.19

### 环境变量

```bash
BUILD_DEBUG_INFO: 显示下载runtime url
BUILD_USE_NGINX: 使用Nginx
BUILD_USE_APACHE: 使用Apache
```

## 授权

根据 MIT 授权获得许可。 请参阅LICENSE文件
