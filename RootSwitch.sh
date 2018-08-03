#/usr/bin/bash
function createuser {
	echo "create user"
}
function setpassword {
	echo "setpassword"
}

function RootSwitch {
	read -p "Would you like to create a local user?\n" choice 
	case "$choice" in
		Yes|yes|y|Y ) NewUser;;
		No|no|n|N ) setrootpass;;
	esac
}

function NewUser {
	createuser
	setpassword
}

function setrootpass {
	setACCOUNT= "root"
	setpassword

}

RootSwitch
