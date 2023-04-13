<?php
// Copyright 1999-2018. Plesk International GmbH.
class Modules_LsSftpAccess_List_Users extends pm_View_List_Simple
{
    public function __construct($view, $request, $options = [])
    {
        parent::__construct($view, $request, $options);

        $this->setColumns([
            'username' => [
                'title' => $this->lmsg('UsersColumnUsername'),
                'noEscape' => true,
                'searchable' => false,
                'sortable' => false,
            ],
            'website' => [
                'title' => $this->lmsg('UsersColumnWebsite'),
                'noEscape' => true,
                'searchable' => false,
                'sortable' => false,
            ],
            'date' => [
                'title' => $this->lmsg('UsersColumnDateEnabled'),
                'noEscape' => true,
                'searchable' => false,
                'sortable' => false,
            ],
            'actions' => [
                'title' => $this->lmsg('UsersColumnActions'),
                'noEscape' => true,
                'searchable' => false,
                'sortable' => false,
            ],
        ]);

        $this->setData($this->_getRecords($view));
    }

    private function _getRecords($view)
    {
        $data = [];
        try {
            $rawData=pm_ApiCli::callSbin('userAction.sh' , array("userList"));
        } catch (pm_Exception $e) {
            print "Failed to get data from the CLI tool: " . $e->getMessage() . "\n";
        }
        //var_dump($rawData);

        if ($rawData["code"]==0) {
            $rawData_=json_decode($rawData["stdout"]);

            foreach ($rawData_->data as $userData) {
                $mapped_to=pm_Bootstrap::getDbAdapter()->fetchOne("SELECT mapped_to FROM sys_users WHERE login = '".$userData->user."'");
                if ($mapped_to=="") {
                    $sys_user_id=pm_Bootstrap::getDbAdapter()->fetchOne("SELECT id FROM sys_users WHERE login = '".$userData->user."'");
                } else {
                    $sys_user_id=pm_Bootstrap::getDbAdapter()->fetchOne("SELECT id FROM sys_users WHERE id = '".$mapped_to."'");
                }
                if ((int)$mapped_to>0) {
                    $domain_id=(int)pm_Bootstrap::getDbAdapter()->fetchOne("SELECT dom_id FROM hosting WHERE sys_user_id=".$sys_user_id.";");
                    if ($domain_id>0){
                        $domain_name="<a href='/smb/web/overview/id/".$domain_id."/type/domain'>".
                                        pm_Bootstrap::getDbAdapter()->fetchOne("SELECT domains.name FROM hosting left JOIN domains on dom_id=id WHERE hosting.sys_user_id=".$sys_user_id.";").
                                     "</a>";
                    } else {
                        $domain_name="N/A";
                    }
                    
                    
                } else {
                    $domain_id="";
                    $domain_name="N/A";
                }
                $data[] = [
                    'username' => $userData->user,
                    'website' => $domain_name,
                    'date' => date('r', $userData->date),
                    'actions' => implode(" ", [

                            "<form method='get' action='{$view->url(['action' => 'disable'])}/$userData->user'>",
                            "<a class='s-btn sb-delete' href='#' onclick='var r = confirm(\"".$this->lmsg('UsersButtonDisableUserConfirm')."\"); if (r==true){ this.parentNode.submit();}else { return false;}'>".
                            "<span>". $this->lmsg('UsersButtonDisableUser') ."</span>".
                            "</a>",
                            "</form>" ,
                            
#                            "<a class='s-btn sb-edit' data-method='post'".
#                            "href='{$view->url(['action' => 'users-edit'])}/username/".$userRow[0]."'>".
#                            "<span>". $this->lmsg('UsersButtonEditUser') ."</span>".
#                            "</a>",
#                            "</form>",
#                            "<a class='s-btn sb-delete' data-method='post'".
#                            "href='{$view->url(['action' => 'users-del'])}/username/".$userRow[0]."'>".
#                            "<span>". $this->lmsg('UsersButtonDeleteUser') ."</span>".
#                            "</a>",
                        ])
                    
                ];
            }
        }

        return $data;
    }

}
