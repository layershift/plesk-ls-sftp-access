#!/bin/bash

if [[ ! -z "$1" ]]; then
    action="$1"
else
    echo "Error: action not set";
    action="help";
fi

case $action in
    
    checkUser|userCheck)
        if [ -z "$2" ]; then echo '{"result":2,"error":"Username not specified"}'; exit 0; fi
        grep -q "^${2}:" /etc/passwd
        if [ $? -ne 0 ]; then 
            echo '{"result":3,"error": "System user does not exit"}'; exit 0; 
        else
            if [ ! -f /usr/local/psa/admin/conf/ls-sftp-access ]; then
                echo '{"result":4,"error": "Failed to open data store"}'; exit 0; 
            else
                cat /usr/local/psa/admin/conf/ls-sftp-access | jq empty 2>/dev/null 1>/dev/null
                if [ $? -ne 0 ]; then
                    echo '{"result":5,"error": "Failed to parse data store"}'; exit 0; 
                else
                    result=$(cat /usr/local/psa/admin/conf/ls-sftp-access | jq -r '.data[]|select( .user == "'${2}'" )| .user')
                    if [ "$result" != "" ]; then
                        echo '{"result":0,"error":"","user":"'${result}'"}'; exit 0; 
                    else
                        echo '{"result":6,"error": "Not found in data store"}'; exit 0;  
                    fi
                fi
            fi
        fi
        exit 0;
    ;;
    
    userAdd)
        if [ -z "$2" ]; then echo '{"result":2,"error":"Username not specified"}'; exit 0; fi
        
        result="$(bash $0 checkUser "$2" )"
        result_=$(echo "$result" | jq -r .result)
        if [ $result_ -eq 6 ]; then
            usermod -a -G sftpusers "$2"
            if [ $? -ne 0 ]; then
                echo '{"result":3,"error":"Failed to add user to sftpusers group"}'; exit 0;
            else
                outKey=("result")
                outVal=(0)

                outcome="jailhome ="
                mkdir -p "/jail/${2}/${2}"
                if [ -d "/jail/${2}/${2}" ]; then
                    outcome="$outcome created"
                else
                    outcome="$outcome failed to create"
                    outVal[0]=2
                fi

                outKey+=("jailHome")
                outVal+=("$(echo $outcome | sed 's#^|##')")

                outcome="mount ="
                grep -q "/jail/${2}/${2}" /etc/auto.master.d/ls-sftp-access.data
                if [ $? -eq  0 ]; then 
                    sed 's#/jail/'${2}'/'${2}' --bind.*##g' -i /etc/auto.master.d/ls-sftp-access.data
                fi
                echo "/jail/${2}/${2} --bind :$(grep "^${2}:" /etc/passwd | awk -F ":" '{print $(NF-1)}') " >> /etc/auto.master.d/ls-sftp-access.data
                grep -q "/jail/${2}/${2}" /etc/auto.master.d/ls-sftp-access.data
                if [ $? -eq 0 ]; then
                    outcome="$outcome created"
                else
                    outcome="$outcome failed to create"
                    outVal[0]=3
                fi
                systemctl reload autofs.service
                if [ $? -eq 0 ]; then
                    outcome="$outcome|reloaded"
                else
                    outcome="$outcome|failed to reload"
                    outVal[0]=4
                fi

                outKey+=("dataStore")
                outVal+=("$(echo $outcome | sed 's#^|##')")

                outcome="dataStore ="
                tmp=$(mktemp)
                cat /usr/local/psa/admin/conf/ls-sftp-access | jq '.data += [{"user": "'$2'", date:'$(date +%s)'}]' > $tmp
                diff /usr/local/psa/admin/conf/ls-sftp-access $tmp 2>&1 >/dev/null
                if [ $? -eq 1 ]; then
                    outcome="$outcome changed"
                else
                    outcome="$outcome|change failed"
                    outVal[0]=5
                fi 
                cat $tmp > /usr/local/psa/admin/conf/ls-sftp-access
                if [ $? -eq 0 ]; then
                    outcome="$outcome|saved"
                else
                    outcome="$outcome|save failed"
                    outVal[0]=6
                fi

                outKey+=("dataStore")
                outVal+=("$(echo $outcome | sed 's#^|##')")


                if [[ ! -z $outKey && ! -z $outVal ]]; then
                    out="{"
                    for i in ${!outKey[@]}; do
                        out="${out}\"${outKey[$i]}\":";
                        re='^[0-9]+$'
                        if ! [[ ${outVal[$i]} =~ $re ]] ; then
                            out="${out}\"${outVal[$i]}\","
                        else
                            out="${out}${outVal[$i]},"
                        fi
                    done;
                    out=$(echo "${out}"|sed 's#,$##')
                    out="${out}}"
                    echo "$out";
                fi

            fi
        else
            echo "$result"
        fi;
    ;;
    
    userRemove)
        if [ -z "$2" ]; then echo '{"result":2,"error":"Username not specified"}'; exit 0; fi
                  
        result="$(bash $0 checkUser "$2" )"
        result_=$(echo "$result" | jq -r .result)

        if [[ $result_ -eq 3 || $result_ -eq 0 ]]; then
            # out = array("result"=>0)
            outKey=("result")
            outVal=(0)
        fi
        if [[ $result_ -eq 3 || $result_ -eq 0 ]]; then
            # remove from dataStore
            tmp=$(mktemp)
            outcome="dataStore ="
            cat /usr/local/psa/admin/conf/ls-sftp-access | jq --arg user "${2}" 'del(.data[]|select(.user==$user))' > $tmp
            diff /usr/local/psa/admin/conf/ls-sftp-access $tmp 2>&1 >/dev/null
            if [ $? -eq 1 ]; then 
                outcome="$outcome|changed"
            else
                outcome="$outcome|change failed"
                outVal[0]=1
            fi
            cat $tmp > /usr/local/psa/admin/conf/ls-sftp-access
            if [ $? -eq 0 ]; then
                outcome="$outcome|saved"
            else
                outcome="$outcome|save failed"
                outVal[0]=2
            fi
            rm -f $tmp

            outKey+=("dataStore")
            outVal+=("$(echo $outcome | sed 's#^|##')")

            # remove autofs mount
            grep -q "^/jail/${2}/${2}" /etc/auto.master.d/ls-sftp-access.data
            if [ $? -eq  0 ]; then
                outcome="mount = found" 
                sed 's#/jail/'${2}'/'${2}'[[:space:]]--bind.*##g' -i /etc/auto.master.d/ls-sftp-access.data
                grep -q "^/jail/${2}/${2}" /etc/auto.master.d/ls-sftp-access.data
                if [ $? -ne  0 ]; then 
                    outcome="$outcome|removed"; 
                else
                    outcome="$outcome|remove failed"; 
                    outVal[0]=3;
                fi
                systemctl reload autofs.service
                if [ $? -eq  0 ]; then 
                    outcome="$outcome|service reloaded"; 
                else
                    outcome="$outcome|service reload failed"; 
                    outVal[0]=4;
                fi

                outKey+=("mount")
                outVal+=("$outcome")
            fi
        fi
        # remove user from sftpusers group
        if [[ $result_ -eq 0 ]]; then
            outcome="systemuser ="
            groups ${2} | grep -q sftpusers
            if [ $? -eq 0 ]; then
                outcome="${outcome} found" 
                gpasswd --delete ${2} sftpusers 2>&1 >/dev/null
                if [ $? -eq 0 ]; then
                    outcome="${outcome}|removed from sftpusers group" 
                else
                    outcome="${outcome}|failed to removed from sftpusers group" 
                    outVal[0]=6;
                fi
            else
                outcome="${outcome} not found"
                outVal[0]=5;
            fi;

                outKey+=("systemuser")
                outVal+=("$outcome")
        fi

        if [[ $result_ -ne 0 && $result_ -ne 3 ]]; then 
            echo "$result"
        else
            if [[ ! -z $outKey && ! -z $outVal ]]; then
                out="{"
                for i in ${!outKey[@]}; do
                    out="${out}\"${outKey[$i]}\":";
                    re='^[0-9]+$'
                    if ! [[ ${outVal[$i]} =~ $re ]] ; then
                        out="${out}\"${outVal[$i]}\","
                    else
                        out="${out}${outVal[$i]},"
                    fi
                done;
                out=$(echo "${out}"|sed 's#,$##')
                out="${out}}"
                echo "$out";
            fi
        fi
    ;;
    
    userList)
        cat /usr/local/psa/admin/conf/ls-sftp-access | jq
    ;;

    dataStoreCleanup)
        for user in $(cat /usr/local/psa/admin/conf/ls-sftp-access | jq -r '.data[].user'); do
            result="$(bash $0 checkUser $user)"
            result_=$(echo "$result" | jq -r .result)
            if [[ $result_ -eq 3 ]]; then
                bash $0 userRemove $user
            fi
        done
    ;;

    help|--help|-h|*)
        cat <<EOF
Usage:
$0  
    userCheck {username}        : Check if the username has SFTP enabled
                                    result: 0   - All ok
                                            2   - Username not specified
                                            3   - System User doesn't exist
                                            4   - Failed to open data store
                                            5   - Failed to parse data store (invalid json)
                                            6   - Not found in data store
    
    userList                    : List of known SFTP enabled users
    
    userAdd {username}          : Enable SFTP for a specific additional FTP user
    userRemove {username}       : Disable SFTP for a specific additional FTP user
    
    dataStoreCleanup            : Parse the dataStore and remove the non existing system users

    help                        : this message
EOF
    ;;
esac
