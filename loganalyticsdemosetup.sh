#!/usr/bin/env bash

ACCOUNT=''
PASSWORD=''

function createuser {
	read -rp "User account: " account
	ACCOUNT=$account
	printf "$ACCOUNT\n"
	adduser -mG wheel $ACCOUNT 
}

function setpassword {
	 passwd $ACCOUNT 
}

printf "Log Analytics Demo Setup.\n"

createuser
setpassword




