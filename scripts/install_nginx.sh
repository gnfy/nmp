#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : nginx安装脚本
 * Filename      : install_nginx.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-20 19:02:03
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_nginx() {

    cd $src_path

    _src_path=${src_path}/nginx-1.6.2
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://nginx.org/download/nginx-1.6.2.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        prefix_path=${nginx_path}
        rm $prefix_path -rf

        add_mod=''
        # 添加模块
        if [ $is_add_nginx_module = 'y' ] ; then
            add_nginx_module
            cd $_src_path
        fi

        ./configure --prefix=$prefix_path --user=$web_user --group=$web_group --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --with-pcre=$pcre_src_path --with-zlib=$zlib_src_path --with-openssl=$openssl_src_path $add_mod

        make 
        make install

        install_lock "$prefix_path"

        install_lock

        echo -e "\033[32mnginx 安装成功!\033[0m"

        rm $prefix_path/conf/* -rf

        /bin/cp ${CURDIR}/ngx_conf/* $prefix_path/conf/ -rf

        sed -i "s@^user.*@user $web_user;@" $_src_path/conf/nginx.conf

        rm /etc/init.d/nginx -f
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

        # 优化nginx
        . ${CURDIR}/scripts/optimize_nginx.sh

        # 分割日志
        cat > /etc/logrotate.d/nginx << EOF
$prefix_path/logs/*.log {
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
        program_path=/etc/init.d/nginx:$prefix_path:/etc/logrotate.d/nginx
        program_name=nginx
        init_uninstall
        
    fi
    
}

# 添加nginx模块
add_nginx_module() {
    mod_path=${install_path}/nginx_modules
    rm $mod_path -rf
    mkdir -p $mod_path
    cd $CURDIR
    no_mod_arr=`echo $no_mod | sed 's/|/ /g'`
    for i in $no_mod_arr; do
        if [ $i ] ; then
            git rm --cached ngx_mod/$i
        fi
    done
    # nginx 相关模块
    # 更新模块
    git submodule init
    git submodule update
    git submodule status
    #/bin/cp ${CURDIR}/ngx_mod/* $mod_path/ -rf
    ls ${CURDIR}/ngx_mod/ | grep -Ev "$no_mod" | xargs -i /bin/cp ${CURDIR}/ngx_mod/{} $mod_path/{} -rf
    add_mod=`find $mod_path/* -maxdepth 0 -type d | sed 's/^/--add-module=/g' | tr "\n" ' '`
    if [ -d $mod_path/ngx_pagespeed ]; then
        cd $mod_path/ngx_pagespeed
        file_url=https://dl.google.com/dl/page-speed/psol/1.8.31.3.tar.gz
        download_file
        file_name=${file_url##*/}
        rm psol -rf
        tar zxf $file_name
    fi
}

if [ $is_install_nginx = 'y' ]; then
    install_nginx 2>&1 | tee -a $install_log
fi
