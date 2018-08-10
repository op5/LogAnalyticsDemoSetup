#!/usr/bin/env bash

ACCOUNT=''
PASSWORD=''
BASHRC=$HOME/.bashrc
NETWORK_INTERFACE=''
NETWORK_GATEWAY=`ip route list | grep default | cut -d ' ' -f 3`
NETWORK_DHCP=1
NETWORK_ACCESS=0
REPO_BASE="https://github.com"
REPO_PATH="op5/LogAnalyticsDemoSetup"
REPO_ACCESS=0
REPO_ON_DISK="$HOME/LogAnalyticsDemoSetup"
SCRIPT_NAME="loganalyticsdemosetup.sh"
LOGSTASH_PATH_SRC="logstash"
LOGSTASH_PATH_DEST="/etc"
ELASTICSEARCH_CONFIG_FILE="/etc/elasticsearch/elasticsearch.yml"


function SET_DHCP() {
	echo "AWESOME DHCP!!!!"
	NETWORK_DHCP=0
}

# Setup the network settings for when not using DHCP (Advanced)
# We provide network list, ask some questions so we can set this automatically
function SETUP_NETWORK() {
	echo "Below you'll see the the intefaces found on your machine, for the next step you'll type in the name of the one you want to use for the Log Analytics server."
	nmcli -p connection show
	
	read -p "Enter the inteface name to use for this Log Analytics server: " inf_name
	read -p "Enter the IPv4 address and subnet for this server in CIDR notation (ex: 10.1.0.100/24): " ipaddr
	read -p "Enter the gateway for this network: " gateway
	read -p "Enter the IPv4 address of your first DNS server: " dns1
	read -p "Enter the IPv4 address of your second DNS server: " dns2
	
	# Saving network info to make sure we have connectivity.
	NETWORK_INTERFACE=$inf_name
	NETWORK_GATEWAY=$gateway

	# Share the collected network information with the nmcli
	printf "\n"
	printf "Making sure $inf_name starts on boot.\n"
	nmcli connection modify "$inf_name" connection.autoconnect yes
	printf "Setting IPv4 address on $inf_name to $ipaddr.\n"
	nmcli connection modify "$inf_name" ipv4.address $ipaddr
	printf "Setting IPv4 gateway on $inf_name to $gateway.\n"
	nmcli connection modify "$inf_name" ipv4.gateway $gateway
	printf "Setting IPv4 DNS on $inf_name to $dns1 $dns2.\n"
	nmcli connection modify "$inf_name" ipv4.dns "$dns1 $dns2"
	printf "Setting $inf_name static.\n"
	nmcli connection modify "$inf_name" ipv4.method manual

	# Confirm the settings which the user entered by outputting ip addr and asking
	# Next steps undefined byt can replace echo
	echo -e "Do these network settings look correct?"
	
	printf "\n$inf_name info:\n"
	ip -h addr show $inf_name
	printf "\nRoute info:\n"
	ip -h route
	
	read -r -p "Are you sure? [Yes/No/Dhcp] " response
	case "$response" in
	    [yY][eE][sS]|[yY])
		#TODO: ask if the interface needs to be bounced just in case ssh is being used.
		printf "Bouncing connection for settings to take effect.\n"
		nmcli connection up "$inf_name"
	        printf "AWESOME NETWORK SETUP COMPLETE!!\n"
	        ;;
	    [dD][hH][cC][pP]|[dD])
		SET_DHCP
		;;
	    *)
	        SETUP_NETWORK
	        ;;
	esac
}

function SETUP_NETWORK_CHOICE() {
	# Initial prompt to ask if user would like to use DHCP or setup the static network settings
	read -r -p "Would you like to use DHCP (1) or Static IP **Advanced** (2)? " response
	case "$response" in
	    1)
	        SET_DHCP
	        ;;
	    2)
	        SETUP_NETWORK
	        ;;
	esac
}

function network_ping_gw {
	ping -Ac3 $NETWORK_GATEWAY 
	if [[ $? -ne 0 ]] 
	then
		printf "\n" 
		printf "Unable to contact gateway.\n"
		printf "Continuing without network access.\n"
		NETWORK_ACCESS=1
	fi
}

function network_resolve_repo_hostname {
	curl --connect-timeout 20 -s $REPO_BASE/$REPO_PATH -o /dev/null
	if [[ $? -ne 0 ]]
	then
		printf "Unable to resolve $REPO_BASE\n"
		REPO_ACCESS=1
	fi
}

function repo_update {
	cd $REPO_ON_DISK
	git pull
}

function elasticsearch_config {
	if [[ $NETWORK_DHCP -eq 0 ]]
	then
		sed -i 's/network.host: \[.\+\]/network.host: \["_local_", "_site_", "_global_"\]/' $ELASTICSEARCH_CONFIG_FILE
	else
		sed -i "s/network.host: \[.\+\]$/network.host: \[\"_local_\", \"_$NETWORK_INTERFACE\_\"\]/" $ELASTICSEARCH_CONFIG_FILE
	fi
}

function logstash_config {
	rsync -rv $LOGSTASH_PATH_SRC $LOGSTASH_PATH_DEST
}

function createuser {
	read -rp "User account: " account
	ACCOUNT=$account
	adduser -mG wheel $ACCOUNT 
}

function setpassword {
	 passwd $ACCOUNT 
}

function NewUser {
	createuser
	setpassword
}

function setrootpass {
	printf "Setting root password then.\n"
	ACCOUNT="root"
	setpassword

}

function RootSwitch {
	read -p "Would you like to create a local user? [Yes/No]: " choice 
	case "$choice" in
		Yes|yes|y|Y ) NewUser;;
		No|no|n|N ) setrootpass;;
	esac
}

function clean_bashrc {
	#TODO: Fix this so the script name comes from $0.
	sed -i "/$SCRIPT_NAME/d" $BASHRC
}

function finish {
	read -p "Ready to reboot the server? [Yes/No]: " bounce
	case "$bounce" in
		[yY][eE][sS]|[yY] )
			printf "Rebooting VM.\n"
			shutdown -r now
			;;
		[nN][oO]|[nN] )
			printf "Exiting script.\n"
			;;
	esac
}

printf "Log Analytics Demo Setup.\n"

SETUP_NETWORK_CHOICE
network_ping_gw
if [[ $NETWORK_ACCESS -eq 0 ]]
then
	printf "Check to see if repo host is resolvable.\n"
	network_resolve_repo_hostname
else
	printf "Skipping resolving repo host since network access is in an unknown state.\n"
fi

if [[ $NETWORK_ACCESS -eq 0 && $REPO_ACCESS -eq 0 ]]
then
	printf "Getting any repo updates.\n"
	repo_update
else
	printf "Skipping pulling repo updates.\n"
fi

elasticsearch_config
logstash_config
RootSwitch
clean_bashrc
finish

