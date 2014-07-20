#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : lnmp 安装脚本
 * Filename      : install.sh
 * Create time   : 2014-06-04 18:16:56
 * Last modified : 2014-07-20 15:02:26
 * License       : MIT, GPL
 * ********************************************
 */
EOF

[ $(id -u) != "0" ] && echo "请切换到root执行该脚本" && exit 1 

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

# 语言环境
export LANG=zh_CN.UTF-8

Mem=`free -m | awk '/Mem:/{print $2}'`

CPU_num=`cat /proc/cpuinfo | grep processor | wc -l`

CURDIR=$(cd "$(dirname "$0")"; pwd)

# 相关变量
src_path='/usr/local/src'
install_path='/usr/local/lnmp'
web_user=www
web_group=www
mysql_user=mysql
mysql_group=mysql
mysql_port=3306
mysql_pwd=root
is_update_system='n'
is_install_php='y'
is_install_nginx='y'
is_add_nginx_module='y'
is_install_mysql='y'
is_install_git='y'
is_install_memcache='y'
is_install_php_memcache='y'
is_install_php_accelerate=0
is_install_ftp='y'
is_install_ruby='y'
no_mod=''

read -p "是否更新系统(y/n, 默认$is_update_system)?:" is_val
[ $is_val ] && is_update_system=$is_val

read -p "请指定源码存放路径(默认$src_path):" new_path
[ $new_path ] && src_path=$new_path
[ ! -d $src_path ] && mkdir -p $src_path

read -p "请指定安装路径(默认$install_path):" new_path
[ $new_path ] && install_path=$new_path
[ ! -d $install_path ] && mkdir -p $install_path

# 相关路径
php_path=${install_path}/php5.3
ruby_path=${install_path}/ruby
nginx_path=${install_path}/nginx
mysql_path=${install_path}/mysql
mysql_data_path=${mysql_path}/data
ftp_path=${install_path}/pureftpd
yaml_path=${install_path}/yaml

read -p "是否安装php(y/n, 默认$is_install_php)?:" is_val
[ $is_val ] && is_install_php=$is_val
echo '选择安装PHP加速'
echo -e "\t0. 不安装加速"
echo -e "\t1. apcu"
echo -e "\t2. eaccelerator"
echo -e "\t3. opcache"
read -p "是否安装php加速(请输入序号, 默认$is_install_php_accelerate)?:" is_val
[ $is_val ] && is_install_php_accelerate=$is_val

read -p "是否安装ruby(y/n, 默认$is_install_ruby)?:" is_val
[ $is_val ] && is_install_ruby=$is_val

read -p "是否安装nginx(y/n, 默认$is_install_nginx)?:" is_val
[ $is_val ] && is_install_nginx=$is_val

read -p "是否安装mysql(y/n, 默认$is_install_mysql)?:" is_val
[ $is_val ] && is_install_mysql=$is_val

if [ $is_install_nginx = 'y' ]; then
    read -p "请指定web运行用户(默认$web_user):" new_user
    [ $new_user ] && web_user=$new_user

    read -p "请指定web运行用户组(默认$web_group):" new_group
    [ $new_group ] && web_group=$new_group
    is_install_git='y'
    is_add_nginx_module='y'
else
    is_add_nginx_module='n'
    read -p "是否安装git(y/n, 默认$is_install_git)?:" is_val
    [ $is_val ] && is_install_git=$is_val
    if [ -d $nginx_path ]; then
        read -p "是否添加nginx module(y/n, 默认$is_add_nginx_module)?:" is_val
        [ $is_val ] && is_add_nginx_module=$is_val
    fi
fi

if [ $is_add_nginx_module = 'y' ]; then
    echo
    echo "################################"
    echo '系统已有的nginx模块如下:'
    ls $CURDIR/ngx_mod | tr " " "\n"
    echo "如果需要添加模块可以使用.gitmodules方式也可以将准备好的模块复制到$CURDIR/ngx_mod目录下"
    echo "################################"
    echo
    read -p '请输入不需要安装的模块,多个模块用|分割：' is_val
    [ $is_val ] && no_mod=$is_val
fi

