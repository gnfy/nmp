<?php

$url    = $_POST['url'];

$md5 = md5($url);
    
$cacheFile = '/mnt/fastcgi_cache/' . substr($md5, -1, 1) . '/' . substr($md5, -3, 2) . '/' . $md5;

if (!file_exists($cacheFile)) {
    exit('no cache');
}

if (@unlink($cacheFile)) {
    echo 'clean cache success';
} else {
    echo 'clean cache false';
}
