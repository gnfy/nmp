#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 用户添加
 * Filename      : user_add.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-05 09:33:41
 * License       : MIT, GPL
 * ********************************************
 */
EOF

user_add() {
    _user=$1
    _group=$2
    [ -z "$_user" ] && _user=$web_user
    [ -z "$_group" ] && _group=$web_group

    if [ $_user -a $_group ]; then

        has_group=`cat /etc/group | awk -F : '{print $1}' | grep $_group`
        
        [ -z "$has_group" ] && groupadd $_group

        has_user=`cat /etc/passwd | awk -F : '{print $1}' | grep $_user`

        [ -z "$has_user" ] && useradd -s /sbin/nologin -d /dev/null -g $_group $_user

    fi
}

if [ $is_install_nginx = 'y' ]; then
    user_add 2>&1 | tee -a $install_log
fi
if [ $is_install_mysql = 'y' ]; then
    user_add $mysql_user $mysql_group 2>&1 | tee -a $install_log
fi
