#!/bin/bash

read -p "Enter Your Name: "  username
echo "Welcome $username!"

Need to know the interface Name

Need to set the following in the interface file
Need to store the answers in variables

function SET_NETWORK()
{
network_inf="/etc/sysconfig/network-scripts/ifcfg-enp0s3"

read -p "Enter the IP address to use for this server: " ipaddr
read -p "Enter the network mask (i.e. 255.255.255.0):" netmask
read -p "Enter the gateway for this network:" gateway
read -p "Enter the IP address of your first DNS server:" dns1
read -p "Enter the IP address of your second DNS server:" dns2

sed -i "
/IPADDR=/c\IPADDR=${ipaddr};
/NETMASK=/c\NETMASK=${netmask};
/GATEWAY=/c\GATEWAY=${gateway};
/DNS1=/c\DNS1=${dns1};
/DNS2=/c\DNS2=${dns2};
" $network_inf
}
echo $(SET_NETWORK);


echo "Your network configuration is: /r IPa"
echo "Welcome $username!"


read -r -p "Are you sure? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY])
        do_something
        ;;
    *)
        do_something_else
        ;;
esac
