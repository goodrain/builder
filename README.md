# Rainbond Builder

该项目为[Rainbond](https://github.com/goodrain/rainbond)项目的子项目。
借助于 [Docker](http://docker.io) 和 [Buildpacks](https://devcenter.heroku.com/articles/buildpacks) 来生成 Heroku 风格的 [slug](https://devcenter.heroku.com/articles/slug-compiler) 为app提供运行环境。

## 功能特性

- 🚀 支持多种编程语言（Java、Node.js、Python、Go、PHP、Ruby 等）
- 📦 自动检测应用类型并选择合适的 Buildpack
- ⚡ 内置缓存机制，加速构建过程
- 🔧 兼容 Heroku Buildpacks 生态

### 支持的语言

| 语言 | Buildpack | 说明 |
|------|-----------|------|
| Java | `Java-maven`, `Java-jar`, `Java-war` | 支持 Maven、JAR、WAR 部署 |
| Node.js | `Node.js` | 支持 npm、yarn 包管理 |
| Python | `Python` | 支持 pip 包管理 |
| Go | `Go` | 支持 Go modules |
| PHP | `PHP` | 支持 Composer |

## 相关项目

- [Rainbond](https://github.com/goodrain/rainbond) - 主项目
- [Buildpacks](https://buildpacks.io/) - 构建技术标准
