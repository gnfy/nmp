#!/bin/bash
:<<EOF
/**
 * ********************************************
 * Description   : 优化nginx
 * Filename      : optimize_nginx.sh
 * Create time   : 2014-06-04 18:43:25
 * Last modified : 2014-06-10 15:06:51
 * License       : MIT, GPL
 * ********************************************
 */
EOF

optimize_nginx() {
    conf_file=${nginx_path}/conf/nginx.conf
    echo '开始优化nginx'
    if [ -e $conf_file ]; then
        [ -z $CPU_num ] && CPU_num=`cat /proc/cpuinfo | grep processor | wc -l`
        has_worker_cpu=`sed -n '/worker_cpu_affinity/p' $conf_file | wc -l`
        if [ $has_worker_cpu -eq "0" ]; then
            if [ $CPU_num -eq "1" ];then
                sed -i 's@^worker_processes.*@worker_processes 1;@' $conf_file
            elif [ $CPU_num -ge "2" -a $CPU_num -lt "4" ];then
                sed -i 's@^worker_processes.*@worker_processes 2;\nworker_cpu_affinity 10 01;@' $conf_file
            elif [ $CPU_num -ge "4" -a $CPU_num -lt "8" ];then
                sed -i 's@^worker_processes.*@worker_processes 4;\nworker_cpu_affinity 1000 0100 0010 0001;@' $conf_file
            elif [ $CPU_num -ge 8 ];then
                sed -i 's@^worker_processes.*@worker_processes 8;\nworker_cpu_affinity 10000000 01000000 00100000 00010000 00001000 00000100 00000010 00000001;@' $conf_file
            fi
        else
            if [ $CPU_num -eq "1" ];then
                sed -i 's@^worker_processes.*@worker_processes 1;@' $conf_file
                sed -i 's@^worker_cpu_affinity.*@@' $conf_file
            elif [ $CPU_num -ge "2" -a $CPU_num -lt "4" ];then
                sed -i 's@^worker_processes.*@worker_processes 2;@' $conf_file
                sed -i 's@^worker_cpu_affinity.*@worker_cpu_affinity 10 01;@' $conf_file
            elif [ $CPU_num -ge "4" -a $CPU_num -lt "8" ];then
                sed -i 's@^worker_processes.*@worker_processes 4;@' $conf_file
                sed -i 's@^worker_cpu_affinity.*@worker_cpu_affinity 1000 0100 0010 0001;@' $conf_file
            elif [ $CPU_num -ge 8 ];then
                sed -i 's@^worker_processes.*@worker_processes 8;@' $conf_file
                sed -i 's@^worker_cpu_affinity.*@worker_cpu_affinity 10000000 01000000 00100000 00010000 00001000 00000100 00000010 00000001;@' $conf_file
            fi
        fi
    else
        echo -e "\033[31m${conf_file} 不存在,请确保nginx已成功安装 \033[0m"
    fi
    echo '优化nginx结束'
}

optimize_nginx 2>&1 | tee -a $install_log
