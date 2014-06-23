#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : mysql安装脚本
 * Filename      : install_mysql.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-06 08:41:26
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_mysql() {

    cd $src_path

    _src_path=${src_path}/mysql-5.6.19
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        #file_url=http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.19-linux-glibc2.5-x86_64.tar.gz
        file_url=http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.19.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        prefix_path=${mysql_path}
        rm $prefix_path -rf
        cd $_src_path
        cmake -DCMAKE_INSTALL_PREFIX=$prefix_path -DSYSCONFDIR=$prefix_path/etc -DMYSQL_DATADIR=$mysql_data_path -DMYSQL_TCP_PORT=$mysql_port -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DMYSQL_USER=$mysql_user -DDEFAULT_CHARSET=utf8 -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_SSL=$openssl_path -DWITH_ZLIB=$zlib_path

        make && make install

        install_lock "$prefix_path"
        
        install_lock

        echo -e "\033[32mmysql 安装成功!\033[0m"

        # 环境变量
        rm -f /usr/bin/mysql
        ln -sf ${prefix_path}/bin/mysql /usr/local/bin/mysql
        ln -sf ${prefix_path}/bin/mysqladmin /usr/local/bin/mysqladmin

        mkdir -p $prefix_path/etc
        rm $prefix_path/my.cnf -f

        cat > $prefix_path/etc/my.cnf << EOF
[client]
port = 3306
socket = /tmp/mysql.sock

[mysqld]
port = 3306
socket = /tmp/mysql.sock

basedir = $prefix_path 
datadir = $mysql_data_path
pid-file = $mysql_data_path/mysql.pid
user = mysql
bind_address = 0.0.0.0
server_id = 1

skip_name_resolve
back_log = 300

max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128 
max_allowed_packet = 4M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M

read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M

thread_cache_size = 8

query_cache_size = 8M
query_cache_limit = 2M

ft_min_word_len = 4

log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 30

log_error = $mysql_data_path/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = $mysql_data_path/mysql-slow.log

performance_schema = 0
explicit_defaults_for_timestamp

skip_external_locking

default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 16M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF

        # 优化mysql
        . ${CURDIR}/scripts/optimize_mysql.sh

        # 初始化数据库
        $prefix_path/scripts/mysql_install_db --user=$mysql_user --basedir=$prefix_path --datadir=$mysql_data_path

        # 改变数据文件夹的属性
        chown ${mysql_user}.${mysql_group} -R $mysql_data_path
        
        # init文件
        rm /etc/init.d/mysqld -f
        /bin/cp support-files/mysql.server /etc/init.d/mysqld
        chmod +x /etc/init.d/mysqld
        mkdir -p $prefix_path/init
        /bin/cp /etc/init.d/mysqld $prefix_path/init/ -f

        #开机自启
        chkconfig --level 345 mysqld on

        # jemalloc 
        sed -i "s@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=${jemalloc_path}/lib/libjemalloc.so@" $prefix_path/bin/mysqld_safe

        #启动mysql
        /etc/init.d/mysqld start

        # 更新数据库配置
        $prefix_path/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$mysql_pwd\" with grant option;"
        $prefix_path/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$mysql_pwd\" with grant option;"
        $prefix_path/bin/mysql -uroot -p$mysql_pwd -e "delete from mysql.user where Password='';"
        $prefix_path/bin/mysql -uroot -p$mysql_pwd -e "delete from mysql.db where User='';"
        $prefix_path/bin/mysql -uroot -p$mysql_pwd -e "delete from mysql.proxies_priv where Host!='localhost';"
        $prefix_path/bin/mysql -uroot -p$mysql_pwd -e "drop database test;"
        $prefix_path/bin/mysql -uroot -p$mysql_pwd -e "reset master;"

        # 更新删除脚本
        program_path=/etc/init.d/mysqld:$prefix_path:/usr/local/bin/mysql:/usr/local/bin/mysqladmin
        program_name=mysql
        init_uninstall

    fi
    
}

install_mysql 2>&1 | tee -a $install_log
