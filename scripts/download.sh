#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 下载脚本
 * Filename      : download.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-04 22:39:55
 * License       : MIT, GPL
 * ********************************************
 */
EOF

download_file() {
    [ ! -s "${file_url##*/}" ] && wget -c --no-check-certificate $file_url
    if [ ! -s "${file_url##*/}" ]; then 
        echo -e "\033[31m${file_url##*/} 下载失败,请确保 ${file_url} 有效 \033[0m"
        kill -9 $$
    fi
}
