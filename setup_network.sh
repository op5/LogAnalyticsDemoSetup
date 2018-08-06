#!/bin/bash

function SETUP_LA()
{
echo "AWESOME DHCP!!!!"
}

# Setup the network settings for when not using DHCP (Advanced)
# We provide network list, ask some questions so we can set this automatically
function SETUP_NETWORK()
{
echo "Below you'll see the the intefaces found on your machine, for the next step you'll type in the name of the one you want to use for the Log Analytics server."
ip ntable | grep dev | sort | uniq | sed -e 's/^.*dev //;/^lo/d'

read -p "Enter the inteface name to use for this Log Analytics server: " inf_name
read -p "Enter the IP address to use for this server and CIDR notation (example 10.10.0.100/24): " ipaddr
read -p "Enter the network mask (i.e. 255.255.255.0):" netmask
read -p "Enter the gateway for this network:" gateway
read -p "Enter the IP address of your first DNS server:" dns1
read -p "Enter the IP address of your second DNS server:" dns2

# Share the collected network information with the nmcli
nmcli con add con-name "$inf_name" ifname $inf_name type ethernet ip4 $ipaddr gw4 $netmask
nmcli con mod "LogAnalytics-Network" ipv4.dns "$dns1,$dns2"
nmcli con up "LogAnalytics-Network" ifname $inf_name

# Confirm the settings which the user entered by outputting ip addr and asking
# Next steps undefined byt can replace echo
echo -e "Do these network settings look correct?"

ip addr | grep -A 1 -B 1 $inf_name

read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        echo AWESOME NETWORK SETUP COMPLETE!!
        ;;
    *)
        SETUP_LA
        ;;
esac
}

# Initial prompt to ask if user would like to use DHCP or setup the static network settings
read -r -p "Would you like to use DHCP (1) or Static IP **Advanced** (2)? " response
case "$response" in
    1)
        SETUP_LA
        ;;
    2)
        SETUP_NETWORK
        ;;
