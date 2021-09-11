#!/bin/bash

red="$(tput setaf 1)"
green="$(tput setaf 2)"
orange="$(tput setaf 3)"
white="$(tput sgr0)"

# ---------------

hardening() {
    echo ------------------------------
    echo
    echo "${orange}$4${white}"
    echo

    echo "${orange}running:${white} $2"

    if eval "$2 | grep -i $3"; then
        echo
        echo "${green}PASSED!${white}"
    else
        echo "${orange}hardening:${white} $1"
        if eval "$1"; then
            if eval "$2 | grep -i $3"; then
                echo
                echo "${green}PASSED!${white}"
            else
                echo
                echo "${red}FAILED!${white}"
                echo
                exit 1
            fi
        else
            echo
            echo "${red}FAILED!${white}"
            echo
            exit 1
        fi
    fi
    echo
}

clear
back_up=`date +sshd_bakup_%s`
cp /etc/ssh/sshd_config $HOME/$back_up

hardening 'chown root:root /etc/ssh/sshd_config' 'stat /etc/ssh/sshd_config|grep "Access: ("' '".*root.*root"' '5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured (Scored)'
hardening 'chmod 0600 /etc/ssh/sshd_config' 'stat /etc/ssh/sshd_config|grep "Access: ("' '"0600"' '5.2.1 Ensure permissions on /etc/ssh/sshd_config are configured (Scored)'


echo "$green 5.2.2 Ensure permissions on SSH private host key files are configure (Scored)"
echo "$red ##TODO May Need Check Manually $white"
echo "$orange find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {}\; $white"
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {} \;
echo "$orange find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 0600 {} \; $white"
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 0600 {} \;



echo "$green 5.2.3 Ensure permissions on SSH public host key files are configured (Scored)"
echo "$red ##TODO May Need Check Manually $white"
echo "$orange find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod go-wx {} \; $white"
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod go-wx {} \;
echo "$orange find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \; $white"
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;



echo "$green 5.2.4 Ensure SSH Protocol is not set to 1 (Scored)"
if sshd -T | grep -Ei '^\s*protocol\s+(1|1\s*,\s*2|2\s*,\s*1)\s*'; then
    echo "Protocol 2">>/etc/ssh/sshd_config
fi