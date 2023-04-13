<?php
// Copyright 1999-2016. Parallels IP Holdings GmbH. All Rights Reserved.

class Modules_LsSftpAccess_SimpleList extends pm_Hook_SimpleList
{
    public function isEnabled($controller, $action, $activeList)
    {
        // Modify only domains lists
        return Zend_Controller_Front::getInstance()->getRequest()->getModuleName() === 'smb'
            && ( $controller === 'ftp' && $action === 'users-list');
    }

    public function getDataProvider($controller, $action, $activeList, $data)
    {
        // Do any list filtering
        return $data;
    }

    public function getData($controller, $action, $activeList, $data)
    {
        foreach ($data as &$row) {
            // Add some data for new column
            if ($row['type']!="hosting") {
                try {
                    $res=pm_ApiCli::callSbin('userAction.sh' , array("checkUser", $row['name']));
                    $result=json_decode($res['stdout']);
                    #var_dump($result);
                    if ($result->result==0) {
                        $row['LsSftpAccessCol'] = "<a href='/modules/ls-sftp-access/index.php/index/disable/".$row['name']."'>Disable Access</a>";
                        continue;
                    }
                } catch (pm_Exception $e) {
                    #$row['LsSftpAccessCol']=$e->getMessage();
                    $row['LsSftpAccessCol']="";
                    #go to the next element
                    continue;
                }
                
                $row['LsSftpAccessCol'] = "<a href='/modules/ls-sftp-access/index.php/index/enable/".$row['name']."'>Enable Access</a>";
                
            } else {
                $row['LsSftpAccessCol']="See Web Hosting Access";
            }
        }

        return $data;
    }

    public function getColumns($controller, $action, $activeList)
    {
        return [
            // Add 'Random' column
            'LsSftpAccessCol' => [
                'title' => 'SFTP',
                'noEscape' => true,
            ]
        ];
    }
/*
    public function getColumnsOverride($controller, $action, $activeList)
    {
        return [
            // Change 'Subscriber' column title to 'Owner'
            'ownerName' => [
                'title' => 'Owner',
            ],
            // Hide 'Setup Date' column
            'setupDate' => [
                'isVisible' => false,
            ],
        ];
    }
*/
}