#!/bin/bash
printenv
# Create the jail home
mkdir -p -v -m 751 /jail
chown root.root /jail

grep -q sftpusers /etc/group
if [ $? -ne 0 ]; then
    groupadd sftpusers
fi

# Configure AutoFS
if [ -d /etc/auto.master.d ]; then
    if [ -f /etc/auto.master.d/ls-sftp-access.autofs ]; then
        mv -v /etc/auto.master.d/ls-sftp-access.autofs /etc/auto.master.d/ls-sftp-access.autofs_$(date +%s)
    fi
    echo "/- /etc/auto.master.d/ls-sftp-access.data" > /etc/auto.master.d/ls-sftp-access.autofs
    if [ ! -f /etc/auto.master.d/ls-sftp-access.data ]; then
        touch /etc/auto.master.d/ls-sftp-access.data
    fi
    chmod 644 /etc/auto.master.d/ls-sftp-access.autofs /etc/auto.master.d/ls-sftp-access.data

    sed 's$/misc$#/misc$' -i /etc/auto.master
    sed 's$/net$#/net$' -i /etc/auto.master

    systemctl restart autofs
    systemctl enable autofs

else
    echo "Error: can't find /etc/auto.master.d"
fi


# Configure SSHD
grep -q "### ls-sftp-access configuration block begin ###" /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
    cp -p -v /etc/ssh/sshd_config /etc/ssh/sshd_config_$(date +%s)
fi

grep -q "### ls-sftp-access configuration block begin ###" /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
    grep -q "### ls-sftp-access configuration block begin ###" /etc/ssh/sshd_config
    if [ $? -eq 0 ]; then
        sed -e '/^### ls-sftp-access configuration block begin ###/,/^### ls-sftp-access configuration block begin ###/d' -i /etc/ssh/sshd_config 
    fi
fi

cat <<EOF >> /etc/ssh/sshd_config 
### ls-sftp-access configuration block begin ###
Match Group sftpusers
    ChrootDirectory /jail/%u
    ForceCommand internal-sftp -d /%u
    PasswordAuthentication yes
    PubkeyAuthentication yes
    PermitTunnel no
    AllowAgentForwarding no
    AllowTcpForwarding no
    X11Forwarding no
Match all
### ls-sftp-access configuration block end ###
EOF

systemctl restart sshd

# Check if CageFS is installed and add the jail folder to the mount points
rpm -q cagefs 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    cat <<EOF >> /etc/cagefs/cagefs.mp
### ls-sftp-access configuration block begin ###
/jail
### ls-sftp-access configuration block end ###
EOF
    cagefsctl --remount-all
fi

# Prepare persistent configuration files

if [ ! -f /usr/local/psa/admin/conf/ls-sftp-access ]; then
    touch /usr/local/psa/admin/conf/ls-sftp-access;
    echo '{"data": []}' > /usr/local/psa/admin/conf/ls-sftp-access
fi

