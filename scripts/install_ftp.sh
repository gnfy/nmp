#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : ftp安装脚本
 * Filename      : install_ftp.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-07-08 10:56:49
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_ftp() {

    cd $src_path

    # memcache
    _src_path=${src_path}/pure-ftpd-1.0.36
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        prefix_path=${ftp_path}
        rm $prefix_path -rf
        cd $_src_path
        ./configure --prefix=$prefix_path --with-everything
        make && make check && make install
        install_lock "$prefix_path"
        install_lock

        user_add ftpuser ftpuser 2>&1 | tee -a $install_log

        # 配置文件
        mkdir -p $prefix_path/etc
        /bin/cp configuration-file/pure-ftpd.conf $prefix_path/etc/ -f
        sed -i "s@^#.*PureDB\(\s*\)/etc/pureftpd.pdb@PureDB\1$prefix_path/etc/pureftpd.pdb@" $prefix_path/etc/pure-ftpd.conf
        sed -i "s@^MinUID\(\s*100\)@#MinUID\1@" $prefix_path/etc/pure-ftpd.conf
        sed -i "s@^#.*CreateHomeDir\(\s*yes\)@CreateHomeDir\1@" $prefix_path/etc/pure-ftpd.conf
        chmod 744 $prefix_path/etc/pure-ftpd.conf

        # 启动脚本
        mkdir -p $prefix_path/init
        /bin/cp contrib/redhat.init $prefix_path/init/pureftpd -f
        sed -i "s@/etc/pure-ftpd.conf@\$confpath@" $prefix_path/init/pureftpd 
        sed -i "s@^pureftpwho=\(.*\)@pureftpwho=\1\nconfpath=$prefix_path/etc/pure-ftpd.conf@" $prefix_path/init/pureftpd
        sed -i "s@^fullpath=.*@fullpath=$prefix_path/sbin/\$prog@" $prefix_path/init/pureftpd
        sed -i "s@^pureftpwho=.*@pureftpwho=$prefix_path/sbin/pure-ftpwho@" $prefix_path/init/pureftpd
        chmod u+x $prefix_path/init/pureftpd
        /bin/cp $prefix_path/init/pureftpd /etc/init.d/pureftpd -f
        /bin/cp configuration-file/pure-config.pl $prefix_path/sbin/ -f
        chmod u+x $prefix_path/sbin/pure-config.pl
        sed -i "s@\${exec_prefix}@$prefix_path@" $prefix_path/sbin/pure-config.pl
        
        # 开机自启动
        chkconfig --level 345 pureftpd on

        # 环境变量
        ln -sf $prefix_path/bin/pure-pw  /usr/local/bin/pure-pw

        # 防火墙
        iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
        iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
        service iptables save

        # 启动ftp
        service pureftpd start

        echo -e "\033[32mpureftp 安装成功!\033[0m"
        cd ../
    fi
}

install_ftp 2>&1 | tee -a $install_log
