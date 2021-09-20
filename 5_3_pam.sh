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
pwquality=$(date +pwquality_bakup_%s)
cp /etc/security/pwquality.conf $HOME/$pwquality

pam_d=$(date +pam_d%s)
cp -r /etc/pam.d/ $HOME/$pam_d

hardening 'apt update;apt install libpam-pwquality -y' 'apt search ^libpam-pwquality$' '"installed"' '5.3.1 Ensure password creation requirements are configured (Scored)'

pwquality=$(date +pwquality_bakup_%s)
cp /etc/security/pwquality.conf $HOME/$pwquality

pam_d=$(date +pam_d%s)
cp -r /etc/pam.d/ $HOME/$pam_d
echo "$red THESE ARE NOT WIRKING DO THESE WITH YOUR OWN RISK $white"
hardening 'sed -i   "s/^\s*minclass/\#minclass/gI" /etc/security/pwquality.conf;echo "minclass = 4">>/etc/security/pwquality.conf' "grep '^\s*minclass\s*' /etc/security/pwquality.conf" '"4"' '"5.3.1 Ensure password creation requirements are configured (Scored)"'
hardening 'sed -i   "s/^\s*minlen/\#minlen/gI" /etc/security/pwquality.conf;echo "minlen = 14">>/etc/security/pwquality.conf' "grep '^\s*minlen\s*' /etc/security/pwquality.conf" '"14"' '"5.3.1 Ensure password creation requirements are configured (Scored)"'
hardening 'sed -i   "s/^\s*password\s*requisite/\#password  requisite/gI" /etc/pam.d/common-password;echo "password        requisite                       pam_pwquality.so retry=3">>/etc/pam.d/common-password' "grep -E '^\s*password\s+(requisite|required)\s+pam_pwquality\.so\s+(\S+\s+)*retry=[1-3]\s*(\s+\S+\s*)*(\s+#.*)?$' /etc/pam.d/common-password" '"retry=3"' '"5.3.1 Ensure password creation requirements are configured (Scored)"'
hardening 'sed -i   "s/^\s*password\s*required/\#password\ required/gI" /etc/pam.d/common-password;echo "password required pam_pwhistory.so remember=5">>/etc/pam.d/common-password' 'grep -E "^password\s+required\s+pam_pwhistory.so" /etc/pam.d/common-password' '"remember=5"' '"5.3.3 Ensure password reuse is limited (Scored)"'
hardening 'sed -i   "s/^\s*password\s*required/\#password\ required/gI" /etc/pam.d/common-password;echo "password required pam_pwhistory.so remember=5">>/etc/pam.d/common-password' 'grep -E "^password\s+required\s+pam_pwhistory.so" /etc/pam.d/common-password' '"remember=5"' '"5.3.3 Ensure password reuse is limited (Scored)"'
# hardening 'sed -i   "s/^\s*password\s*\[success/\#password\ \[success/gI" /etc/pam.d/common-password;echo "password [success=1 default=ignore] pam_unix.so sha512">>/etc/pam.d/common-password' 'grep -E "^\s*password\s+(\S+\s+)+pam_unix\.so\s+(\S+\s+)*sha512\s*(\S+\s*)*(\s+#.*)?$" /etc/pam.d/common-password' '"sha512"' '"5.3.4 Ensure password hashing algorithm is SHA-512 (Scored)"'
hardening 'sed -i   "s/^\s*account\s*requisite/\#account\ requisite/gI" /etc/pam.d/common-account;echo "account requisite   pam_deny.so">>/etc/pam.d/common-account' 'grep "pam_deny" /etc/pam.d/common-account' '"pam_deny.so"' '"5.3.2 Ensure lockout for failed password attempts is configured (Scored)"'
# hardening 'sed -i   "s/^\s*auth\s*required/\#auth  required/gI" /etc/pam.d/common-auth;echo "auth required pam_tally2.so onerr=fail audit silent deny=5 unlock_time=900">>/etc/pam.d/common-auth' 'grep "pam_tally2" /etc/pam.d/common-auth' '"pam_tally2.so"' '"5.3.2 Ensure lockout for failed password attempts is configured (Scored)"'
echo "$green 5.2.2 Ensure permissions on SSH private host key files are configure (Scored)"
echo "$red ##TODO May Need Check Manually $white"
