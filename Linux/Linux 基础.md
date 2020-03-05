[TOC]

# Linux 各目录作用

```bash
[root@enderlee /]# ls
bin  boot  dev  etc  home  lib  lib64  lost+found  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

- bin: 保存系统命令，任何用户都能执行
- sbin: 保存系统命令，只有 root 用户可以执行
- usr/bin: 保存系统命令，任何用户都能执行
- usr/sbin: 保存系统命令，只有 root 用户可以执行
- boot: 用户启动数据
- dev: 特殊文件保存目录
- etc: 系统默认配置文件
- home: 普通用户家目录
- root: root 用户家目录
- lib: 函数库目录
- media: 空目录，用于挂载
- mnt: 空目录，用于挂载
- proc: 不能直接操作，保存内存的过载点（内存的盘符）
- sys: 不能直接操作，保存内存的过载点（内存的盘符）
- tmp: 临时目录，存放临时数据
- usr: 系统软件资源目录

# Linux 常用命令

## 基础命令

### 目录/文件相关

创建目录

```bash
# 创建目录
mkdir 目录名

# 递归创建目录，比如：mkdir -p test/test/test  会同时创建三级目录
mkdir -p 目录名
```

删除目录

```bash
# 删除空白目录
rmdir 目录名

# 删除目录
rm -r 目录名

# 强制删除目录
rm -rf 目录名/文件名
```

查看当前目录

```bash
pwd
```

切换目录

```bash
# 返回上级目录
cd ..

# 切换到指定目录
cd 目录的路径

# 切换到当前用户的家目录
cd ~

# 切换到根目录
cd /

# 回到上次工作目录
cd -
```

复制文件/目录

```bash
# 复制文件，新复制的文件时间是复制命令执行时间
cp 源文件 目标位置

# 复制目录
cp -r 源目录 目标位置

# 复制文件，使得新复制的文件时间与源文件时间相同（文件所有属性都一致）
cp -a 源文件 目标位置
```

移动/重命名文件/目录

```bash
# 移动文件/目录
mv 源文件/源目录 目标位置

# 重命名文件
mv 源文件 源文件位置/新名字
```

软/硬链接

```bash
# 注意：软链接的源文件必须为绝对路径
# 创建软链接文件（软链接文件有自己的 i 节点号，类似于 windows 的快捷方式）
ln -s 源文件（绝对路径） 目标文件

# 创建硬链接，目标文件就是一个硬链接文件（硬链接文件相当于源文件的一个备份）
ln 源文件 目标文件
```

文件传输命令

```bash
# 下载文件，-r 表示下载目录
scp [-r] 用户名@ip:文件路径 本地路径

# 上传文件，-r 表示上传目录
scp [-r] 本地文件 用户名@ip:上传路径 
```

### 查找/搜索相关

#### 查找之 `find` 命令

```bash
# 文件搜索命令（find 命令搜索速度比较慢，find 是完全匹配）
find 搜索路径 [option] 搜索条件 [操作]

# 例如在 /etc 目录下查找文件名为 nginx.conf 的文件
find /etc -n 'nginx.conf'

常用 [option]:
-name: 按照文件名查找
-iname:	按照文件名查找，忽略大小写
-user: 根据文件所属者查找（比如查找文件所属者为 user1 的所有文件	find . -user user1）
-group: 根据文件所属组查找（比如查找文件所属组为 yarn 的所有文件	find . -group yarn ）
-type: 根据文件类型查找，查找选项包括:
			f		文件				
			d		目录				
			c		字符设备文件		
			b		块设备文件			
			l		链接文件			
			p		管道文件
-size: 按照文件大小查找，查找选项包括:
			-n		小于 n 的文件
			+n		大于 n 的文件
			例子1：查找 /etc 目录下小于 10000 字节的文件：find /etc -size -10000c
			例子2：查找 /etc 目录下大于 1M 的文件：find /etc -size +1M
-mtime: 按照文件修改时间（天）查找，查找选项包括:
			-n		n 天以内修改的文件
			+n		n 天之前修改的文件
			n		  正好 n 天修改的文件
			例子1：查找 /etc 目录下 5 天之内修改且以 conf 结尾的文件：find /etc -mtime -5 -name '*.conf'
			例子2：查找 /etc 目录下 10 天之前修改且属主为 root 的文件：find /etc -mtime +10 -user root	
-mmin: 按照文件修改时间（分钟）查找，查找选项包括:	
			-n		n 分钟以内修改的文件
			+n		n 分钟以外修改的文件
			例子1：查找 /etc 目录下 30 分钟之前修改的文件：find /etc -mmin +30		
-mindepth n: 表示从n级子目录开始搜索
			例子：在 /etc 下的 3 级子目录开始搜索：find /etc -mindepth 3 
-maxdepth n: 表示最多搜索到 n 级子目录
			例子：在 /etc 下搜索符合条件的文件，但最多搜索到 2 级子目录：find /etc -maxdepth 3 -name '*.conf'
	
