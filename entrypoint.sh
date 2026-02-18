#!/usr/bin/env bash

set -eu

ROOT_PASSWORD=${ROOT_PASSWORD:-}
GITHUBEMAIL=${GITHUBEMAIL:-}
GITHUBTOKEN=${GITHUBTOKEN:-}
SECRETPASSPHRASE=${SECRETPASSPHRASE:-}


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

function main {
rootpassword_exists
email_exists
token_exists
secretpassphrase_exists

#generate key
ssh-keygen -A 1>/dev/null

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
curl -H "Authorization: token ${GITHUBTOKEN}" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/user/keys \
     -d "{\"title\":\"my-server\",\"key\":\"$(cat /root/.ssh/id_ed25519.pub)\"}"
git config --global user.email $GITHUBEMAIL
git config --global user.name $(hostname)"-"$(whoami)


# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e "$@"
}

main
