#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 安装状态
 * Filename      : install_status.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-05 00:46:02
 * License       : MIT, GPL
 * ********************************************
 */
EOF

# 检测安装
check_install() {
    check_path=$1
    [ -z "$check_path" ] && check_path=$_src_path
    lock_file=${check_path}'/lnmp.install.lock'
    [ -f $lock_file ] && echo 1 || echo 0
}

# 安装锁定
install_lock() {
    check_path=$1
    [ -z "$check_path" ] && check_path=$_src_path
    if [ -d $check_path ]; then
        lock_file=${check_path}'/lnmp.install.lock'
        echo 1 > $lock_file
    else
        echo -e "\033[31m${check_path} 安装失败 \033[0m"
        kill -9 $$
        exit
    fi
}

# 初始化卸载
init_uninstall() {
    p_name=$1
    p_path=$2
    [ -z "$p_name" ] && p_name=$program_name
    [ -z "$p_path" ] && p_path=$program_path

   sed -i "s@^$p_name=.*@$p_name=$p_path@" $CURDIR/uninstall.sh

}
