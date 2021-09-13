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
login_defs=$(date +login_defs_%s)
cp /etc/login.defs $HOME/$login_defs

hardening 'sed -i   "s/^\s*PASS_MAX_DAYS/\#PASS_MAX_DAYS/gI" /etc/login.defs;echo "PASS_MAX_DAYS 365">>/etc/login.defs;' 'grep -i -E "^\s*PASS_MAX_DAYS" /etc/login.defs' '"365"' '5.4.1.1 Ensure password expiration is 365 days or less (Scored)'

grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1,5
echo "$red chage --maxdays 365 <user> $white"

hardening 'sed -i   "s/^\s*PASS_MIN_DAYS/\#PASS_MIN_DAYS/gI" /etc/login.defs;echo "PASS_MIN_DAYS 1">>/etc/login.defs;' 'grep -i -E "^\s*PASS_MIN_DAYS" /etc/login.defs' '"\s*1\s*"' '5.4.1.2 Ensure minimum days between password changes is configured(Scored)'


grep -E ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1,4
echo "$red chage --mindays 1 <user>  $white"
hardening 'sed -i   "s/^\s*PASS_WARN_AGE/\#PASS_WARN_AGE/gI" /etc/login.defs;echo "PASS_WARN_AGE 7">>/etc/login.defs;' 'grep -i -E "^\s*PASS_WARN_AGE" /etc/login.defs' '"\s*7\s*"' '5.4.1.3 Ensure password expiration warning days is 7 or more (Scored)'


grep -E ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1,6
echo "$red chage --warndays 7 <user>  $white"


hardening 'useradd -D -f 30' 'useradd -D | grep "INACTIVE"' '"[\s=]*30\s*"' '5.4.1.3 Ensure password expiration warning days is 7 or more (Scored)'
grep -E ^[^:]+:[^\!*] /etc/shadow | cut -d: -f1,7
echo "$red chage --inactive 30 <user>  $white"

echo "$green 5.4.1.5 Ensure all users last password change date is in the past (Scored) $white"
echo "$red Ensure all users last password change date is in the past  $white"
for usr in $(cut -d: -f1 /etc/shadow); do [[ $(chage --list $usr | grep '^Last password change' | cut -d: -f2) > $(date) ]] && echo "$usr :$(chage --list $usr | grep '^Last password change' | cut -d: -f2)"; done



echo "$green 5.4.2 Ensure system accounts are secured (Scored) $white"
echo "$red ###TODO run this manually  $white"
echo "$red erify no results are returned  $white"

awk -F: '($1!="root" && $1!="sync" && $1!="shutdown" && $1!="halt" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!="'"$(which nologin)"'" && $7!="/bin/false") {print}' /etc/passwd

echo "$red erify no results are returned  $white"
awk -F: '($1!="root" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '($2!="L" && $2!="LK") {print $1}'

echo "$red Run the commands appropriate for your distribution:  $white"
echo "$red eSet the shell for any accounts returned by the audit to nologin: $white"
echo "usermod -L <user>"

hardening 'usermod -g 0 root' 'grep "^root:" /etc/passwd | cut -f4 -d:' '"^0$"' '5.4.3 Ensure default group for the root account is GID 0 (Scored)'

hardening 'sed -i   "s/^\s*umask/\#umask/gI" /etc/bash.bashrc ;echo "umask 027"  >> /etc/bash.bashrc  ' 'grep "umask" /etc/bash.bashrc' '"027"' '5.4.4 Ensure default user umask is 027 or more restrictive (Scored)'
hardening 'sed -i   "s/^\s*umask/\#umask/gI" /etc/profile;echo "umask 027"  >>  /etc/profile ' 'grep "umask" /etc/profile' '"027"' '5.4.4 Ensure default user umask is 027 or more restrictive (Scored)'

hardening 'sed -i   "s/^\s*readonly\ TMOUT/\#readonly\ TMOUT/gI" /etc/bash.bashrc ;echo "readonly TMOUT=900 ; export TMOUT"  >> /etc/bash.bashrc  ' 'grep "TMOUT" /etc/bash.bashrc' '"readonly TMOUT=900 ; export TMOUT"' '5.4.5 Ensure default user shell timeout is 900 seconds or less (Scored)'
hardening 'sed -i   "s/^\s*readonly\ TMOUT/\#readonly\ TMOUT/gI" /etc/profile;echo "readonly TMOUT=900 ; export TMOUT"  >>  /etc/profile ' 'grep "TMOUT" /etc/profile' '"readonly TMOUT=900 ; export TMOUT"' '5.4.5 Ensure default user shell timeout is 900 seconds or less(Scored)'


echo "$red 5.5 Ensure root login is restricted to system console (Not Scored)  $white"
echo "$red The file /etc/securetty contains a list of valid terminals that may be logged in directly as root. $white"
echo "cat /etc/securetty"
cat /etc/securetty
echo "$red Remove entries for any consoles that are not in a physically secure location. $white"
