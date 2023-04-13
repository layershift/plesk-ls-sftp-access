<?php
// Copyright 1999-2016. Parallels IP Holdings GmbH. All Rights Reserved.

class Modules_LsSftpAccess_SystemServices extends pm_Hook_SystemServices
{
    public function getServices()
    {
        return [new Modules_LsSftpAccess_Service()];
    }
}

