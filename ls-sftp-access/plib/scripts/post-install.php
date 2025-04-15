<?php
// Copyright 1999-2018. Plesk International GmbH.
pm_Loader::registerAutoload();
pm_Context::init('ls-sftp-access');
$isUpgrade=0;
$isUpgradeVersion="1.0";

    file_put_contents(pm_Context::getVarDir()."debug.log", date(DATE_RFC2822)."\n", FILE_APPEND);


if (isset($argv)) {
    file_put_contents(pm_Context::getVarDir()."debug.log", '$argv='.implode(',',$argv)."\n", FILE_APPEND);
    foreach ($argv as $_key=>$_arg) {
        if ($_arg=="upgrade") {
            $isUpgrade=1;
            $isUpgradeVersion=$argv[$_key+1];
        }
    }
}

    file_put_contents(pm_Context::getVarDir()."debug.log", '$isUpgrade='.$isUpgrade."\n", FILE_APPEND);
    file_put_contents(pm_Context::getVarDir()."debug.log", '$isUpgradeVersion='.$isUpgradeVersion."\n", FILE_APPEND);


if (!class_exists('pm_ApiCli')) {
    // NOTE: echoing will cause us to not be able to install!
    echo 'pm_ApiCli not available!' . "\n";
    exit(1);
}
else{
    echo 'pm_ApiCli available!' . "\n";
    //return TRUE;
}

    file_put_contents(pm_Context::getVarDir()."debug.log", 'executing installer.sh ...'."\n", FILE_APPEND);
// call install script
try {
    pm_ApiCli::callSbin('installer.sh' , array("$isUpgrade", "$isUpgradeVersion"));
} catch (pm_Exception $e) {
    print "Failed to install dependencies: " . $e->getMessage() . "\n";
    exit;
}
    file_put_contents(pm_Context::getVarDir()."debug.log", 'done'."\n", FILE_APPEND);



    file_put_contents(pm_Context::getVarDir()."debug.log", 'executing provision.sh ...'."\n", FILE_APPEND);
    // call provision script
    try {
        pm_ApiCli::callSbin('provision.sh');
    } catch (pm_Exception $e) {
        print "Failed to provision the extension: " . $e->getMessage() . "\n";
        exit;
    }
    file_put_contents(pm_Context::getVarDir()."debug.log", 'done'."\n", FILE_APPEND);

    

exit(0);
