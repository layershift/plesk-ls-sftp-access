<?php

// Copyright 1999-2021. Plesk International GmbH.
class Modules_LsSftpAccess_CustomButtons extends pm_Hook_CustomButtons
{

    public function getButtons()
    {
        $buttons = [ [
            'place' => self::PLACE_ADMIN_TOOLS_AND_SETTINGS,
            'title' => 'SFTP Access for additional FTP users',
            'section' => 'securityPanel-tools-list',
            'order' => 3,
            'description' => 'Description for multi place button',
            'link' => pm_Context::getActionUrl('index', ''),
        ]];

        return $buttons;
    }

}