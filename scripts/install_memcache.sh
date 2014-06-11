#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : memcache安装脚本
 * Filename      : install_memcache.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-11 21:29:22
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_memcache() {

    cd $src_path

    # libevent
    _src_path=${src_path}/libevent-2.0.21-stable
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=https://github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        prefix_path=${libevent_path}
        rm $prefix_path -rf
        cd $_src_path
        ./configure --prefix=$prefix_path
        make
        make install
        install_lock
    fi

    # memcache
    _src_path=${src_path}/memcached-1.4.20
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://www.memcached.org/files/memcached-1.4.20.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        prefix_path=${memcache_path}
        rm $prefix_path -rf
        cd $_src_path
        ./configure --prefix=$prefix_path --with-libevent={$libevent_path}
        make && make install
        install_lock
    fi
    
}

install_memcache 2>&1 | tee -a $install_log
