#!/usr/bin/env bash

set -eu

ROOT_PASSWORD=${ROOT_PASSWORD:-}
EMAIL=${EMAIL:-}
TOKEN=${TOKEN:-}
SECRETPASSPHRASE=${SECRETPASSPHRASE:-}
GITHOST=${GITHOST:-}
GH_TOKEN=${GH_TOKEN:-}

function basic_arg_check {
if [[ "$TOKEN" == '' || "$EMAIL" == '' || "$ROOT_PASSWORD" == '' || "$SECRETPASSPHRASE" == '' ]];then
        echo "4 basic args TOKEN/EMAIL/ROOT_PASSWORD/SECRETPASSPHRASE must be set"
        return 1
fi
}

function git_host_arg_check {
if [[  "$GITHOST" != "github" && "$GITHOST" != "gitlab"  ]];then
	echo "arg GITHOST must be set to gitlab or github"
	return 1
elif [[ "$GITHOST" == "github" ]];then
	GH_TOKEN=$TOKEN
	return 0
elif [[ "$GITHOST" == "gitlab" ]];then
	GH_TOKEN=$TOKEN
	return 0
fi
}

function remote_git_host_autokey_set {
        case "$GITHOST" in
        	"github")
                curl "https://api.github.com/user/keys" \
	             -H "Authorization: token ${TOKEN}" \
                     -H "Accept: application/vnd.github+json" \
                     -d "{\"title\":\"My Automated Key\",\"key\":\"$(cat /root/.ssh/id_ed25519.pub)\"}"
		         ;;
		 "gitlab")
		 curl "https://gitlab.com/api/v4/user/keys" \
                     -H "PRIVATE-TOKEN: ${TOKEN}" \
                     -H "Content-Type: application/json" \
                     -d "{\"title\": \"My Automated Key\",\"key\": \"$(cat /root/.ssh/id_ed25519.pub)\"}"
		 #glab ssh-key add $(cat /root/.ssh/id_ed25519.pub) --title "My Automated Key"
			 ;;
	 esac
}

function localhost_ssh_key_generate {
ssh-keygen -A 1>/dev/null
if [[ ! -e /root/.ssh  ]];then
        mkdir -p /root/.ssh
fi
ssh-keygen -t ed25519 -C $EMAIL -f /root/.ssh/id_ed25519 -N $SECRETPASSPHRASE -q
}

function main {
basic_arg_check
git_host_arg_check
localhost_ssh_key_generate
remote_git_host_autokey_set

#set git config global
git config --global user.email $EMAIL
git config --global user.name $(hostname)"-"$(whoami)

#set root password login and heartbeat
echo "root:${ROOT_PASSWORD}" | chpasswd &>/dev/null
sed -i "s/#PermitRootLogin.*/PermitRootLogin\ yes/" /etc/ssh/sshd_config
sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 20/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e "$@"
}

main
