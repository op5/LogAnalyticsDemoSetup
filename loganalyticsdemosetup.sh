#!/usr/bin/env bash

ACCOUNT=''
PASSWORD=''
BASHRC=./sedtest.sh

function createuser {
	read -rp "User account: " account
	ACCOUNT=$account
	printf "$ACCOUNT\n"
	adduser -mG wheel $ACCOUNT 
}

function setpassword {
	 passwd $ACCOUNT 
}

function clean_bashrc {
	sed -i '' -n '/$0/d'$BASHRC
}

function finish {
	#shutdown -r now
	printf "Rebooting VM. (Not really)\n"
}

printf "Log Analytics Demo Setup.\n"

createuser
setpassword
clean_bashrc
finish

