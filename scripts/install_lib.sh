#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 安装相关组件
 * Filename      : install_lib.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-05 02:09:49
 * License       : MIT, GPL
 * ********************************************
 */
EOF

install_lib() {

    cd $src_path

    echo '开始安装相关依赖包'

    #zlib
    install_lib_process
    _src_path=${src_path}'/zlib-1.2.8'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://cznic.dl.sourceforge.net/project/libpng/zlib/1.2.8/zlib-1.2.8.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        cd $_src_path
        prefix_path=${zlib_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path
        make && make install
        install_lock
        # 复制源码编译nginx
        cd ../
    fi
    export LDFLAGS="-L${zlib_path}/lib"
    export CPPFLAGS="-I${zlib_path}/include"
    
    #mhash
    install_lib_process
    _src_path=${src_path}'/mhash-0.9.9.9'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://nchc.dl.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        cd $_src_path
        prefix_path=${mhash_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path
        make && make install
        install_lock
        cd ../
    fi

    #libmcrypt
    install_lib_process
    _src_path=${src_path}'/libmcrypt-2.5.8'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://nchc.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        cd $_src_path
        prefix_path=${libmcrypt_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path
        make && make install && cd libltdl
        ./configure --prefix=$prefix_path --enable-ltdl-install
        make && make install && cd ../
        install_lock
        cd ../
    fi

    #libpng
    install_lib_process
    _src_path=${src_path}'/libpng-1.6.10'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://ncu.dl.sourceforge.net/project/libpng/libpng16/1.6.10/libpng-1.6.10.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        cd $_src_path
        prefix_path=${libpng_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path
        make && make install
        install_lock
        cd ../
    fi

    #jpeg
    install_lib_process
    _src_path=${src_path}'/jpeg-9a'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://www.ijg.org/files/jpegsrc.v9a.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        cd $_src_path
        prefix_path=${jpeg_path}
        rm $prefix_path
        ./configure --prefix=$prefix_path --enable-shared --enable-static
        make && make install
        install_lock
        cd ../
    fi

    #libiconv
    install_lib_process
    _src_path=${src_path}'/libiconv-1.14'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        cd $_src_path
        prefix_path=${libiconv_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path
        make && make install
        install_lock
        cd ../
    fi

    #freetype
    install_lib_process
    _src_path=${src_path}'/freetype-2.5.3'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://iweb.dl.sourceforge.net/project/freetype/freetype2/2.5.3/freetype-2.5.3.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        cd $_src_path
        prefix_path=${freetype_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path --enable-shared
        make && make install
        # 修复编译时检测文件出错
        mkdir -p $prefix_path'/include/freetype2/freetype'
        rm $prefix_path'/include/freetype2/freetype/*' -rf
        /bin/cp ${prefix_path}/include/freetype2/*.h ${prefix_path}/include/freetype2/freetype/ -rf
        /bin/cp ${prefix_path}/include/freetype2/config ${prefix_path}/include/freetype2/freetype/ -rf
        install_lock
        cd ../
    fi

    #libxml2
    install_lib_process
    _src_path=${src_path}'/libxml2-2.9.1'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=ftp://xmlsoft.org/libxml2/libxml2-2.9.1.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        cd $_src_path
        prefix_path=${libxml2_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path --with-iconv=${libiconv_path} --with-zlib=${zlib_path}
        make && make install
        install_lock
        cd ../
    fi

    #openssl
    install_lib_process
    _src_path=$openssl_src_path
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://www.openssl.org/source/openssl-1.0.1h.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        cd $_src_path
        prefix_path=${openssl_path}
        rm $prefix_path -rf
        ./config --prefix=$prefix_path -shared
        make && make install
        install_lock
        cd ../
        #升级openssl修补heartbleed漏洞'
        mv /usr/bin/openssl /usr/bin/openssl.old
        mv /usr/include/openssl /usr/include/openssl.old
        ln -sf ${prefix_path}/bin/openssl /usr/bin/openssl
        ln -sf ${prefix_path}/include/openssl/ /usr/include/openssl
        echo "${prefix_path}/lib/" >> /etc/ld.so.conf
        ldconfig
    fi

    #curl
    install_lib_process
    _src_path=${src_path}'/curl-7.37.0'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://curl.haxx.se/download/curl-7.37.0.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        cd $_src_path
        prefix_path=${curl_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path --with-ssl=$openssl_path
        make && make install
        install_lock
        cd ../
    fi
    
    #pcre
    install_lib_process
    _src_path=${pcre_src_path}
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.35.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        cd $_src_path
        prefix_path=${pcre_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path
        make && make install
        install_lock
        cd ../
    fi

    #luajit
    install_lib_process
    _src_path=${src_path}'/LuaJIT-2.0.3'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://luajit.org/download/LuaJIT-2.0.3.tar.gz
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar zxf $file_name
        cd $_src_path
        prefix_path=${luajit_path}
        rm $prefix_path -rf
        make PREFIX=$prefix_path && make install PREFIX=$prefix_path
        ln -sf $prefix_path/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
        install_lock
        cd ../
    fi

    #jemalloc
    install_lib_process
    _src_path=${src_path}'/jemalloc-3.6.0'
    install_status=$(check_install)
    if [ $install_status -eq "0" ]; then
        file_url=http://www.canonware.com/download/jemalloc/jemalloc-3.6.0.tar.bz2
        download_file
        file_name=${file_url##*/}
        rm $_src_path -rf
        tar jxf $file_name
        cd $_src_path
        prefix_path=${jemalloc_path}
        rm $prefix_path -rf
        ./configure --prefix=$prefix_path
        make && make install
        install_lock
        cd ../
    fi

}

now_num=0
install_lib_process() {
    sum_lib_num=13
    (( now_num++ ))
    echo "正在安装${now_num}/${sum_lib_num}"
}

install_lib 2>&1 | tee -a $install_log
