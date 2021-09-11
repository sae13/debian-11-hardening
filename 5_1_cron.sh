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

hardening 'systemctl --now enable cron' 'systemctl is-enabled cron' '"enabled"' '5.1.1 Ensure cron daemon is enabled (Scored)'

hardening 'chown root:root /etc/crontab' 'stat /etc/crontab|grep "Access: ("' '".*root.*root"' '5.1.2 Ensure permissions on /etc/crontab are configured (Scored)'
hardening 'chmod 0600 /etc/crontab' 'stat /etc/crontab|grep "Access: ("' '"0600"' '5.1.2 Ensure permissions on /etc/crontab are configured (Scored)'

hardening 'chown root:root /etc/cron.hourly' 'stat /etc/cron.hourly|grep "Access: ("' '".*root.*root"' '5.1.3 Ensure permissions on /etc/cron.hourly are configured (Scored)'
hardening 'chmod 0600 /etc/cron.hourly' 'stat /etc/cron.hourly|grep "Access: ("' '"0600"' '5.1.3 Ensure permissions on /etc/cron.hourly are configured (Scored)'

hardening 'chown root:root /etc/cron.daily' 'stat /etc/cron.daily|grep "Access: ("' '".*root.*root"' '5.1.4 Ensure permissions on /etc/cron.daily are configured (Scored)'
hardening 'chmod 0600 /etc/cron.daily' 'stat /etc/cron.daily|grep "Access: ("' '"0600"' '5.1.4 Ensure permissions on /etc/cron.daily are configured (Scored)'

hardening 'chown root:root /etc/cron.weekly' 'stat /etc/cron.weekly|grep "Access: ("' '".*root.*root"' '5.1.5 Ensure permissions on /etc/cron.weekly are configured (Scored)'
hardening 'chmod 0600 /etc/cron.weekly' 'stat /etc/cron.weekly|grep "Access: ("' '"0600"' '5.1.5 Ensure permissions on /etc/cron.weekly are configured (Scored)'

hardening 'chown root:root /etc/cron.monthly' 'stat /etc/cron.monthly|grep "Access: ("' '".*root.*root"' '5.1.6 Ensure permissions on /etc/cron.monthly are configured (Scored)'
hardening 'chmod 0600 /etc/cron.monthly' 'stat /etc/cron.monthly|grep "Access: ("' '"0600"' '5.1.6 Ensure permissions on /etc/cron.monthly are configured (Scored)'

hardening 'chown root:root /etc/cron.d' 'stat /etc/cron.d|grep "Access: ("' '".*root.*root"' '5.1.7 Ensure permissions on /etc/cron.d are configured (Scored)'
hardening 'chmod 0600 /etc/cron.d' 'stat /etc/cron.d|grep "Access: ("' '"0600"' '5.1.7 Ensure permissions on /etc/cron.d are configured (Scored)'
echo "5.1.8 Ensure at/cron is restricted to authorized users (Scored)"
echo "###TODO May Need Check Manually"
rm /etc/cron.deny>/dev/null 2>&1
touch /etc/cron.allow
chown root:root /etc/cron.allow
chmod 0660 /etc/cron.allow