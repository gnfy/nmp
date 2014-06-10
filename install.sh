#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : lnmp 安装脚本
 * Filename      : install.sh
 * Create time   : 2014-06-04 18:16:56
 * Last modified : 2014-06-09 18:34:26
 * License       : MIT, GPL
 * ********************************************
 */
EOF

[ $(id -u) != "0" ] && echo "请切换到root执行该脚本" && exit 1 

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

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
is_install_mysql='y'
is_install_git='y'

read -p "是否更新系统(y/n, 默认$is_update_system)?:" is_val
[ $is_val ] && is_update_system=$is_val

read -p "请指定源码存放路径(默认$src_path):" new_path
[ $new_path ] && src_path=$new_path
[ ! -d $src_path ] && mkdir -p $src_path

read -p "请指定安装路径(默认$install_path):" new_path
[ $new_path ] && install_path=$new_path
[ ! -d $install_path ] && mkdir -p $install_path

read -p "是否安装php(y/n, 默认$is_install_php)?:" is_val
[ $is_val ] && is_install_php=$is_val

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
else
    read -p "是否安装git(y/n, 默认$is_install_git)?:" is_val
    [ $is_val ] && is_install_git=$is_val
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
fi

# 相关的路径
php_path=${install_path}/php5.3
nginx_path=${install_path}/nginx
mysql_path=${install_path}/mysql
mysql_data_path=${mysql_path}/data
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
luajit_path=${install_lib_path}/luajit
mhash_path=${install_lib_path}/mhash
openssl_path=${install_lib_path}/openssl
openssl_src_path=${src_path}/openssl-1.0.1g
pcre_path=${install_lib_path}/pcre
pcre_src_path=${src_path}/pcre-8.35
zlib_path=${install_lib_path}/zlib
zlib_src_path=${src_path}/zlib-1.2.8
jemalloc_path=${install_lib_path}/jemalloc

read -p "请指定mysql数据目录(默认$mysql_data_path):" new_path
[ $new_path ] && mysql_data_path=$new_path

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

# 安装nginx
if [ $is_install_nginx = 'y' ]; then
. ${CURDIR}/scripts/install_nginx.sh
fi

# 安装mysql
if [ $is_install_mysql = 'y' ]; then
. ${CURDIR}/scripts/install_mysql.sh
fi
