#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 更新初始化脚本
 * Filename      : update_init.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-10 13:05:02
 * License       : MIT, GPL
 * ********************************************
 */
EOF

update_init() {
    # 程序安装路径
    sed -i "s@^lnmp_path=.*@lnmp_path=$install_path@" ${CURDIR}/init_nmp.sh

    mkdir -p $install_path/scripts

    # web用户
    if [ $is_install_php = 'y' -o $is_install_nginx = 'y' ]; then
        sed -i "s@^web_user=.*@web_user=$web_user@" ${CURDIR}/init_nmp.sh
        sed -i "s@^web_group=.*@web_group=$web_group@" ${CURDIR}/init_nmp.sh

        if [ $is_install_php = 'y' ]; then
            /bin/cp ${CURDIR}/scripts/optimize_php.sh $install_path/scripts/ -f
        fi

        if [ $is_install_nginx = 'y' ]; then
            /bin/cp ${CURDIR}/scripts/optimize_nginx.sh $install_path/scripts/ -f
        fi
    fi
    # mysql用户
    if [ $is_install_mysql = 'y' ]; then
        sed -i "s@^mysql_user=.*@mysql_user=$mysql_user@" ${CURDIR}/init_nmp.sh
        sed -i "s@^mysql_group=.*@mysql_group=$mysql_group@" ${CURDIR}/init_nmp.sh
        # mysql端口
        sed -i "s@^mysql_port=.*@mysql_port=$mysql_port@" ${CURDIR}/init_nmp.sh

        /bin/cp ${CURDIR}/scripts/optimize_mysql.sh $install_path/scripts/ -f
    fi
    
    # 添加初始化和卸载程序
    /bin/cp ${CURDIR}/init_nmp.sh $install_path -f
    /bin/cp ${CURDIR}/uninstall.sh $install_path -f

}

update_init 2>&1 | tee -a $install_log
