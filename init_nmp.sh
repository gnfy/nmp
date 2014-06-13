#!/bin/bash

lnmp_path=/usr/local/lnmp

if [ ! -d $lnmp_path ]; then
    echo -e "\033[31m{$lnmp_path}程序目录不存在,请先解压/同步代码\033[0m"
    kill -9 $$
    exit
fi

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

cd $lnmp_path

web_user=www
web_group=www

mysql_user=mysql
mysql_group=mysql
mysql_port=3306

php_path=$lnmp_path/php5.3
nginx_path=$lnmp_path/nginx
mysql_path=$lnmp_path/mysql
mysql_data_path=$lnmp_path/mysql/data
install_log=$lnmp_path/install.log

# 添加相关用户
if [ -d $php_path -o -d $nginx_path ]; then
    groupadd $web_group
    useradd -s /sbin/nologin -g $web_group $web_user
fi

if [ -d $mysql_path ]; then
    groupadd $mysql_group
    useradd -s /sbin/nologin -g $mysql_group $mysql_user
    chown $mysql_user.$mysql_group -R $mysql_data_path
fi

# 系统服务 开机自启 环境变量
if [ -d $php_path ]; then
    /bin/cp $php_path/init/php-fpm /etc/init.d/php-fpm -f
    if [ $OS = 'CentOS' ]; then
        chkconfig --level 345 php-fpm on
    else
        update-rc.d php-fpm defaults
    fi
    ln -sf $php_path/bin/php /usr/local/bin/php
    ln -sf $php_path/bin/phpize /usr/local/bin/phpize
    # 优化php
    . $lnmp_path/scripts/optimize_php.sh
    
    service php-fpm start
fi

if [ -d $mysql_path ]; then
    /bin/cp $mysql_path/init/mysqld /etc/init.d/mysqld -f
    if [ $OS = 'CentOS' ]; then
        chkconfig --level 345 mysqld on
    else
        update-rc.d mysqld defaults
    fi
    ln -sf $mysql_path/bin/mysql /usr/local/bin/mysql
    ln -sf $mysql_path/bin/mysqladmin /usr/local/bin/mysqladmin
    # 优化mysql
    . $lnmp_path/scripts/optimize_mysql.sh

    service mysqld start
    
    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp --dport $mysql_port -j ACCEPT
        /sbin/iptables-save
    fi
fi

if [ -d $nginx_path ]; then
    if [ $OS = 'CentOS' ]; then
        /bin/cp $nginx_path/init/nginx /etc/init.d/nginx -f
        chkconfig --level 345 nginx on
    else
        /bin/cp $nginx_path/init/nginx_ubuntu /etc/init.d/nginx -f
        update-rc.d nginx defaults
    fi
    # lua库
    if [ $OS = 'CentOS' ]; then
        ln -sf $lnmp_path/lib/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
    else
        ln -sf $lnmp_path/lib/luajit/lib/libluajit-5.1.so.2 /lib/libluajit-5.1.so.2
    fi
    # 日志分割
    cat > /etc/logrotate.d/nginx << EOF
$nginx_path/logs/*.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -e $nginx_path/logs/nginx.pid ] && kill -USR1 \`cat $nginx_path/logs/nginx.pid\`
endscript
}
EOF

    # 优化nginx
    . $lnmp_path/scripts/optimize_nginx.sh

    service nginx start

    if [ -s /sbin/iptables ]; then
        /sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
        /sbin/iptables-save
    fi

fi
