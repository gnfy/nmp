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

# 添加相关用户
groupadd $web_group
useradd -s /sbin/nologin -g $web_group $web_user

groupadd $mysql_group
useradd -s /sbin/nologin -g $mysql_group $mysql_user

# 系统服务
/bin/cp $lnmp_path/php5.3/init/php-fpm /etc/init.d/php-fpm -f
/bin/cp $lnmp_path/mysql/init/mysqld /etc/init.d/mysqld -f
/bin/cp $lnmp_path/nginx/init/nginx /etc/init.d/nginx -f

# 开机自启动
chkconfig --level 345 php-fpm on
chkconfig --level 345 mysqld on
chkconfig --level 345 nginx on

# 环境变量
ln -sf $lnmp_path/php5.3/bin/php /usr/local/bin/php
ln -sf $lnmp_path/php5.3/bin/phpize /usr/local/bin/phpize
ln -sf $lnmp_path/mysql/bin/mysql /usr/local/bin/mysql
ln -sf $lnmp_path/mysql/bin/mysqladmin /usr/local/bin/mysqladmin

# lua库
ln -sf $lnmp_path/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2

# nginx日志分割
cat > /etc/logrotate.d/nginx << EOF
$lnmp_path/nginx/logs/*nginx.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -e $lnmp_path/nginx/logs/nginx.pid ] && kill -USR1 \`cat $lnmp_path/nginx/logs/nginx.pid\`
endscript
}
EOF

# 启动
service php-fpm start
service mysqld start
service nginx start
