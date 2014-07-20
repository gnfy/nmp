#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : ruby安装脚本
 * Filename      : install_ruby.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-07-20 14:52:02
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_ruby() {

    cd $src_path

    _src_path=${src_path}/yaml-0.1.6
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://pyyaml.org/download/libyaml/yaml-0.1.6.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        prefix_path=${yaml_path}
        rm $prefix_path -rf
        cd $_src_path
        ./configure --prefix=${prefix_path}
        make && make install

        install_lock "$prefix_path"

        install_lock
        
        cd ../

    fi
    
    _src_path=${src_path}/ruby-2.1.2
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://ftp.ruby-lang.org/pub/ruby/ruby-2.1.2.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        prefix_path=${ruby_path}
        rm $prefix_path -rf
        cd $_src_path
        ./configure --prefix=${prefix_path}
        make && make install

        install_lock "$prefix_path"

        install_lock

        echo -e "\033[32mruby 安装成功!\033[0m"

    fi
}

install_ruby 2>&1 | tee -a $install_log
