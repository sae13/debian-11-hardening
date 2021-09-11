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

hardening 'sed -i   "s/^\s*minclass/\#minclass/gI" /etc/security/pwquality.conf;echo "minclass = 4">>/etc/security/pwquality.conf'  "grep '^\s*minclass\s*' /etc/security/pwquality.conf" '"4"' '"5.3.1 Ensure password creation requirements are configured (Scored)"'

hardening 'sed -i   "s/^\s*minlen/\#minlen/gI" /etc/security/pwquality.conf;echo "minlen = 14">>/etc/security/pwquality.conf' "grep '^\s*minlen\s*' /etc/security/pwquality.conf" '"14"' '"5.3.1 Ensure password creation requirements are configured (Scored)"'

hardening 'sed -i   "s/^\s*password\s*requisite/\#password  requisite/gI" /etc/pam.d/common-password;echo "password        requisite                       pam_pwquality.so retry=3">>/etc/pam.d/common-password' "grep -E '^\s*password\s+(requisite|required)\s+pam_pwquality\.so\s+(\S+\s+)*retry=[1-3]\s*(\s+\S+\s*)*(\s+#.*)?$' /etc/pam.d/common-password" '"retry=3"' '"5.3.1 Ensure password creation requirements are configured (Scored)"'

echo "$green 5.2.2 Ensure permissions on SSH private host key files are configure (Scored)"
echo "$red ##TODO May Need Check Manually $white"
