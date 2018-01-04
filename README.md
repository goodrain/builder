# Builder

借助于 [Docker](http://docker.io) 和 [Buildpacks](https://devcenter.heroku.com/articles/buildpacks) 来生成 Heroku 风格的 [slug](https://devcenter.heroku.com/articles/slug-compiler) 为app提供运行环境。

## 组件做了哪那些事呢？

首先，应用程序源码通过管道的方式传给Docker容器。
源码会通过 buildpacks 运行, 如果源码被检测是被支持的app则就会进行编译，生成gzip的压缩包形式，以备在各处运行。

## 使用 Builder

首先, 你需要有Docker，然后你可以从Docker官方镜像仓库拉取镜像:
    ​```
    $ docker pull goodrain.me/builder
    ​```

或者你也可以从源码build:
```
	$ cd builder
	$ make
```

当容器运行起来后，它准备通过标准输入设备接收app源码包。所以让我们通过`git archive` 来得到源码包:
```
	$ id=$(git archive master | docker run -i -a stdin goodrain.me/builder)
	$ docker wait $id
	$ docker cp $id:/tmp/slug.tgz .
```

我们运行 builder容器,docker等待其正常退出，然后将只做好的slug包复制到当期目录。如果我们通过 `docker attach` 连接到容器可以看到Heroku的build日志。当然也可以通过下面的方式 *只* 查看build的输出信息：
```
	$ git archive master | docker run -i -a stdin -a stdout goodrain.me/builder
```

我们也可以查找id，将slug复制到容器外面来，通过如下简单的方式来实现！
```
	$ git archive master | docker run -i -a stdin -a stdout goodrain.me/builder - > myslug.tgz
```

上面的 `-` 参数，它会发送所有build的stderr输出(在这里我们无法连接)stdout输出的内容就是slug，可以看到可以轻松的将输出重定向到一个压缩包文件。

最后, 你也可以将压缩包文件PUT到指定的htpt服务器上，http地址作为builder的参数即可，如下：

	$ git archive master | docker run -i -a stdin -a stdout goodrain.me/builder http://fileserver/path/for/myslug.tgz

## 缓存

为了加快building速度，最好在building的时候挂载一个持久化存储目录到`/tmp/cache`，这样在第一次build时就可以可缓存的文件存在这个目录中，下次构建时可以直接使用。例如我希望挂载 /cache/abc 目录，构建时添加 `-v /tmp/app-cache:/tmp/cache:rw` 选项:

	docker run -v /tmp/app-cache:/tmp/cache:rw -i -a stdin -a stdout goodrain.me/builder

`注意`：挂载的目录需要为 rain 属主，否则构建会出错！


## Buildpacks

如你所见，builder支持heroku官方的buildpacks和众多的第三方buildpacks。当然你也可以添加自定义buildpack然后重新生成builder镜像。

## 基础环境

builder环境基于 [cedarish](https://github.com/progrium/cedarish) 创建，它模拟了 Heroku Cedar stack 环境。所有的 buildpacks 都运行在这个镜像中，如果某些buildpack出错，需要对该镜像进行修改。
