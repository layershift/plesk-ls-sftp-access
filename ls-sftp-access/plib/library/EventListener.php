<?php
class Modules_LsSftpAccess_EventListener implements EventListener
{
    public function filterActions()
    {
        return json_decode(pm_Settings::get('actions', '[]'), true);
    }

    public function handleEvent($objectType, $objectId, $action, $oldValue, $newValue)
    {
        
        #pm_Log::info('Handle event: {'.$action.'}');
        #pm_Log::info('Object Id: ' . var_export($objectId, true));
        #pm_Log::info('Old value: ' . var_export($oldValue, true));
        #pm_Log::info('New value: ' . var_export($newValue, true));
        
        if ($action == 'ftpuser_update') {
            if ( is_array($oldValue) and is_array($newValue) ) {
                if ( $oldValue['Home Directory']!=$newValue['Home Directory'] and $oldValue['Home Directory']!="" and $newValue['Home Directory']!="" ) {
                    $success=true;
                    try {
                        $res=pm_ApiCli::callSbin('userAction.sh' , array("userRemove", $oldValue['System User']));
                    } catch (pm_Exception $e) {
                        pm_Log::info("Failed to execute action \n".$e->getMessage()."\n".$res['stdout']);
                        $success=false;
                    }
                    try {
                        $res=pm_ApiCli::callSbin('userAction.sh' , array("userAdd", $newValue['System User']));
                    } catch (pm_Exception $e) {
                        pm_Log::info("Failed to execute action \n".$e->getMessage()."\n".$res['stdout']);
                        $success=false;
                    }
                    if ( $success == true ) {
                        pm_Log::info("Updated SFTP access for ".$newValue['System User']);
                    }
                }
            }    
        }
        if ($action == 'ftpuser_delete') {
            if ( is_array($oldValue) ) {
                try {
                    $res=pm_ApiCli::callSbin('userAction.sh' , array("userRemove", $oldValue['System User']));
                    pm_Log::info($newValue['System User']." was removed. Also Removed if from the SFTP dataStore");
                } catch (pm_Exception $e) {
                    pm_Log::info("Failed to execute action \n".$e->getMessage()."\n".$res['stdout']);
                }
            }
        }
    }
}

return new Modules_LsSftpAccess_EventListener ();