#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : lnmp 卸载脚本
 * Filename      : uninstall.sh
 * Create time   : 2014-06-04 18:16:56
 * Last modified : 2014-06-08 18:45:39
 * License       : MIT, GPL
 * ********************************************
 */
EOF

[ $(id -u) != "0" ] && echo "请切换到root执行该脚本" && exit 1 

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

arg_num=$#
arg=$@

php=/etc/init.d/php-fpm:/usr/local/lnmp/php5.3:/usr/local/bin/php:/usr/local/bin/phpize
nginx=/etc/init.d/nginx:/usr/local/lnmp/nginx:/etc/logrotate.d/nginx
mysql=/etc/init.d/mysqld:/usr/local/lnmp/mysql:/usr/local/bin/mysql:/usr/local/bin/mysqladmin
progrom_arr=(php nginx mysql)

uninstall() {

    if [  ${#uninstall_progrom[@]} -gt 0 ]; then
        for a in ${uninstall_progrom[@]}; do
            eval info=\$$a
            path_arr=${info//:/ }
            for i in $path_arr; do
                index=`echo $i | grep 'init.d'`
                if [ $index ]; then
                    init_name=${i##*/}

                    if [ -e "$i" ]; then
                        # 取消开机自启动
                        if [ `chkconfig --list | grep $init_name | wc -l` -gt 0 ]; then
                            chkconfig --del $init_name
                        fi

                        # 停止服务
                        if [ pidof $init_name ]; then
                            service $init_name stop
                        fi
                    fi
                fi
                [ -e "$i" ] && rm -rf $i
            done
            echo -e "\033[32m$a卸载完成!\033[0m"
        done
    fi
}

check_arg() {
    if [ $arg_num -gt "0" ]; then
        if [ $arg_num -eq "1" ]; then
            if [ $arg = 'all' ]; then
                uninstall_progrom=${progrom_arr[*]}
            else
                for a in ${progrom_arr[@]}; do
                    if [ $a = $arg ]; then
                        uninstall_progrom=($a)
                        break
                    fi
                done
            fi
        else
            for i in $arg; do
                is_find=0
                for a in ${progrom_arr[@]}; do
                    if [ $a = $i ]; then
                        is_find=1
                        break
                    fi
                done
                if [ $is_find -eq "0" ]; then
                    break
                fi
            done
            if [ $is_find -eq '1' ]; then
                uninstall_progrom=${arg[*]}
            fi
        fi
    else
        uninstall_progrom=${progrom_arr[*]}
    fi
    if [  ${#uninstall_progrom[@]} -eq 0 ]; then
        echo -e "\033[31m参数错误，标准参数 {all|php|nginx|mysql},其中all代表所有程序且不能和其它参数共存 \033[0m"
        kill -9 $$
        exit 1
    fi
    
    # 卸载
    uninstall
}

check_arg
