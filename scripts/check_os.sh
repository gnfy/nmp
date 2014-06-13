#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 验证操作系统
 * Filename      : check_os.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-13 17:20:46
 * License       : MIT, GPL
 * ********************************************
 */
EOF

if [ -f /etc/redhat-release ];then
    OS=CentOS
elif [ ! -z "`cat /etc/issue | grep bian`" ];then
    OS=Debian
elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
    OS=Ubuntu
else
    echo -e "\033[31m系统不支持 \033[0m"
    kill -9 $$
fi
