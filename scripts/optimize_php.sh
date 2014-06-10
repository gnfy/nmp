#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 优化php
 * Filename      : optimize_php.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-10 15:43:25
 * License       : MIT, GPL
 * ********************************************
 */
EOF

optimize_php() {

    ini_file=${php_path}/ect/php.ini

    echo '开始优化php'

    if [ -e $ini_file ]; then

        [ -z $Mem ] && Mem=`free -m | awk '/Mem:/{print $2}'`

        if [ $Mem -gt 1024 -a $Mem -le 1500 ];then
            Memory_limit=192
        elif [ $Mem -gt 1500 -a $Mem -le 3500 ];then
            Memory_limit=256
        elif [ $Mem -gt 3500 -a $Mem -le 4500 ];then
            Memory_limit=320
        elif [ $Mem -gt 4500 ];then
            Memory_limit=448
        else
            Memory_limit=128
        fi
        
        sed -i "s/^memory_limit.*/memory_limit = ${Memory_limit}M/" $ini_file
        sed -i 's/^post_max_size.*/post_max_size = 50M/g' $ini_file
        sed -i 's/^upload_max_filesize.*/upload_max_filesize = 50M/g' $ini_file
        sed -i 's/^;date.timezone.*/date.timezone = PRC/g' $ini_file
        sed -i 's/^short_open_tag.*/short_open_tag = On/g' $ini_file
        sed -i 's/^;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' $ini_file
        sed -i 's/^max_execution_time.*/max_execution_time = 300/g' $ini_file
        sed -i 's/^;upload_tmp_dir.*/upload_tmp_dir = \/tmp/g' $ini_file
        sed -i 's/^mysqlnd.collect_memory_statistics.*/mysqlnd.collect_memory_statistics = On/' $ini_file
        sed -i 's/^disable_functions.*/disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' $ini_file
        if [ -e /usr/sbin/sendmail ]; then
            sed -i 's/^;sendmail_path.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/' $ini_file
        else
            sed -i 's/^sendmail_path.*/;sendmail_path = \/usr\/sbin\/sendmail -t -i/' $ini_file
        fi

        conf_file=${php_path}/etc/php-fpm.conf
        
        if [ -e $conf_file ]; then
            if [ $Mem -le 3000 ];then
                sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/2/20))@" $conf_file
                sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/2/30))@" $conf_file
                sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/2/40))@" $conf_file
                sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/2/20))@" $conf_file
            elif [ $Mem -gt 3000 -a $Mem -le 4500 ];then
                sed -i "s@^pm.max_children.*@pm.max_children = 80@" $conf_file
                sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" $conf_file
                sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" $conf_file
                sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" $conf_file
            elif [ $Mem -gt 4500 -a $Mem -le 6500 ];then
                sed -i "s@^pm.max_children.*@pm.max_children = 90@" $conf_file
                sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" $conf_file
                sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" $conf_file
                sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 90@" $conf_file
            elif [ $Mem -gt 6500 -a $Mem -le 8500 ];then
                sed -i "s@^pm.max_children.*@pm.max_children = 100@" $conf_file
                sed -i "s@^pm.start_servers.*@pm.start_servers = 70@" $conf_file
                sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 60@" $conf_file
                sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 100@" $conf_file
            elif [ $Mem -gt 8500 ];then
                sed -i "s@^pm.max_children.*@pm.max_children = 120@" $conf_file
                sed -i "s@^pm.start_servers.*@pm.start_servers = 80@" $conf_file
                sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 70@" $conf_file
                sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 120@" $conf_file
            fi
        fi

    else
        echo -e "\033[31m${ini_file} 不存在,请确保php已成功安装 \033[0m"
    fi

    echo '优化php结束'
}

optimize_php 2>&1 | tee -a $install_log
