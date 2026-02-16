#!/usr/bin/env bash

set -e


ROOT_LOGIN_UNLOCKED="true"
ROOT_PASSWORD="root"

ssh-keygen -A 1>/dev/null

if [[ "${ROOT_LOGIN_UNLOCKED}" == "true" ]] ; then
    echo "root:${ROOT_PASSWORD}" | chpasswd &>/dev/null
    sed -i "s/#PermitRootLogin.*/PermitRootLogin\ yes/" /etc/ssh/sshd_config
    sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 20/g' /etc/ssh/sshd_config
fi

# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e "$@"
