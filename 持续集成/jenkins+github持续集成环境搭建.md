# 手把手教你搭建Jenkins+Github持续集成环境

### 一、安装 Jenkins

Centos 7 环境安装 jenkins

#### 1. 安装 Java 环境

如果已安装 Java，可以跳过这一步。。。

下载 jdk1.8：

```shell
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.tar.gz
```

解压下载的压缩包到指定位置，比如：/usr/local/java

```shell
tar -zxvf jdk-8u131-linux-x64.tar.gz
```

设置环境变量：

```shell
vi ~/.bash_profile

# 加入以下内容
export JAVA_HOME=/usr/local/java/jdk1.8.0_101
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
```

使环境变量生效：

```shell
source ~/.bash_profile
```

查看 java 是否安装成功：

```shell
java -version
```

#### 2. 安装 git

如果已经安装过了，可以跳过这一步。。。

```shell
yum -y install git
```

#### 3. 安装 Jenkins

第一种方法：

```shell
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

yum install jenkins
```

第二种方法：

直接下载 rpm 安装，各个版本地址： https://pkg.jenkins.io/

```shell
wget https://pkg.jenkins.io/redhat/jenkins-2.156-1.1.noarch.rpm
rpm -ivh jenkins-2.156-1.1.noarch.rpm
```

#### 4. 更改 Jenkins 配置

根据需要修改，不需要的话也可以跳过这一步。。。

比如配置端口和用户：

```shell
vim /etc/sysconfig/jenkins

# 找到上述文件中需要配置的内容
# 配置监听端口
JENKINS_PORT="8080"

# 为了不因为权限出现各种问题，修改用户为 root
$JENKINS_USER="root"
```

配置权限：

保证上面修改的用户可用

```shell
# 修改目录权限
chown -R root:root /var/lib/jenkins
chown -R root:root /var/cache/jenkins
chown -R root:root /var/log/jenkins
```

#### 5. 启动 Jenkins 服务

```shell
service jenkins start
或
systemctl start jenkins
```

启动过程可能会报错，比如我就遇到了下面的问题：

![启动报错](https://note.youdao.com/yws/api/personal/file/WEB494b8c9207004770e78c692740f4f029?method=download&shareKey=dca4d1acd28b8c6cf64a7cda810fd890)

原因：

```shell
Starting Jenkins bash: /usr/bin/java: No such file or directory
```

解决方法： 找到你的 jdk 目录，我的是在 usr/local/java/jdk1.8.0_131/ 下，创建软链接即可：

```shell
ln -s /usr/local/java/jdk1.8.0_131/bin/java /usr/bin/java
```

然后重新启动 jenkins 服务即可：

```shell
service jenkins restart
```

### 二、配置 Jenkins

通过浏览器访问 jenkins 地址：http:<ip或者域名>:8080

<!--注意：服务器防火墙必须开放8080端口或者通过 nginx 进行访问-->

初始启动可能会遇到下面的问题：我就遇到了 O(∩_∩)O~

![浏览器进入](https://note.youdao.com/yws/api/personal/file/WEB4e5b749efb77da18a7317e31dc84464b?method=download&shareKey=eda4aacc136850e4457350b7b486f331)

解决办法：

修改 jenkins 启动目录 /var/lib/jenkins/ 下的 hudson.model.UpdateCenter.xml 文件

```shell
vim /var/lib/jenkins/hudson.model.UpdateCenter.xml

将  http://mirror.xmission.com/jenkins/updates/update-center.json
修改为： http://mirror.xmission.com/jenkins/updates/update-center.json
```

修改后再次通过浏览器访问即可。

新手入门安装 Jenkins 可以参考：https://www.cnblogs.com/fangts/p/11095316.html

### 三、配置 Github

#### 1. 生成 github token

登录 github，点击右上角用户图标，进入 Settings

点击进入最下面的 Developer settings，选择 Personal access tokens，点击 Generate new token



保存生成的 access token

#### 2. 项目配置 webhook

对需要使用 webhook 部署的项目进行配置。

github 上进入项目 -- Settings，左侧选择 Webhooks，点击 Add webhook



Payload URL 填写：Jenkins域名/github-webhook/ 或者 Jenkins ip: 端口号/github-webhook/

Content Type 选择 application/json，保存即可



### 四、Jenkins 配置 Github

#### 1. 安装 Github 插件

如果已经安装，可以跳过这一步。。。

登录 Jenkins，进入 系统管理 --> 插件管理 --> 可选插件

直接安装Github Plugin, jenkins会自动帮你解决其他插件的依赖，直接安装该插件 Jenkins 会自动帮你安装plain-credentials 、Git、 credentials 、 github-api

#### 2. 添加凭据

进入 凭据 --> 系统，点击全局凭据，点击左侧添加凭据，添加 access token 和 访问 github 的 ssh 私钥（私钥就是你 git clone 时候的私钥，可以去 ～/.ssh 下查看）



添加 access token 的凭据，类型选择 Secret text，然后在 Secret 一栏中填入之前 github 上生成的 access token 即可



添加 ssh 私钥的凭据，类型选择 SSH username with private key，填写 username，Private Key 勾选 Enter directly，点击 Add，输入 ssh 私钥即可



#### 3. 配置GitHub Plugin

进入系统管理 --> 系统配置，找到 GitHub 配置，点击 Add GitHub Sever，配置 GitHub Server 信息，凭据如果一直是无，可以去首页选择凭据进行添加，这个页面直接添加的凭据可能不生效。

设置完成后，点击测试连接，如果提示 `Credentials verified for user UUserName, rate limit: xxx`，则表明有效。

#### 4. 创建部署任务

点击新建任务，输入任务名称，选择构建一个自由风格的软件项目

配置 GitHub 项目，输入项目地址



源码管理选择 Git，输入项目仓库地址，Credentials 选择之前添加的 ssh 私钥凭据，源码库浏览器选择 githubweb，URL 输入 github 项目 url



构建触发器选择：GitHub hook trigger for GITScm polling



构建环境选择：Use secret text(s) or file(s)

新增绑定 Secret text，选择 access token 凭据



构建：根据项目部署需求，可以选择执行 shell 脚本部署项目，也可以选择其他方式等，具体看项目



配置好了以后，可以 push 一下代码测试是否生效，如果生效，则会看到 Jenkins 正在部署项目