其他[option]：了解即可
-nouser: 查找没有属主的用户		
-nogroup: 查找没有属组的用户		
-perm: 按照文件权限查找
		例子：find . -perm 664
-prune: 查找时排除指定目录。通常和 -path 一起使用，用于将特定目录排除在搜索条件之外
		例子：查找当前目录下所有普通文件，但排除 etc 和 opt 目录
		find . -path ./etc -prune -o -path ./opt -prune -o -type f	
-newer file1: 查找更改时间比 file1 新的文件
		例子：find /etc -newer a

常用[操作]:
-print: 打印输出
-exec: 对搜索到的文件执行特定的操作，格式为 -exec 'command' {} \;
		# {} 表示查找的结果
		例子1：搜索 /etc 下的文件(非目录)，文件名以 conf 结尾，且大于 10k，然后将其删除
			find ./etc/ -type f -name '*.conf' -size +10k -exec rm -f {} \;	
		例子2：将 /var/log/ 目录下以 log 结尾的文件，且更改时间在 7 天以上的删除
			find /var/log/ -name '*.log' -mtime +7 -exec rm -rf {} \;
		例子3：搜索条件和例子1一样，只是不删除，而是将其复制到 /root/conf 目录下
			find ./etc/ -size +10k -type f -name '*.conf' -exec cp {} /root/conf/ \;
-ok: 和 -exec 功能一样，只是每次操作都会给用户提示

按照多个条件查找：
-a: 与
-o: 或
-not|!: 非
		例子1：查找当前目录下，属主不是 hdfs 的所有文件		
			find . -not -user hdfs 	|	find . ! -user hdfs
		例子2：查找当前目录下，属主属于 hdfs ，且大于 300 字节的文件
			find . -type f -a -user hdfs -a -size +300c
		例子3：查找当前目录下的属主为 hdfs 或者以 xml 结尾的普通文件
			find . -type f -a \( -user hdfs -o -name '*.xml' \)
```

#### 查找之 `locate` 命令

> 使用 locate 之前必须安装

安装 `locate`

```bash
yum install mlocate
```

查找

```bash
# 文件搜索命令
#（locate 搜索 /user/lib/mlocate 中后台数据库中的内容，数据库每天更新一次，对应的配置文件在 /etc/updatedb.conf 中）
locate 文件名
```

强制更新 `/user/lib/mlocate` 数据库

```bash
updatedb
```

#### 查找之 `whereis` 命令

> `whereis` 用户查找可执行文件和帮助文档

```bash
# whereis 搜索系统命令
whereis 命令名

# 只查命令所在位置
whereis -b 命令名

# 只查命令对应的帮助文档
whereis -m 命令名
```

#### 查找之 `which` 命令

> 用于查找程序的可执行文件

```bash
# 查看命令所在位置以及命令别名
which 命令名
```

### 压缩与解压缩

常用压缩格式：
`.zip  .gz  .bz2  .tar.gz  .tar.bz2`

#### .zip 文件

```bash
# 压缩 zip 文件
zip 压缩文件名 源文件

# 压缩 zip 目录
zip -r 压缩目录名 源目录

# 解压缩 zip 文件
unzip 压缩文件
```

#### .gz 文件

```bash
# 压缩 .gz 文件
# gzip 会删除源文件，生成与源文件同名的 .gz 文件
gzip 源文件

# 保留源文件
gzip -c 源文件 > 压缩文件

# 解压缩 .gz 文件
gzip -d 压缩文件
gunzip 压缩文件
```

#### .bz2 文件

```bash
# 压缩 .bz2 文件
# bzip2 会删除源文件，生成与源文件同名的 .bz2 文件（bzip2 命令不能压缩目录）
bzip2 源文件

# 保留源文件
bzip2 -k 源文件

# 解压缩 .bz2 文件，可以加 -k 参数保留压缩文件
bzip2 -d 压缩文件
bunzip2 压缩文件
```

#### .tar.gz 或 .tar.bz2 文件

```bash
# tar 命令用法
tar [option] 文件

常用 [option]:
-c：打包
-v：显示过程
-f：指定打包后的文件名
-x：解压缩
-z：压缩为 .tar.gz 格式
-j：压缩为 .tar.bz2 格式
-t：test

# 压缩 .tar 文件
tar -cvf 打包文件名 源文件

# 解压缩 .tar 文件
tar -xvf 打包文件名

# 压缩 .tar.gz 文件
tar -zcvf 压缩文件名.tar.gz 源文件

# 解压缩 .tar.gz 文件
tar -zxvf 压缩文件名

# 压缩 .tar.bz2 文件
tar -jcvf 压缩文件名.tar.bz2 源文件

# 解压缩 .tar.bz2 文件
tar -jxvf 压缩文件名

