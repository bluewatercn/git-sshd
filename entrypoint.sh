#!/usr/bin/env bash

set -eu

ROOT_PASSWORD=${ROOT_PASSWORD:-}
GITHUBEMAIL=${GITHUBEMAIL:-}
GITHUBTOKEN=${GITHUBTOKEN:-}
SECRETPASSPHRASE=${SECRETPASSPHRASE:-}

ssh-keygen -A 1>/dev/null

function token_exists {
if [[ "$GITHUBTOKEN" == ''  ]];then
        echo "GITHUBTOKEN must be set"
        return 1
fi
}

function email_exists {
if [[ "$GITHUBEMAIL" == ''  ]];then
        echo "GITHUBEMAIL must be set"
        return 1
fi
}
function rootpassword_exists {
if [[ "$ROOT_PASSWORD" == ''  ]];then
        echo "ROOT_PASSWORD must be set"
        return 1
fi
}

function secretpassphrase_exists {
if [[ "$SECRETPASSPHRASE" == ''  ]];then
        echo "SECRETPASSPHRASE must be set"
        return 1
fi
}


rootpassword_exists
email_exists
token_exists
secretpassphrase_exists

#set root password login and heartbeat
echo "root:${ROOT_PASSWORD}" | chpasswd &>/dev/null
sed -i "s/#PermitRootLogin.*/PermitRootLogin\ yes/" /etc/ssh/sshd_config
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 20/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config

#set git token login
if [[ ! -e /root/.ssh  ]];then
        mkdir -p /root/.ssh
fi
ssh-keygen -t ed25519 -C $GITHUBEMAIL -f /root/.ssh/id_ed25519 -N $SECRETPASSPHRASE -q



# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e "$@"
