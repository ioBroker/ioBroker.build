#!/bin/bash 

#use_static_ip="yes"
 
# System update. 
sudo apt-get update 
sudo apt-get -y upgrade 
 
 
 
# Change network configuration if use_static_ip is "yes". 
if [[ $use_static_ip == "yes" ]] 
   then 
      dhcpcd_status=`service dhcpcd status | grep "Active: "`  
      set - $dhcpcd_status 
      if [[ $3 == "(running)" ]] 
         then 
            echo "interface eth0" >> /etc/dhcpcd.conf  
            echo "static ip_address=$ip_host/24" >> /etc/dhcpcd.conf  
            echo "static routers=$ip_router" >> /etc/dhcpcd.conf  
            echo "static domain_name_servers=$ip_router" >> /etc/dhcpcd.conf  
       
      else  
         service dhcpcd start 
            echo "interface eth0" >> /etc/dhcpcd.conf  
            echo "static ip_address=$ip_host/24" >> /etc/dhcpcd.conf  
            echo "static routers=$ip_router" >> /etc/dhcpcd.conf  
            echo "static domain_name_servers=$ip_router" >> /etc/dhcpcd.conf  
      fi 
      # Deactivate DHCP for Ethernet interface. Not recommendet. 
      #cat /etc/dhcpcd.conf  
      #echo "denyinterfaces eth0" >> /etc/dhcpcd.conf  
 
      #Statische IP für das Ethernet interface vergeben, ip des Pi's und des Routers kommen aus den Variablen am Anfang des Scripts. 
      #sed -i "s/iface eth0 inet .*/auto eth0 \n allow-hotplug eth0 \n iface eth0 inet static \n address $ip_raspi \n netmask 255.255.255.0 \n gateway $ip_router \n dns-nameservers $ip_router \n /" /etc/network/interfaces 
fi 
 
# Deinstall preinstalled node version, because ioBroker requires specific version 
sudo apt-get remove -y node 
sudo apt-get remove -y nodejs 
sudo apt-get autoremove -y 
sudo rm -r bin/node bin/node-waf include/node lib/node lib/pkgconfig/nodejs.pc share/man/man1/node.1 
 
 
# Install NodeJS from Nodesource.com. 
if [[ $(/bin/uname -a) != *pine64* ]] 
then
   curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - 
   sudo apt-get install -y nodejs
else
   # Or download directly from nodejs.org
   cd /tmp
   wget https://nodejs.org/dist/v4.5.0/node-v4.5.0-linux-arm64.tar.xz
   cd /usr/local
   sudo tar --strip-components=1 -xvf /tmp/node-v4.5.0-linux-arm64.tar.xz
fi

 
# Install build essentials. 
sudo apt-get install -y build-essential 
 
#Installation of iobroker. 
sudo mkdir /opt/iobroker 
sudo chmod 777 /opt/iobroker
cd /opt/iobroker
sudo npm install iobroker --unsafe-perm --production
sudo chmod 777 * -R
 
# Install of ALL drivers. 
# allAdapter=`cat /opt/iobroker/node_modules/iobroker.js-controller/conf/sources-dist.json | grep ": {"` 
# for fn in $allAdapter; do 
#    if [[ $fn != *"{"* ]] && [[ $fn != *"js-controller"* ]] && [[ $fn != *"admin"* ]] 
#       then 
#          fn_tmp="${fn%:}" 
#          listChk="$listChk $fn_tmp $fn_tmp OFF" 
#    fi 
# done 
#  
# Selection=$(whiptail --title "Adapter selection" --checklist "Select Drivers, that should be installed" 25 80 15 $listChk 3>&1 1>&2 2>&3) 
#  
# cd /opt/iobroker 
# for adapter in $Selection; do 
#         installName="${adapter##\"\"}" 
#         installName2="${installName%%\"\"}" 
#         ./iobroker add $installName2 --enabled 
# done 
./iobroker install socketio
./iobroker install simple-api
./iobroker install web
./iobroker install vis-map
./iobroker install vis-history
./iobroker install vis-metro
./iobroker install vis-hqwidgets
./iobroker install vis
./iobroker install flot
./iobroker install sql
./iobroker install cloud
./iobroker install mobile
 
# setup autostart of ioBroker. 
#bash /opt/iobroker/node_modules/iobroker/install/linux/install.sh 
 