if [ $is_install_mysql = 'y' ]; then
    read -p "请指定mysql运行用户(默认$mysql_user):" new_user
    [ $new_user ] && mysql_user=$new_user

    read -p "请指定mysql运行用户组(默认$mysql_group):" new_group
    [ $new_group ] && mysql_group=$new_group

    read -p "请指定mysql运行端口(默认$mysql_port):" new_port
    [ $new_port ] && mysql_port=$new_port

    read -p "请指定mysql root 密码(默认$mysql_pwd):" new_pwd
    [ $new_pwd ] && mysql_pwd=$new_pwd

    read -p "请指定mysql数据目录(默认$mysql_data_path):" new_path
    [ $new_path ] && mysql_data_path=$new_path
fi

read -p "是否安装memcache(y/n, 默认$is_install_memcache)?:" is_val
[ $is_val ] && is_install_memcache=$is_val

if [ $is_install_memcache = 'y' ]; then
    is_install_php_memcache='y'
    read -p "是否安装php memcache 扩展(y/n, 默认$is_install_php_memcache)?:" is_val
    [ $is_val ] && is_install_php_memcache=$is_val
fi

read -p "是否安装ftp(y/n, 默认$is_install_ftp)?:" is_val
[ $is_val ] && is_install_ftp=$is_val

# 相关的路径
memcache_path=${install_path}/memcache
install_log=${install_path}/install.log
install_lib_path=${install_path}/lib
curl_path=${install_lib_path}/curl
freetype_path=${install_lib_path}/freetype
jpeg_path=${install_lib_path}/jpeg
libiconv_path=${install_lib_path}/libiconv
libmcrypt_path=${install_lib_path}/libmcrypt
libpng_path=${install_lib_path}/libpng
libxml2_path=${install_lib_path}/libxml2
libevent_path=${install_lib_path}/libevent
luajit_path=${install_lib_path}/luajit
mhash_path=${install_lib_path}/mhash
openssl_path=${install_lib_path}/openssl
openssl_src_path=${src_path}/openssl-1.0.1h
pcre_path=${install_lib_path}/pcre
pcre_src_path=${src_path}/pcre-8.35
zlib_path=${install_lib_path}/zlib
zlib_src_path=${src_path}/zlib-1.2.8
jemalloc_path=${install_lib_path}/jemalloc

# 更新系统
if [ $is_update_system = "y" ]; then
    . ${CURDIR}/scripts/update_system.sh
fi

# 工具
. ${CURDIR}/scripts/download.sh
. ${CURDIR}/scripts/install_status.sh

# 添加相关用户及用户组
. ${CURDIR}/scripts/user_add.sh

# 安装依赖包
if [ $is_install_php = 'y' -o $is_install_nginx = 'y' -o $is_install_mysql = 'y' ]; then
    . ${CURDIR}/scripts/install_lib.sh
    # 导入相关环境变量
    export LDFLAGS="-L${zlib_path}/lib"
    export CPPFLAGS="-I${zlib_path}/include"
    export LUAJIT_LIB=${luajit_path}/lib
    export LUAJIT_INC=${luajit_path}/include/luajit-2.0
fi

# 安装git
if [ $is_install_git = 'y' ]; then
    . ${CURDIR}/scripts/install_git.sh
fi

# 安装php
if [ $is_install_php = 'y' ]; then
    . ${CURDIR}/scripts/install_php.sh
fi

# 安装ruby
if [ $is_install_ruby = 'y' ]; then
    . ${CURDIR}/scripts/install_ruby.sh
fi

# 安装nginx
if [ $is_install_nginx = 'y' ]; then
. ${CURDIR}/scripts/install_nginx.sh
fi

# 安装mysql
if [ $is_install_mysql = 'y' ]; then
    . ${CURDIR}/scripts/install_mysql.sh
fi

# 安装memcache
if [ $is_install_memcache = 'y' ]; then
    . ${CURDIR}/scripts/install_memcache.sh
fi

# 安装ftp
if [ $is_install_ftp = 'y' ]; then
    . ${CURDIR}/scripts/install_ftp.sh
fi

# 安装 php 加速
if [ $is_install_php_accelerate -gt 0 ]; then
    . ${CURDIR}/scripts/install_php_accelerate.sh
fi

# 更新初始化脚本
. ${CURDIR}/scripts/update_init.sh
