#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 优化mysql
 * Filename      : optimize_mysql.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-10 16:12:07
 * License       : MIT, GPL
 * ********************************************
 */
EOF

optimize_mysql() {
    conf_file=${mysql_path}/etc/my.cnf
    echo '开始优化mysql'
    if [ -e $conf_file ]; then
        [ -z $Mem ] && Mem=`free -m | awk '/Mem:/{print $2}'`
        if [ $Mem -gt 1500 -a $Mem -le 2500 ];then
            sed -i 's@^thread_cache_size.*@thread_cache_size = 16@' $conf_file
            sed -i 's@^query_cache_size.*@query_cache_size = 16M@' $conf_file
            sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' $conf_file
            sed -i 's@^key_buffer_size.*@key_buffer_size = 16M@' $conf_file
            sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 128M@' $conf_file
            sed -i 's@^tmp_table_size.*@tmp_table_size = 32M@' $conf_file
            sed -i 's@^table_open_cache.*@table_open_cache = 256@' $conf_file
        elif [ $Mem -gt 2500 -a $Mem -le 3500 ];then
            sed -i 's@^thread_cache_size.*@thread_cache_size = 32@' $conf_file
            sed -i 's@^query_cache_size.*@query_cache_size = 32M@' $conf_file
            sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' $conf_file
            sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' $conf_file
            sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 512M@' $conf_file
            sed -i 's@^tmp_table_size.*@tmp_table_size = 64M@' $conf_file
            sed -i 's@^table_open_cache.*@table_open_cache = 512@' $conf_file
        elif [ $Mem -gt 3500 ];then
            sed -i 's@^thread_cache_size.*@thread_cache_size = 64@' $conf_file
            sed -i 's@^query_cache_size.*@query_cache_size = 64M@' $conf_file
            sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' $conf_file
            sed -i 's@^key_buffer_size.*@key_buffer_size = 256M@' $conf_file
            sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 1024M@' $conf_file
            sed -i 's@^tmp_table_size.*@tmp_table_size = 128M@' $conf_file
            sed -i 's@^table_open_cache.*@table_open_cache = 1024@' $conf_file
        fi
    else
        echo -e "\033[31m${conf_file} 不存在,请确保mysql已成功安装 \033[0m"
    fi
    echo '优化mysql结束'
}

optimize_mysql 2>&1 | tee -a $install_log
