#!/bin/bash

lnmp_path=/usr/local/lnmp

if [ ! -d $lnmp_path ]; then
    echo -e "\033[31m程序目录不存在,请先解压/同步代码\033[0m"
    kill -9 $$
    exit
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
install_log=$lnmp_path/install.log

# 添加相关用户
groupadd $web_group
useradd -s /sbin/nologin -g $web_group $web_user

groupadd $mysql_group
useradd -s /sbin/nologin -g $mysql_group $mysql_user

# 系统服务
/bin/cp $php_path/init/php-fpm /etc/init.d/php-fpm -f
/bin/cp $mysql_path/init/mysqld /etc/init.d/mysqld -f
/bin/cp $nginx_path/init/nginx /etc/init.d/nginx -f

# 开机自启动
chkconfig --level 345 php-fpm on
chkconfig --level 345 mysqld on
chkconfig --level 345 nginx on

# 环境变量
ln -sf $php_path/bin/php /usr/local/bin/php
ln -sf $php_path/bin/phpize /usr/local/bin/phpize
ln -sf $mysql_path/bin/mysql /usr/local/bin/mysql
ln -sf $mysql_path/bin/mysqladmin /usr/local/bin/mysqladmin

# lua库
ln -sf $lnmp_path/lib/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2

# nginx日志分割
cat > /etc/logrotate.d/nginx << EOF
$nginx_path/logs/*nginx.log {
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

# 优化php
. $lnmp_path/scripts/optimize_php.sh
# 优化mysql
. $lnmp_path/scripts/optimize_mysql.sh
# 优化nginx
. $lnmp_path/scripts/optimize_nginx.sh

# 启动
service php-fpm start
service mysqld start
service nginx start

# 更改防火墙
if [ -s /sbin/iptables ]; then
    /sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
    /sbin/iptables -I INPUT -p tcp --dport $mysql_port -j ACCEPT
    /sbin/iptables-save
fi
