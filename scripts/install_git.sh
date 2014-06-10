#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : git安装脚本
 * Filename      : install_git.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-05 10:44:33
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_git() {
    yum install git -y
:<<EOF
    cd $src_path

    _src_path=${src_path}/git-2.0.0
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        yum install gettext-devel
        file_url=https://github.com/git/git/archive/v2.0.0.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        prefix_path=${install_path}/git
        rm $prefix_path -rf
        cd $_src_path
        make configure
        ./configure --prefix=$prefix_path --with-iconv=$libiconv_path --with-zlib=$zlib_path --with-curl=$curl_path --with-libpcre=$pcre_path
    fi
EOF
    
}

install_git 2>&1 | tee -a $install_log
