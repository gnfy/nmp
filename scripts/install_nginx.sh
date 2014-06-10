#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : nginx安装脚本
 * Filename      : install_nginx.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-05 09:24:17
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_nginx() {

    cd $src_path

    _src_path=${src_path}/nginx-1.6.0
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://nginx.org/download/nginx-1.6.0.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        prefix_path=${nginx_path}
        rm $prefix_path -rf
        mod_path=${install_path}/nginx_modules
        mkdir -p $mod_path
        cd $CURDIR
        # nginx 相关模块
        # 更新模块
        git submodule init
        git submodule update
        git submodule status
        /bin/cp ${CURDIR}/ngx_mod/* $mod_path/ -rf
        cd $_src_path
        add_mod=`find $mod_path/* -maxdepth 0 -type d | sed 's/^/--add-module=/g' | tr "\n" ' '`
        if [ -d $mod_path/ngx_pagespeed ]; then
            cd $mod_path/ngx_pagespeed
            file_url=https://dl.google.com/dl/page-speed/psol/1.8.31.3.tar.gz
            download_file
            file_name=${file_url##*/}
            rm psol -rf
            tar zxf $file_name
            cd $_src_path
        fi
        #./configure --prefix=$prefix_path --user=$web_user --group=$web_group --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --with-pcre=$pcre_path/src --with-zlib=$zlib_path/src --with-openssl=$openssl_path/src --add-module=$mod_path/ngx_devel_kit --add-module=$mod_path/lua-nginx-module --add-module=$mod_path/memc-nginx-module --add-module=$mod_path/srcache-nginx-module --add-module=$mod_path/set-misc-nginx-module --add-module=$mod_path/echo-nginx-module --add-module=$mod_path/redis2-nginx-module --add-module=$mod_path/nginx-gridfs
        #./configure --prefix=$prefix_path --user=$web_user --group=$web_group --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --with-cc-opt="-I${jemalloc_path}/include" --with-ld-opt="-L${jemalloc_path}/lib" --with-pcre=$pcre_src_path --with-zlib=$zlib_src_path --with-openssl=$openssl_src_path $add_mod
        ./configure --prefix=$prefix_path --user=$web_user --group=$web_group --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --with-pcre=$pcre_src_path --with-zlib=$zlib_src_path --with-openssl=$openssl_src_path $add_mod

        make 
        make install

        install_lock "$prefix_path"

        install_lock

        echo -e "\033[32mnginx 安装成功!\033[0m"

        rm $prefix_path/conf/* -rf

        /bin/cp ${CURDIR}/ngx_conf/* $prefix_path/conf/ -rf

        sed -i "s@^user.*@user $web_user;@" $_src_path/conf/nginx.conf

        /bin/cp ${CURDIR}/init/nginx /etc/init.d/nginx -f
        sed -i "s@/usr/local/lnmp/nginx@$prefix_path@g" /etc/init.d/nginx
        chmod u+x /etc/init.d/nginx

        # 内存管理
        sed -i "s@export LD_PRELOAD=.*@export LD_PRELOAD=${jemalloc_path}/lib/libjemalloc.so@" /etc/init.d/nginx

        # 开机自启动
        chkconfig --level 345 nginx on

        # 将init脚本复制到安装目录下
        mkdir -p $prefix_path/init
        /bin/cp /etc/init.d/nginx $prefix_path/init/ -f

        if [ $CPU_num == 1 ];then
            sed -i 's@^worker_processes.*@worker_processes 1;@' $prefix_path/conf/nginx.conf
        elif [ $CPU_num == 2 ];then
            sed -i 's@^worker_processes.*@worker_processes 2;\nworker_cpu_affinity 10 01;@' $prefix_path/conf/nginx.conf
        elif [ $CPU_num == 3 ];then
            sed -i 's@^worker_processes.*@worker_processes 3;\nworker_cpu_affinity 100 010 001;@' $prefix_path/conf/nginx.conf
        elif [ $CPU_num == 4 ];then
            sed -i 's@^worker_processes.*@worker_processes 4;\nworker_cpu_affinity 1000 0100 0010 0001;@' $prefix_path/conf/nginx.conf
        elif [ $CPU_num == 6 ];then
            sed -i 's@^worker_processes.*@worker_processes 6;\nworker_cpu_affinity 100000 010000 001000 000100 000010 000001;@' $prefix_path/conf/nginx.conf
        elif [ $CPU_num == 8 ];then
            sed -i 's@^worker_processes.*@worker_processes 8;\nworker_cpu_affinity 10000000 01000000 00100000 00010000 00001000 00000100 00000010 00000001;@' $prefix_path/conf/nginx.conf
        else
            echo Google worker_cpu_affinity
        fi

        # 分割日志
        cat > /etc/logrotate.d/nginx << EOF
$prefix_path/logs/*nginx.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -e $prefix_path/logs/nginx.pid ] && kill -USR1 \`cat $prefix_path/logs/nginx.pid\`
endscript
}
EOF

        # phpinfo
        cat > $prefix_path/html/info.php << EOF
<?php
phpinfo();
EOF
        # 启动web服务器
        /etc/init.d/nginx start

        # 更改防火墙
        if [ -s /sbin/iptables ]; then
            /sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
            /sbin/iptables-save
        fi

        # 更新删除脚本
        program_path=$prefix_path:/etc/init.d/nginx:/etc/logrotate.d/nginx
        program_name=nginx
        init_uninstall
        
    fi
    
}

install_nginx 2>&1 | tee -a $install_log
