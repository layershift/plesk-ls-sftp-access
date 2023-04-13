<?php
// Copyright 1999-2018. Plesk International GmbH.
pm_Loader::registerAutoload();
pm_Context::init('ls-sftp-access');

if (!class_exists('pm_ApiCli')) {
    // NOTE: echoing will cause us to not be able to install!
    echo 'pm_ApiCli not available!' . "\n";
    exit(1);
}
else{
    echo 'pm_ApiCli available!' . "\n";
    //return TRUE;
}

// stop, remove the servie and save server config
try {
    pm_ApiCli::callSbin('uninstall.sh');
} catch (pm_Exception $e) {
    print "Failed to uninstall package: " . $e->getMessage() . "\n";
}

exit(0);
