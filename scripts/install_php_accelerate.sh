#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : apcu php 扩展安装脚本
 * Filename      : install_php_accelerate.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-07-17 22:07:14
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_php_accelerate() {
    # 验证php是否安装
    install_lock "$php_path"

    cd $src_path

    if [ $is_install_php_accelerate -eq 1 ];then
        install_php_apcu
    elif [ $is_install_php_accelerate -eq 2 ];then
        install_php_eaccelerator
    elif [ $is_install_php_accelerate -eq 3 ];then
        install_php_opcache
    fi

    service php-fpm reload
}

#php apcu
install_php_apcu() {
    _src_path=${src_path}/apcu-4.0.6
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://pecl.php.net/get/apcu-4.0.6.tgz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        cd $_src_path
        phpize
        ./configure --with-php-config=$php_path/bin/php-config
        make
        /bin/cp modules/*.so $php_path/lib/php/extensions -f
        cat >${php_path}/etc/php.d/apcu.ini<<EOF
[apcu]
extension=apcu.so
apc.enabled=1
apc.shm_size=32M
apc.ttl=7200
apc.enable_cli=1
EOF
        install_lock
        cd ../
    fi
}

#php eaccelerator
install_php_eaccelerator() {
    _src_path=${src_path}/eaccelerator-0.9.6.1
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=https://github.com/downloads/eaccelerator/eaccelerator/eaccelerator-0.9.6.1.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        cd $_src_path
        phpize
        ./configure --enable-eaccelerator=shared --with-php-config=$php_path/bin/php-config
        make
        /bin/cp modules/*.so $php_path/lib/php/extensions -f
        mkdir /var/eaccelerator_cache
        chown -R www.www /var/eaccelerator_cache
        cat >${php_path}/etc/php.d/eaccelerator.ini<<EOF
[eaccelerator]
zend_extension="$php_path/lib/php/extensions/eaccelerator.so"
eaccelerator.shm_size="64"
eaccelerator.cache_dir="/var/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="0"
eaccelerator.shm_prune_period="0"
eaccelerator.shm_only="0"
eaccelerator.compress="0"
eaccelerator.compress_level="9"
eaccelerator.keys = "disk_only"
eaccelerator.sessions = "disk_only"
eaccelerator.content = "disk_only"
EOF
        install_lock
        cd ../
    fi
}

#zend opcache
install_php_opcache() {
    _src_path=${src_path}/zendopcache-7.0.3
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://pecl.php.net/get/zendopcache-7.0.3.tgz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        cd $_src_path
        phpize
        ./configure --with-php-config=$php_path/bin/php-config
        make
        /bin/cp modules/*.so $php_path/lib/php/extensions -f
        cat >${php_path}/etc/php.d/opcache.ini<<EOF
[opcache]
zend_extension="$php_path/lib/php/extensions/opcache.so"
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
EOF
        install_lock
        cd ../
    fi
}

install_php_accelerate 2>&1 | tee -a $install_log
