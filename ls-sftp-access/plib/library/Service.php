<?php
// Copyright 1999-2016. Parallels IP Holdings GmbH. All Rights Reserved.

class Modules_LsSftpAccess_Service extends pm_SystemService_Service
{

    public function getName()
    {
        return 'Sftp Access - AutoFS';
    }

    public function getId ()
    {
        return 'ls-sftp-access';
    }

    public function onStart()
    {
        $result = pm_ApiCli::callSbin('autofs.serviceControl.sh', ['start']);
        if ($result['code'] !== 0) {
            throw new pm_Exception ('Error occurred when starting Sftp Access - AutoFS.');
        }
    }

    public function onStop()
    {
        $result = pm_ApiCli::callSbin('autofs.serviceControl.sh', ['stop']);
        if ($result['code'] !== 0) {
            throw new pm_Exception ('Error occurred when stopping Sftp Access - AutoFS.');
        }
    }

    public function onRestart()
    {
        $result = pm_ApiCli::callSbin('autofs.serviceControl.sh', ['restart']);
        if ($result['code'] !== 0) {
            throw new pm_Exception ('Error occurred when restarting Sftp Access - AutoFS.');
        }
    }

    public function isRunning()
    {
        $result = pm_ApiCli::callSbin('autofs.serviceControl.sh', ['status']);
        return $result['code'] == 0;
    }

    public function isConfigured()
    {
        $result = pm_ApiCli::callSbin('autofs.serviceControl.sh', ['isconfigured']);
        return $result['code'] == 0;
    }

    public function isInstalled()
    {
        $result = pm_ApiCli::callSbin('autofs.serviceControl.sh', ['isinstalled']);
        return $result['code'] == 0;
    }

}

