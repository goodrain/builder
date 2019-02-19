## 1902101
- static buildpack 支持nginx选择

## 112301
- php buildpack: compile 文件请求 api.github.com 添加超时和重试机制

## 111301
- 优化apache mpm_event 优化参数

## 110601
- php buildpack 更新到v82版本，apache降级到2.4.16，添加apache ProxySet timeout参数

## 102301
- golang buildpack升等级到18.2 版本
- php buildpack 添加swoole扩展，升级到v80.102305 版本

## 102001
- php，apache，nginx版本升级
- 优化预处理脚本

## 101902
- 更新php-buildpack到v80版本

## 101901
- 将预编译脚本中调用user.goodrain.com的协议更新为https

## 101001
- 为了预编译脚本调用user api的操作添加了超时参数

## 71901
- 解决php 5.4.40 第三方扩展问题
- 修改nginx 在 php 5.4.40 版本中的最低版本需求

## 70301
- 升级python的pip和settools版本

## 70104
- 关闭maven debug日志
- 去掉java buildpack 帮助文档地址
- 去掉python collectstatic 日志

## 63001
- 添加goodrain-buildpack-java-war 支持 单独上传一个war的java webapp 程序


## 62901
- 修改静态文件buildpack的apache参数，之前最大连接数为1，有空用nginx替换apache

## 60901
- 修改所有buildpack的clone地址，去掉ssh://前缀
