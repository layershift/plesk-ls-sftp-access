<?php

class IndexController extends pm_Controller_Action
{
    protected $_accessLevel = 'admin';

    public function init()
    {
        parent::init();

        if (!pm_Session::getClient()->isAdmin()) 
        {
            throw new pm_Exception('Permission denied');
        }
        /** @noinspection PhpUndefinedFieldInspection */
        $this->view->pageTitle = $this->lmsg('pageTitle');
    }

    public function indexAction()
    {
        $this->view->tabs = $this->_getTabs();

        $out="<table>";
        $out.="<tr><td>SFTP for additional FTP users.<br> Version: 1.0.76</td></tr>";
        $out.="</table>";
        $this->view->service_status=$out;

    }

    public function enableAction()
    {
        $HTTP_HOST=$this->getRequest()->get('HTTP_HOST');
        $HTTP_REFERER=$this->getRequest()->get('HTTP_REFERER');
        $BACK_URL=preg_replace("/.*$HTTP_HOST/i","",$HTTP_REFERER);

        if ($this->getRequest()->isPost()) {
            #parse if data sent via POST
        } elseif ($this->getRequest()->isGet()) {
            $REQUEST_URI=$this->getRequest()->get('REQUEST_URI');
            #$parts=explode("/",str_replace("/modules/ls-sftp-access/index.php/index/","",$REQUEST_URI));
            $parts=explode("/",preg_replace(array("|/modules/ls-sftp-access/index.php/index/|","|\?.*$|"),"",$REQUEST_URI));
            
            $action=$parts[0];
            $username=$parts[1];

        } else {
            $this->_status->addMessage('error', "Unknown method\n");
            $this->getResponse()->setRedirect($BACK_URL);
        }

        try {
            $res=pm_ApiCli::callSbin('userAction.sh' , array("userAdd", $username));
            $result=json_decode($res['stdout']);
            if ($result->result==0) {
                $this->_status->addMessage('info', "Enabled SFTP access for $username");
            } else {
                $this->_status->addMessage('error', "Failed to enable SFTP access for $username"."\n".$res['stdout']);
            }
        } catch (pm_Exception $e) {
            $this->_status->addMessage('error', "Failed Failed to execute action\n". $e->getMessage()."\n".$res['stdout']);
        }

        $this->getResponse()->setRedirect($BACK_URL);
    }

    public function disableAction()
    {
        $HTTP_HOST=$this->getRequest()->get('HTTP_HOST');
        $HTTP_REFERER=$this->getRequest()->get('HTTP_REFERER');
        $BACK_URL=preg_replace("/.*$HTTP_HOST/i","",$HTTP_REFERER);

        if ($this->getRequest()->isPost()) {
            #parse if data sent via POST
        } elseif ($this->getRequest()->isGet()) {
            $REQUEST_URI=$this->getRequest()->get('REQUEST_URI');
            #$parts=explode("/",str_replace("/modules/ls-sftp-access/index.php/index/","",$REQUEST_URI));
            $parts=explode("/",preg_replace(array("|/modules/ls-sftp-access/index.php/index/|","|\?.*$|"),"",$REQUEST_URI));
            
            $action=$parts[0];
            $username=$parts[1];

        } else {
            $this->_status->addMessage('error', "Unknown method\n");
            $this->getResponse()->setRedirect($BACK_URL);
        }

        try {
            $res=pm_ApiCli::callSbin('userAction.sh' , array("userRemove", $username));
            $result=json_decode($res['stdout']);
            if ($result->result==0) {
                $this->_status->addMessage('info', "Disabled SFTP access for $username");
            } else {
                $this->_status->addMessage('error', "Failed to disable SFTP access for $username"."\n".$res['stdout']);
            }
        } catch (pm_Exception $e) {
            $this->_status->addMessage('error', "Failed to execute action\n". $e->getMessage()."\n".$res['stdout']);
        }

        $this->getResponse()->setRedirect($BACK_URL);
    }


    public function usersAction()
    {
        $this->view->tools = [
/*
            [
                        'icon' => '/cp/theme/icons/16/plesk/toolbar-add.png',
                        'title' => $this->lmsg('UsersButtonAdd'),
                        'description' => $this->lmsg('UsersButtonAddHint'),
                        'link' => "{$this->_helper->url('users-add')}",
                    ],
                     [
                        'icon' => '/theme/icons/32/plesk/refresh.png',
                        'title' => $this->lmsg('syncAllButton'),
                        'description' => $this->lmsg('syncAllHint'),
                        'link' => "javascript:Modules_MyVpn_Confirm('{$this->_helper->url('sync-all')}', 'confirm', '{$this->lmsg('syncAllConfirm')}')",
                    ], [
                        'icon' => '/theme/icons/32/plesk/remove-selected.png',
                        'title' => $this->lmsg('removeAllButton'),
                        'description' => $this->lmsg('removeAllHint'),
                        'link' => "javascript:Modules_MyVpn_Confirm('{$this->_helper->url('remove-all')}', 'delete', '{$this->lmsg('removeAllConfirm')}')",
                    ],
*/
                    ];
        $this->view->tabs = $this->_getTabs(2);
        $this->view->list = new Modules_LsSftpAccess_List_Users($this->view, $this->getRequest());
    }



    private function _getTabs($setActiveTab=-1)
    {
        $tabs = [];
        $tabs[] = [
                    'id' => $setActiveTab,
                    'title' => $this->lmsg('indexLabel'),
                    'action' => 'index',
                    'active' => ( $setActiveTab==1 ? true : false),
                ];
        
        $tabs[] = [
                    'title' => $this->lmsg('usersLabel'),
                    'action' => 'users',
                    'active' => ( $setActiveTab==2 ? true : false),
                    
                ];
        /*
        $tabs[] = [
                    'title' => $this->lmsg('toolsTitle'),
                    'action' => 'tools',
                    'active' => ( $setActiveTab==3 ? true : false),
                ];
        $tabs[] = [
                    'title' => $this->lmsg('settingsLabel'),
                    'action' => 'settings',
                    'active' => ( $setActiveTab==0 ? true : false),
                ];
        */

        return $tabs;
    }

}
