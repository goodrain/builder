Static  buildpack
========================

Rainbond静态html项目的源码构建核心部分是基于[Heroku buildpack for static ](https://github.com/heroku/heroku-buildpack-static)实现的。

工作原理
-------

当buildpack在您应用的代码根目录下检测到`index.html` 文件，它会识别应用为Static(静态网页)。

文档
-------

## Nginx

默认使用最新稳定版本Nginx v1.14.2

#### 自定义Nginx配置

需要在源码根目录定义nginx配置文件：`web.conf`,默认配置文件为

```
server {
    listen       80;
    
    location / {
        root   /app/www;
        index  index.html index.htm;
    }
}
```



## 授权

根据 MIT 授权获得许可。 请参阅LICENSE文件
