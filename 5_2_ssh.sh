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


hardening  'sed -i   "s/^\s*loglevel/\#LogLevel/gI" /etc/ssh/sshd_config;echo "LogLevel VERBOSE">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i loglevel' 'VERBOSE' '5.2.5 Ensure SSH LogLevel is appropriate (Scored)'

hardening  'sed -i   "s/^\s*X11Forwarding/\#X11Forwarding/gI" /etc/ssh/sshd_config;echo "X11Forwarding no">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i X11Forwarding' 'no' '5.2.7 Ensure SSH MaxAuthTries is set to 4 or less (Scored)'

hardening  'sed -i   "s/^\s*MaxAuthTries/\#MaxAuthTries/gI" /etc/ssh/sshd_config;echo "MaxAuthTries 4">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i MaxAuthTries' '4' '5.2.7 Ensure SSH MaxAuthTries is set to 4 or less (Scored)'

hardening  'sed -i   "s/^\s*IgnoreRhosts/\#IgnoreRhosts/gI" /etc/ssh/sshd_config;echo "IgnoreRhosts yes">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i IgnoreRhosts' 'yes' '5.2.8 Ensure SSH IgnoreRhosts is enabled (Scored)'

hardening  'sed -i   "s/^\s*HostbasedAuthentication/\#HostbasedAuthentication/gI" /etc/ssh/sshd_config;echo "HostbasedAuthentication no">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i HostbasedAuthentication' 'no' '5.2.9 Ensure SSH HostbasedAuthentication is disabled (Scored)'

hardening  'sed -i   "s/^\s*PermitRootLogin/\#PermitRootLogin/gI" /etc/ssh/sshd_config;echo "PermitRootLogin no">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i PermitRootLogin' 'no' '5.2.10 Ensure SSH PermitRootLogin is disabled (Scored)'

hardening  'sed -i   "s/^\s*PermitEmptyPasswords/\#PermitEmptyPasswords/gI" /etc/ssh/sshd_config;echo "PermitEmptyPasswords no">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i PermitEmptyPasswords' 'no' '5.2.11 Ensure SSH PermitEmptyPasswords is disabled (Scored)'

hardening  'sed -i   "s/^\s*PermitUserEnvironment/\#PermitUserEnvironment/gI" /etc/ssh/sshd_config;echo "PermitUserEnvironment no">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i PermitUserEnvironment' 'no' '5.2.12 Ensure SSH PermitUserEnvironment is disabled (Scored)'

hardening  'sed -i   "s/^\s*Ciphers\ /\#Ciphers\ /gI" /etc/ssh/sshd_config;echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i ciphers' '"chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr"' '5.2.13 Ensure only strong Ciphers are used (Scored)'

hardening  'sed -i   "s/^\s*MACs\ /\#MACs\ /gI" /etc/ssh/sshd_config;echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i MACs' '"hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"' '5.2.14 Ensure only strong MAC algorithms are used (Scored)'

hardening  'sed -i   "s/^\s*KexAlgorithms\ /\#KexAlgorithms\ /gI" /etc/ssh/sshd_config;echo "KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i KexAlgorithms' '"curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group14-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256"' '5.2.15 Ensure only strong Key Exchange algorithms are used (Scored)'



hardening  'sed -i   "s/^\s*ClientAliveInterval/\#ClientAliveInterval/gI" /etc/ssh/sshd_config;echo "ClientAliveInterval 300">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i ClientAliveInterval' '300' '5.2.16 Ensure SSH Idle Timeout Interval is configured (Scored)'


hardening  'sed -i   "s/^\s*ClientAliveCountMax/\#ClientAliveCountMax/gI" /etc/ssh/sshd_config;echo "ClientAliveCountMax 300">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i ClientAliveCountMax' '"ClientAliveCountMax 300"' '5.2.16 Ensure SSH Idle Timeout Interval is configured (Scored)'

hardening  'sed -i   "s/^\s*LoginGraceTime/\#LoginGraceTime/gI" /etc/ssh/sshd_config;echo "LoginGraceTime 60">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i LoginGraceTime' '"LoginGraceTime 60"' '5.2.17 Ensure SSH LoginGraceTime is set to one minute or less (Scored)'

hardening  'sed -i   "s/^\s*LoginGraceTime/\#LoginGraceTime/gI" /etc/ssh/sshd_config;echo "LoginGraceTime 60">>/etc/ssh/sshd_config;systemctl restart sshd;sleep 5;' 'sshd -T | grep -i LoginGraceTime' '"LoginGraceTime 60"' '5.2.16 Ensure SSH Idle Timeout Interval is configured (Scored)'
