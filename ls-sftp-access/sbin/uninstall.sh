#!/bin/bash

systemctl stop autofs
systemctl disable autofs

grep -q "### ls-sftp-access configuration block begin ###" /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
    grep -q "### ls-sftp-access configuration block begin ###" /etc/ssh/sshd_config
    if [ $? -eq 0 ]; then
        sed -e '/^### ls-sftp-access configuration block begin ###/,/^### ls-sftp-access configuration block begin ###/d' -i /etc/ssh/sshd_config 
        systemctl restart sshd
    fi
fi

