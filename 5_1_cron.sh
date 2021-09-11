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
hardening 'chmod og-rwx /etc/crontab' 'stat /etc/crontab|grep "Access: ("' '"0600"' '5.1.2 Ensure permissions on /etc/crontab are configured (Scored)'