#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 更新系统
 * Filename      : update_system.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-04 19:35:41
 * License       : MIT, GPL
 * ********************************************
 */
EOF

update_system() {

    repos_path='/etc/yum.repos.d/CentOS-Base.repo'

    num=`cat $repos_path | grep aliyun | wc -l`

    if [ $num -eq "0" ]; then
        /bin/cp $repos_path ${repos_path}'.bak' -f
        curl http://mirrors.aliyun.com/repo/Centos-6.repo > $repos_path
        yum makecache
    fi

    isaliyunvps="n"
    read -p '是否阿里云主机(y/n)? ' isaliyunvps
    case "$isaliyunvps" in
    y|Y|Yes|YES|yes|yES|yEs|YeS|yeS) isaliyunvps="y";;  
    n|N|No|NO|no|nO) isaliyunvps="n" ;;  
    *) isaliyunvps="n";;
    esac
    
    if [ $isaliyunvps = "y" ]; then
        # 替换为阿里云内网源
        sed -i 's/mirrors.aliyun.com/mirrors.aliyuncs.com/g' $repos_path
    fi

    yum update -y

    # 安装相关的编译工具
    yum install gcc gcc-c++ vim wget autoconf libtool make cmake python-devel perl-devel ncurses-devel -y

}

update_system 2>&1 | tee -a $install_log
