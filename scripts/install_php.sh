#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : php安装脚本
 * Filename      : install_php.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-05 02:09:58
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_php53() {

    cd $src_path

    _src_path=${src_path}/php-5.3.28
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://cn2.php.net/distributions/php-5.3.28.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        prefix_path=${php_path}
        rm $prefix_path -rf
        cd $_src_path
        ./configure --prefix=${prefix_path} --with-config-file-path=${prefix_path}/etc --with-config-file-scan-dir=${prefix_path}/etc/php.d --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-gd --with-jpeg-dir=${jpeg_path} --with-iconv-dir=${libiconv_path} --with-zlib-dir=${zlib_path} --with-png-dir=${libpng_path} --with-curl=${curl_path} --with-libxml-dir=${libxml2_path} --with-openssl-dir=${openssl_path} --with-mhash=${mhash_path} --with-mcrypt=${libmcrypt_path} --with-freetype-dir=${freetype_path} --enable-shared --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --enable-mbregex --enable-fpm --enable-mbstring=all --enable-gd-native-ttf --enable-pcntl --enable-sockets --enable-zip --enable-soap --with-gettext --enable-exif
        make && make install

        install_lock "$prefix_path"

        install_lock

        echo -e "\033[32mPHP5.3 安装成功!\033[0m"

        # 环境变量
        rm -f /usr/bin/php
        ln -s ${prefix_path}/bin/php /usr/local/bin/php
        ln -s ${prefix_path}/bin/phpize /usr/local/bin/phpize

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

        ini_file=${prefix_path}/etc/php.ini

        /bin/cp php.ini-production ${ini_file}

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
        [ -e /usr/sbin/sendmail ] && sed -i 's/^;sendmail_path.*/sendmail_path = \/usr\/sbin\/sendmail -t -i/' $ini_file

        file_url=http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        download_file
        file_name=${file_url##*/}
        tar zxf $file_name
        /bin/cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so ${prefix_path}/lib/php/

        mkdir -p ${prefix_path}/etc/php.d

cat >${prefix_path}/etc/php.d/ZendGuardLoader.ini<<EOF
[Zend Optimizer] 
zend_extension=$prefix_path/lib/php/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
zend_loader.license_path=
EOF

cat >${prefix_path}/etc/php-fpm.conf<<EOF
[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = notice
emergency_restart_threshold = 30
emergency_restart_interval = 60s 
process_control_timeout = 5s
daemonize = yes

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = $web_user
listen.group = $web_group
listen.mode = 0666
user = $web_user
group = $web_group
pm = dynamic
pm.max_children = 12
pm.start_servers = 8
pm.min_spare_servers = 6
pm.max_spare_servers = 12
pm.max_requests = 2048
pm.process_idle_timeout = 10
request_terminate_timeout = 120
request_slowlog_timeout = 0
slowlog = log/slow.log
EOF

        if [ $Mem -le 3000 ];then
            sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/2/20))@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/2/30))@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/2/40))@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/2/20))@" $prefix_path/etc/php-fpm.conf
        elif [ $Mem -gt 3000 -a $Mem -le 4500 ];then
            sed -i "s@^pm.max_children.*@pm.max_children = 80@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" $prefix_path/etc/php-fpm.conf
        elif [ $Mem -gt 4500 -a $Mem -le 6500 ];then
            sed -i "s@^pm.max_children.*@pm.max_children = 90@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 90@" $prefix_path/etc/php-fpm.conf
        elif [ $Mem -gt 6500 -a $Mem -le 8500 ];then
            sed -i "s@^pm.max_children.*@pm.max_children = 100@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.start_servers.*@pm.start_servers = 70@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 60@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 100@" $prefix_path/etc/php-fpm.conf
        elif [ $Mem -gt 8500 ];then
            sed -i "s@^pm.max_children.*@pm.max_children = 120@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.start_servers.*@pm.start_servers = 80@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 70@" $prefix_path/etc/php-fpm.conf
            sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 120@" $prefix_path/etc/php-fpm.conf
        fi

        /bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm -f
        chmod u+x /etc/init.d/php-fpm

        # 将init脚本复制到安装目录下，方便同步到不同机器
        mkdir -p $prefix_path/init
        /bin/cp /etc/init.d/php-fpm $prefix_path/init/ -f

        # 开机自启
        chkconfig --level 345 php-fpm on
    
        # 启动php-fpm
        /etc/init.d/php-fpm start

        # 更新删除脚本
        program_path=$prefix_path:/etc/init.d/php-fpm:/usr/local/bin/php:/usr/local/bin/phpize
        program_name=php
        init_uninstall

    fi
    
}

install_php53 2>&1 | tee -a $install_log
