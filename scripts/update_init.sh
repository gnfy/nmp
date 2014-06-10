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
    # web用户
    sed -i "s@^web_user=.*@web_user=$web_user@" ${CURDIR}/init_nmp.sh
    sed -i "s@^web_group=.*@web_group=$web_group@" ${CURDIR}/init_nmp.sh
    # mysql用户
    sed -i "s@^mysql_user=.*@mysql_user=$mysql_user@" ${CURDIR}/init_nmp.sh
    sed -i "s@^mysql_group=.*@mysql_group=$mysql_group@" ${CURDIR}/init_nmp.sh
    # mysql端口
    sed -i "s@^mysql_port=.*@mysql_port=$mysql_port@" ${CURDIR}/init_nmp.sh
    
    # 添加初始化和卸载程序
    /bin/cp ${CURDIR}/init_nmp.sh $install_path -f
    /bin/cp ${CURDIR}/uninstall.sh $install_path -f
    mkdir -p $install_path/scripts

    # 复制优化脚本
    /bin/cp ${CURDIR}/scripts/optimize_php.sh $install_path/scripts/ -f
    /bin/cp ${CURDIR}/scripts/optimize_mysql.sh $install_path/scripts/ -f
    /bin/cp ${CURDIR}/scripts/optimize_nginx.sh $install_path/scripts/ -f
}

update_init 2>&1 | tee -a $install_log