# 查看 .tar.gz 压缩文件中内容
tar -ztvf 压缩文件名
```

### 挂载命令

```bash
# 查看系统中已挂载的设备
mount

# 依据 /etc/fstab 中的内容自动挂载
mount -a

# 挂载设备
mount [-t 文件系统] [-o 特殊选项] 设备文件名 挂载点

# 挂载光盘的步骤
# 1. 新建挂载点
mkdir /mnt/cdrom
# 2. 执行挂载命令
mount -t iso9660 /dev/sr0 /mnt/cdrom

# 卸载挂载设备
umount 挂载点
```

### 登录相关

```bash
# 查看登录用户
w

who

# 查询当前登录的和过去登录的信息（所有用户）、以及系统重启信息
last

# 查看所有用户的最后一次登录时间
lastlog
```

### 文本输出 -- echo

```bash
echo 输出内容

# 输出带 \ 的特殊字符
echo -e 输出内容
# 输出内容中可以包含
\n：换行
\b：删除左侧字符
\t：制表符
\0nnn：输出八进制数字
\xnnn：输出十六进制数字
\a：输出警告音
\r：回车键
\v：垂直制表符
\e[1;颜色 输出内容 \e[0m 输出显示颜色

echo -e "\e[1;31m hello \e[0m"
```

### 网络相关

```bash
# 查看与配置网络命令，看不到网关和 DNS
ifconfig

# 禁用网卡
ifdown 网卡设备名

# 启用网卡
ifup 网卡设备名

# 查询网络状态
netstat [option]
常用[option]:
-t：列出 tcp 协议端口
-u：列出 UDP 协议端口
-n：不使用域名和服务名，而使用 ip 地址和端口号
-l：仅列出在监听状态网络服务
-a：列出所有的网络连接
-r：列出路由列表，功能和 route 命令一致

# route 命令
# 查看路由列表，可以看到网关
route -n

# 临时设置网关
route add default gw 192.168.1.1

# 查看 dns
nslookup 主机名或 ip

# 探测指定 ip 或域名的网络状况
ping [option] ip或域名
常用[option]
-c 次数：指定 ping 包的次数

# 远程管理和端口探测命令
telnet 域名或ip 端口

# 查看连接域名或ip经过的路由
traceroute [option] 域名或ip

# tcpdump 命令 
tcpdump -i 网卡接口 -nnX port 端口号
# 参数解释
-i：指定网卡接口
-nn：将数据包中的域名和服务转为 ip 和端口
-X：以十六进制和ASCII码显示数据包内容
port：指定端口号

```

### 软件下载安装相关

#### `wget`

```bash
wget 下载地址
```

#### `rpm`

```bash
# 二进制包（rpm 包，系统安装包）
# rpm 包管理（rpm包安装和卸载会检测包的依赖性）
rpm [option] rpm包全名
常用[option]:
-i：安装
-U：升级
-v：显示安装过程（verbose）
-h：显示进度
--nodeps：不检测依赖性

# 卸载 rpm 包
rpm -e 包名
# 选项
-e：erase，表示卸载
--nodeps：不检测依赖性

# rpm 包查询
rpm -q 包名

# 查询系统中已安装的所有包
rpm -qa

# 查询已安装软件包的信息
rpm -qi 包名

# 查询未安装软件包的信息
rpm -qip 包名

# 查询软件包中文件安装位置
rpm -ql 包名

# 查询系统文件属于哪个 rpm 包
rpm -qf 系统文件名

# 查看包依赖哪些包
rpm -qR 包名
常用[option]:
-q：query，表示查询
-a：all，表示全部
-i：查询软件包信息
-p：package，表示未安装包
-l：list，表示列表
-f：file，表示系统文件

# rpm 包校验
# 校验指定 rpm 包中的文件
rpm -V 包名
# 验证内容中的 8 个信息是否改变
S：文件大小是否改变
M：文件的类型或文件的权限（rw）是否被改变
5:文件的 MD5 和是否被改变
D：设备的主从代码是否被改变
L：文件路径是否改变
U：文件的所有者是否改变
G：文件的所属组是否改变
T：文件的修改时间是否改变

# rpm 包中文件提取
rpm2cpio 包全名 | cpio -div .文件绝对路径
# 参数
rpm2cpio：将rpm包转换为cpio格式的命令
```

#### `yum`

```bash
# yum 在线安装
yum install 包名
yum -y install 包名
# 选项
-y：自动回答 yes

# yum 源配置文件位置
/etc/yum.repos.d

# 查询所有可安装软件包
yum list

# 查询和关键字相关的软件包
yum search 关键字

# 更新软件
yum -y update 包名

# 卸载软件包
yum -y remove 包名

# yum 软件组管理命令
# 查看软件组
yum grouplist

# 安装软件组
yum grouplistinstall

# 卸载软件组
yum grouplist remove
```

### 监控相关

```bash
top
free
df
vmstat
iostat
```

