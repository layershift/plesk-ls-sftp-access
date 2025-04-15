#!/bin/bash

systemctl stop autofs
systemctl disable autofs

# Remove SSHD configuration block
grep -q "### ls-sftp-access configuration block begin ###" /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
    grep -q "### ls-sftp-access configuration block begin ###" /etc/ssh/sshd_config
    if [ $? -eq 0 ]; then
        sed -e '/^### ls-sftp-access configuration block begin ###/,/^### ls-sftp-access configuration block begin ###/d' -i /etc/ssh/sshd_config 
        systemctl restart sshd
    fi
fi

# Remove the CageFS mounte point
rpm -q cagefs 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    grep -q "### ls-sftp-access configuration block begin ###" /etc/cagefs/cagefs.mp
    if [ $? -eq 0 ]; then
        sed -e '/^### ls-sftp-access configuration block begin ###/,/^### ls-sftp-access configuration block begin ###/d' -i /etc/cagefs/cagefs.mp
        cagefsctl --remount-all
    fi
fi