#!/bin/bash


#==============================================================================
#title          :fresh_install.sh
#description    :This script is used on first boot to configure a server/client
#author		:Justin Holt - githubjh@gmail.com
#date           :Aug 10 2022
#version        :3.3.0 alpha.17
#usage		:sudo `pwd`/fresh_install.sh
#notes          :
#log file	:/var/log/pibroadcast-install.log
#==============================================================================
#Copyright (C) 2018  Web Server Development

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#==============================================================================

## Testing for being run as root ##
if [ "$(id -un)" != "root" ]; then
    echo "You must be root to run this....exiting"
    exit
fi

##  Testing architecture for virtual environment settings  ##
arch_test=$(uname -m)
if [ $arch_test = "i686" ]; then
        #echo "x86"
        arch=0

elif [ $arch_test = "x86_64" ]; then
	#echo "x86_64"
	arch=0

else [ $arch_test = "armf" ]
        #echo "Armf"
        arch=1
fi

##  Setting variables  ##
hostn=$(cat /etc/hostname)
choice=""
opt=""
LOGFILE=/var/log/pibroadcast-install.log
pipasswd="raspberry"
piadminpasswd="pibroadcast"

serveruser="piadmin"
serveruserpasswd="pibroadcast"

starting_install_directory=`pwd`

## Used for troubleshooting ##
echo Starting Install Directory: $starting_install_directory
## Used for troubleshooting ##


export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_PAPER=en_US.UTF-8
export LC_NAME=en_US.UTF-8
export LC_ADDRESS=en_US.UTF-8
export LC_TELEPHONE=en_US.UTF-8
export LC_MEASUREMENT=en_US.UTF-8
export LC_IDENTIFICATION=en_US.UTF-8
export LC_ALL=C
currentuser="piadmin"


echo "#####################################" | tee -a $LOGFILE
echo "##      Fresh/Re Install Test      ##" | tee -a $LOGFILE
echo "#####################################" | tee -a $LOGFILE
echo | tee -a $LOGFILE
echo "Testing hostname..." | tee -a $LOGFILE
echo | tee -a $LOGFILE


if [ $arch -eq 1 ]; then			##  For armf install  ##
	if [ $hostn = raspberrypi ]; then
			echo "Fresh Install...proceeding as normal." | tee -a $LOGFILE
	else
			echo "Hostname is currently set to $hostn" | tee -a $LOGFILE
			echo "Resetting Hostname to default of raspberrypi" | tee -a $LOGFILE
			echo "Updated /etc/hostname and /etc/hosts with raspberrypi" | tee -a $LOGFILE
			sudo sed -i "s/$hostn/raspberrypi/g" /etc/hostname | tee -a $LOGFILE
			sudo sed -i "s/$hostn/raspberrypi/g" /etc/hosts | tee -a $LOGFILE
	fi
else [ $arch -eq 0 ] 				##  For x86 VM  ##
	if [ $hostn = raspberry ]; then
			echo "Fresh Install...proceeding as normal." | tee -a $LOGFILE
	else
			echo "Hostname is currently set to $hostn" | tee -a $LOGFILE
			echo "Resetting Hostname to default of raspberry" | tee -a $LOGFILE
			echo "Updated /etc/hostname and /etc/hosts with raspberry" | tee -a $LOGFILE
			sudo sed -i "s/$hostn/raspberry/g" /etc/hostname | tee -a $LOGFILE
			sudo sed -i "s/$hostn/raspberry/g" /etc/hosts | tee -a $LOGFILE
	fi
fi


echo "############################" | tee -a $LOGFILE
echo "##      Network Test      ##" | tee -a $LOGFILE
echo "############################" | tee -a $LOGFILE
echo | tee -a $LOGFILE
echo "Testing network connection..." | tee -a $LOGFILE
echo | tee -a $LOGFILE

if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
  	echo "IPv4 is up" | tee -a $LOGFILE
	echo "Continuing install."
	echo | tee -a $LOGFILE
	network_status=up
else
  	echo "IPv4 is down"
	echo "No network connection.  Can not continue install without network connection.  Exiting..."
	network_status=down | tee -a $LOGFILE
	exit
fi

while [ "$choice" != "s" ]
do
	        echo "##################"
		echo "#                #"
		echo "# 1) EntrancePi  #"
		echo "# 2) MissionsPi  #"
		echo "# 3) ChildrensPi #"
		echo "# 4) EastPi      #"
		echo "# 5) WestPi      #"
		echo "# 6) ServerPi    #"
		echo "# s) Skip        #"
		echo "#                #"
		echo "##################"
		echo
		echo -n "Setup this Pi as: "
	        read choice
 		

	        case $choice in
	        	'1')	opt="EntrancePi"
				echo -n "What number $opt is this (1, 2, 3...etc...)? "
				read client_number
				final_hostname=$opt$client_number
				opt=$final_hostname
				echo Setting Hostname as $opt	
				echo "Updated /etc/hostname and /etc/hosts with $opt" | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hostname | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hosts | tee -a $LOGFILE
				echo | tee -a $LOGFILE
				break;;
			'2')	opt="MissionsPi"
				echo -n "What number $opt is this (1, 2, 3...etc...)? "
				read client_number
				final_hostname=$opt$client_number
				opt=$final_hostname
				echo Setting Hostname as $opt	
			       	echo "Updated /etc/hostname and /etc/hosts with $opt" | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hostname | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hosts | tee -a $LOGFILE
				echo | tee -a $LOGFILE
				break;;	
			'3')	opt="ChildrenPi"
				echo -n "What number $opt is this (1, 2, 3...etc...)? "
				read client_number
				final_hostname=$opt$client_number
				opt=$final_hostname
				echo Setting Hostname as $opt	
			       	echo "Updated /etc/hostname and /etc/hosts with $opt" | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hostname | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hosts | tee -a $LOGFILE
				echo | tee -a $LOGFILE
				break;;
			'4')    opt="WestPi"
				echo Setting Hostname as $opt	
			       	echo "Updated /etc/hostname and /etc/hosts with $opt" | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hostname | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hosts | tee -a $LOGFILE
				echo | tee -a $LOGFILE
				break;;
			'5')   	opt="EastPi"
				echo Setting Hostname as $opt	
			       	echo "Updated /etc/hostname and /etc/hosts with $opt" | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hostname | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hosts | tee -a $LOGFILE
				echo | tee -a $LOGFILE
				break;;			
			'6')	opt="ServerPi"	
			       	echo "Updated /etc/hostname and /etc/hosts with $opt" | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hostname | tee -a $LOGFILE
				sudo sed -i "s/$hostn/$opt/g" /etc/hosts | tee -a $LOGFILE
				
				while true; do
    					read -p "Do you wish to use Dropbox Syncing (y/n)? " yn
    					case $yn in
        					[Yy]* ) read -p "Paste OAUTH ACCESS TOKEN here: " dropbox_token; dropbox_access_token=$dropbox_token; dropbox_enabled=0; break;;
        					[Nn]* ) dropbox_enabled=1; break;;
        					* ) echo "Please answer yes or no.";;
    					esac
				done
				echo OAUTH ACCESS TOKEN $dropbox_access_token $dropbox_option  ## Used for troubleshooting ##
				#exit  ## Used for troubleshooting ##

				echo | tee -a $LOGFILE
				break;;
			's') echo "Skip"
				echo "Skipping hostname setting" | tee -a $LOGFILE
				echo | tee -a $LOGFILE
				echo "Skip was selected." >> $LOGFILE
				echo "You will need to go in and manually set the hostname after this script completes." | tee -a $LOGFILE
				echo "This is done in /etc/hosts and /etc/hostname" | tee -a $LOGFILE
				sleep 10
				break;;
		 	*)   echo "menu item is not available; try again!" 
				;;
	        esac
done


echo "#############################################" >> $LOGFILE 2>&1
echo "##  Start/Enable/Edit ssh/sudo on boot up  ##" | tee -a $LOGFILE
echo "#############################################" >> $LOGFILE 2>&1
echo | tee -a $LOGFILE
systemctl enable ssh | tee -a $LOGFILE
systemctl start ssh | tee -a $LOGFILE
sed -i '/#   StrictHostKeyChecking ask/a StrictHostKeyChecking no ' /etc/ssh/ssh_config | tee -a $LOGFILE
sed -i '/StrictHostKeyChecking no/a UserKnownHostsFile=/dev/null ' /etc/ssh/ssh_config | tee -a $LOGFILE

echo "################################################" | tee -a $LOGFILE
echo "##  Starting $LOGFILE now...  ##" | tee -a $LOGFILE
echo "################################################" | tee -a $LOGFILE
echo | tee -a $LOGFILE

echo "##################################" | tee -a $LOGFILE
echo "##  Setting up /etc/locale.gen  ##"  | tee -a $LOGFILE
echo "##################################" | tee -a $LOGFILE
sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen | tee -a $LOGFILE
sed -i 's/en_GB.UTF-8 UTF-8/# en_GB.UTF-8 UTF-8/' /etc/locale.gen | tee -a $LOGFILE
sed -i 's/en_GB.UTF-8/en_US.UTF-8/' /etc/locale.gen | tee -a $LOGFILE
sed -i 's/LANG=en_GB.UTF-8/LANG=en_US.UTF-8/' /etc/default/locale | tee -a $LOGFILE
locale-gen en_US.UTF-8 | tee -a $LOGFILE
update-locale en_US.UTF-8 | tee -a $LOGFILE
echo | tee -a $LOGFILE


echo "##################################################" | tee -a $LOGFILE
echo "##  Update Keyboard to US /etc/default/keyboard ##"  | tee -a $LOGFILE
echo "##################################################" | tee -a $LOGFILE
sed -i 's/XKBMODEL=""/XKBMODEL="pc105"/' /etc/default/keyboard | tee -a $LOGFILE
sed -i 's/XKBLAYOUT="gb"/XKBLAYOUT="us"/' /etc/default/keyboard | tee -a $LOGFILE
sed -i 's/BACKSPACE=""/BACKSPACE="guess"/' /etc/default/keyboard | tee -a $LOGFILE
echo | tee -a $LOGFILE



echo "##########################" | tee -a $LOGFILE
echo "##      $opt      ##" | tee -a $LOGFILE
echo "##########################" | tee -a $LOGFILE
echo | tee -a $LOGFILE


echo "########################" | tee -a $LOGFILE
echo "##  Setting Timezone  ##" | tee -a $LOGFILE
echo "########################" | tee -a $LOGFILE
echo | tee -a $LOGFILE 
cp /usr/share/zoneinfo/America/New_York /etc/localtime | tee -a $LOGFILE
echo | tee -a $LOGFILE


echo "####################################" | tee -a $LOGFILE
echo "##  Change/Create pi/piadmin user ##" | tee -a $LOGFILE
echo "####################################" | tee -a $LOGFILE
echo "Creating piadmin user" >> $LOGFILE
sudo useradd -m -G sudo -p $(echo $piadminpasswd | openssl passwd -1 -stdin) -s /bin/bash piadmin | tee -a $LOGFILE
echo "Changing $currentuser user password" >> $LOGFILE
sudo usermod --password $pipasswd $currentuser | tee -a $LOGFILE
#echo "$currentuser:$pipasswd" | sudo chpasswd
echo "$serveruser:$serveruserpasswd" | sudo chpasswd
echo | tee -a $LOGFILE


echo "###############################################" | tee -a $LOGFILE
echo "## Start system update and software removal  ##"  | tee -a $LOGFILE
echo "###############################################" | tee -a $LOGFILE
echo | tee -a $LOGFILE
rm /usr/share/raspi-ui-overrides/applications/python-games.desktop
rm /usr/share/raspi-ui-overrides/applications/raspi_resources.desktop
rm /usr/share/raspi-ui-overrides/applications/magpi.desktop
rm -rf /home/$currentuser/python_games

echo "########################" | tee -a $LOGFILE
echo "## Disable Bluetooth  ##" | tee -a $LOGFILE
echo "########################" | tee -a $LOGFILE
echo | tee -a $LOGFILE
echo "# Disable Bluetooth" >> /boot/config.txt
echo "dtoverlay=pi3-disable-bt" >> /boot/config.txt
systemctl disable hciuart.service | tee -a $LOGFILE
systemctl disable bluealsa.service | tee -a $LOGFILE
systemctl disable bluetooth.service | tee -a $LOGFILE


echo "#############################" | tee -a $LOGFILE
echo "## Start software removal  ##" | tee -a $LOGFILE
echo "#############################" | tee -a $LOGFILE
echo | tee -a $LOGFILE

if [ $arch -eq 1 ]; then
	apt-get autoremove -y wolf* sonic-pi sense-hat sense-emu-tools scratch* nodered greenfoot geany* bluej libreoffice* claws-mail minecraft-pi idle* thonny* realvnc-vnc* | tee -a $LOGFILE

else [ $arch -eq 0 ]
	apt-get autoremove -y wolf* sonic-pi sense-hat sense-emu-tools scratch* greenfoot geany* bluej libreoffice* claws-mail idle* thonny* | tee -a $LOGFILE

fi


if [ $opt = ServerPi ]; then

	## For Server ##

	echo "######################" | tee -a $LOGFILE
	echo "##  Server Install  ##" | tee -a $LOGFILE
	echo "######################" | tee -a $LOGFILE
	
	apt-get update | tee -a $LOGFILE
	apt-get install -y gawk libsigsegv2 libpcre3 libpcre3-dev libpcre16-3 libpcre32-3 libpcrecpp0v5 rsync samba vlc build-essential libssl-dev libpcre++-dev zlib1g-dev libcurl4-openssl-dev libnet-ssleay-perl libauthen-pam-perl libio-pty-perl apt-show-versions samba bind9 locate nmap nginx | tee -a $LOGFILE
	apt-get upgrade -y | tee -a $LOGFILE
	mkdir /home/$currentuser/install-packages | tee -a $LOGFILE
	printf 'pibroadcast_version 1.3.1\n' >> /home/$currentuser/.pibroadcast_settings  ## Setting Default Settings File ##
	printf 'log_upload true\n' >> /home/$currentuser/.pibroadcast_settings  ## Setting Default Settings File ##


	## Used for Troubleshooting ##
	echo "################################"
	echo "## Current User: $currentuser ##"
	echo "################################"
	## Used for Troubleshooting ##

	echo "#####################" | tee -a $LOGFILE
	echo "##  nginx Install  ##" | tee -a $LOGFILE
	echo "#####################" | tee -a $LOGFILE

	sudo apt-get remove nginx -y
	sudo apt-get clean nginx -y
	mkdir /home/$currentuser/nginx-build
	cd /home/$currentuser/nginx-build
	wget http://nginx.org/download/nginx-1.21.3.tar.gz
	#wget https://github.com/arut/nginx-rtmp-module/archive/master.zip
	git clone https://github.com/arut/nginx-rtmp-module
	tar -zxvf nginx-*tar.gz
	#unzip master.zip--without-http_rewrite_module
	cd /home/$currentuser/nginx-build/nginx-1.21.3
	./configure --prefix=/var/www --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx.pid --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-http_ssl_module --without-http_proxy_module --add-module=/home/$currentuser/nginx-build/nginx-rtmp-module | tee -a $LOGFILE

	make -j4 | tee -a $LOGFILE
	sudo make -j4 install | tee -a $LOGFILE
	sudo rm /var/www/html/*.html
	sudo wget --directory-prefix=/var/www/html/ https://gist.githubusercontent.com/spfaffly/d774f87b8cf9a1837d05/raw/2223babec34cb3e1732031556549eb307024572f/index.html | tee -a $LOGFILE

	echo "
		
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

}
rtmp {
        server {
                listen 1935;
                chunk_size 4096;

                application live {
                        live on;
                        record off;
                        }
                }
        }" > /etc/nginx/nginx.conf | tee -a $LOGFILE
	chown nobody:root -R /var/www/*
	cd /home/$currentuser
	rm -rf /home/$currentuser/nginx-build
	
	## Used for Troubleshooting ##
	echo "################################"
	echo "## Current User: $currentuser ##"
	echo "################################"
	## Used for Troubleshooting ##

	#echo "######################" | tee -a $LOGFILE
	#echo "##  Webmin Install  ##" | tee -a $LOGFILE
	#echo "######################" | tee -a $LOGFILE

	#wget --directory-prefix=/home/$currentuser/install-packages/ http://www.webmin.com/download/deb/webmin-current.deb | tee -a $LOGFILE
	#dpkg -i /home/$currentuser/install-packages/webmin-current.deb | tee -a $LOGFILE

	#rm -rf /home/$currentuser/install-packages | tee -a $LOGFILE
	mkdir -p /smb_shares/watch_folder/syncd_clients | tee -a $LOGFILE
	mkdir -p /smb_shares/scripts | tee -a $LOGFILE
	mkdir -p /smb_shares/slides | tee -a $LOGFILE

		
	echo "####################################" | tee -a $LOGFILE
	echo "##  Updating /etc/samba/smb.conf  ##" | tee -a $LOGFILE
	echo "####################################" | tee -a $LOGFILE

		echo "
			[global]

				workgroup = WORKGROUP
				server string = %h server
				dns proxy = no
				log file = /var/log/samba/log.%m
				max log size = 1000
				syslog only = no
				syslog = 0

				panic action = /usr/share/samba/panic-action %d

				security = user
				encrypt passwords = true
				passdb backend = tdbsam
				obey pam restrictions = yes
				unix password sync = yes

				passwd program = /usr/bin/passwd %u
				passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
				pam password change = yes
				map to guest = bad user

				load printers = no
				printcap name = /dev/null
				disable spoolss = yes


			[slides]
				force create mode = 755
				force group = users
				writeable = yes
				force directory mode = 755
				write list = piadmin
				path = /smb_shares/slides
				user = piadmin
				force user = piadmin
				valid users = piadmin
				comment = Place pictures and ppt slideshows in these folders

			[scripts]
				path = /smb_shares/scripts

			[watch_folder]
				path = /smb_shares/watch_folder
				writeable = yes
				valid users = piadmin
				write list = piadmin

		" > /etc/samba/smb.conf | tee -a $LOGFILE

	echo "##########################################" | tee -a $LOGFILE
	echo "##  Setting up piadmin on Samba Server  ##" | tee -a $LOGFILE
	echo "##########################################" | tee -a $LOGFILE

	(echo "$piadminpasswd"; echo "$piadminpasswd") | sudo smbpasswd -a piadmin | tee -a $LOGFILE
	sudo chmod 755 -R /smb_shares/slides/
	sudo chmod -R 777 /smb_shares/watch_folder


	echo "##################################################################" | tee -a $LOGFILE
	echo "##  Setting up autologin variable in /etc/lightdm/lightdm.conf  ##" | tee -a $LOGFILE
	echo "##################################################################" | tee -a $LOGFILE
	sudo sed -i 's/autologin-user=$currentuser/#autologin-user=$currentuser/' /etc/lightdm/lightdm.conf | tee -a $LOGFILE
	echo | tee -a $LOGFILE

	
	if [ $dropbox_enabled -eq 0 ]; then
 	
	echo "###########################################" | tee -a $LOGFILE
	echo "##  Install/Syncing Dropbox with Server  ##" | tee -a $LOGFILE
	echo "###########################################" | tee -a $LOGFILE
	
	echo $dropbox_access_token > /home/$currentuser/.dropbox_uploader
	echo $dropbox_access_token > /root/.dropbox_uploader
	chown $currentuser:$currentuser /home/$currentuser/.dropbox_uploader
	mkdir /home/$currentuser/dropbox_media_slides/	
	chown $currentuser:$currentuser /home/$currentuser/dropbox_media_slides
	
	echo "-- Begin Dropbox sync --" | tee -a $LOGFILE 
	echo "" | tee -a $LOGFILE 
	chown -R $currentuser:$currentuser `pwd`/pibroadcast-scripts/Dropbox-Uploader/
	echo $USER : $UID | tee -a $LOGFILE
	#sudo -H -u $currentuser `pwd`/pibroadcast-scripts/Dropbox-Uploader/dropbox_uploader.sh download /Media_Slides/ServerPi/ /home/$currentuser/dropbox_media_slides/ | tee -a $LOGFILE
	`pwd`/pibroadcast-scripts/Dropbox-Uploader/dropbox_uploader.sh download /Media_Slides/ServerPi/ /home/$currentuser/dropbox_media_slides/ | tee -a $LOGFILE
	echo "-- Syncing All Dropbox and Server Folders --" | tee -a $LOGFILE
	rsync -avh --exclude=".*" /home/$currentuser/dropbox_media_slides/ServerPi/ /smb_shares/slides/ --delete | tee -a $LOGFILE
	sudo chmod -R 755 /home/$currentuser/dropbox_media_slides/
	sudo chmod 755 -R /smb_shares/slides/

	printf 'log_upload true\n' >> /home/$currentuser/.pibroadcast_settings  ## Setting Default Server Settings File ##

	fi

	echo "#######################################################" | tee -a $LOGFILE
	echo "##  Moving scripts folder from /boot and cleaning up ##" | tee -a $LOGFILE
	echo "#######################################################" | tee -a $LOGFILE
	echo "Working directory: "`pwd`		## Used for Troubleshooting ##
	echo "Current user: " $currentuser	## Used for Troubleshooting ##
	echo "Starting Install directory: " $starting_install_directory	

	mv $starting_install_directory/pibroadcast/pibroadcast-scripts/server_menu.sh /home/$currentuser/server_menu.sh
	chown -R $currentuser:$currentuser /home/$currentuser
	chmod +x /home/$currentuser/server_menu.sh	
	echo "sudo ~/server_menu.sh" >> /home/$currentuser/.bashrc
	mv $starting_install_directory/pibroadcast/pibroadcast-scripts/ /smb_shares/scripts/
	rm -rf `pwd`/pibroadcast-scripts
	mkdir /home/piadmin/pibroadcast_update
	chmod 777 /home/piadmin/pibroadcast_update


else	## For Clients ##

	echo "######################" | tee -a $LOGFILE
	echo "##  Client Install  ##" | tee -a $LOGFILE
	echo "######################" | tee -a $LOGFILE

	if [ $arch -eq 1 ]; then		
		apt-get update && apt-get install -y feh omxplayer rsync nmap | tee -a $LOGFILE
	else [ $arch -eq 0 ]
		apt-get update && apt-get install -y feh rsync nmap | tee -a $LOGFILE
	fi
	apt-get upgrade -y | tee -a $LOGFILE
	echo | tee -a $LOGFILE

	

	echo "#################################################" | tee -a $LOGFILE
	echo "##  Get PiBroadcastServer info for /etc/hosts  ##"  | tee -a $LOGFILE
	echo "#################################################" | tee -a $LOGFILE
	echo | tee -a $LOGFILE
	nmap -sn `ifconfig eth0 | grep 'inet ' | awk '{print $2}' | awk -F "." '/1/ {print $1"."$2"."$3".*"}'` | grep ServerPi | awk '{print $6"     " $5}' | sed 's/(//g' | sed 's/)//g' | sudo tee --append /etc/hosts
	echo | tee -a $LOGFILE

	echo "###############################################" | tee -a $LOGFILE
	echo "##  Create directories to mount from server  ##"  | tee -a $LOGFILE
	echo "###############################################" | tee -a $LOGFILE
	mkdir /server_folders | tee -a $LOGFILE
	mkdir /server_folders/scripts | tee -a $LOGFILE
	mkdir /server_folders/slides | tee -a $LOGFILE
	mkdir /server_folders/watch_folder | tee -a $LOGFILE
	echo | tee -a $LOGFILE


	echo "################################################################" | tee -a $LOGFILE
	echo "##  Create local directories to sync from server directories  ##"  | tee -a $LOGFILE
	echo "################################################################" | tee -a $LOGFILE
	mkdir -p /home/$currentuser/local_sync/scripts | tee -a $LOGFILE
	mkdir /home/$currentuser/local_sync/slides | tee -a $LOGFILE
	echo | tee -a $LOGFILE


	echo "#######################" | tee -a $LOGFILE
	echo "##  Edit /etc/fstab  ##"  | tee -a $LOGFILE
	echo "#######################" | tee -a $LOGFILEecho | tee -a $LOGFILE
	echo "//ServerPi/slides/ /server_folders/slides cifs username=$serveruser,password=$serveruserpasswd 0 0" >> /etc/fstab | tee -a $LOGFILE
	echo "//ServerPi/watch_folder/ /server_folders/watch_folder cifs username=$serveruser,password=$serveruserpasswd,defaults 0  0" >> /etc/fstab | tee -a $LOGFILE
	echo "//ServerPi/scripts/ /server_folders/scripts cifs username=$serveruser,password=$serveruserpasswd,defaults 0 0" >> /etc/fstab | tee -a $LOGFILE
	echo | tee -a $LOGFILE


	echo "############################################################" | tee -a $LOGFILE
	echo "##  Setting up /etc/rc.local to start client_services.sh  ##" | tee -a $LOGFILE
	echo "############################################################" | tee -a $LOGFILE
	sed -i '/fi/a /home/$currentuser/local_sync/scripts/client_services.sh & ' /etc/rc.local | tee -a $LOGFILE
	cp `pwd`/pibroadcast/pibroadcast-scripts/client_services.sh /home/$currentuser/local_sync/scripts/client_services.sh | tee -a $LOGFILE  ## Added as a temp fix ##
	echo | tee -a $LOGFILE


	echo "#########################################" | tee -a $LOGFILE
	echo "##  Mount server directories and sync  ##"  | tee -a $LOGFILE
	echo "#########################################" | tee -a $LOGFILE
	mount -av | tee -a $LOGFILE
	rsync -avh --exclude=".*" /server_folders/slides/ /home/$currentuser/local_sync/slides/ | tee -a $LOGFILE
	rsync -avh --exclude=".*" /server_folders/scripts/ /home/$currentuser/local_sync/scripts/  | tee -a $LOGFILE
	[ "$(ls -A /home/$currentuser/local_sync/slides/)" ] && echo "/home/$currentuser/local_sync/slides folder Not Empty" || mkdir /home/$currentuser/local_sync/slides/Empty && cp `pwd`/pibroadcast-scripts/Default_Screen.jpg /home/$currentuser/local_sync/slides/Empty/
	echo | tee -a $LOGFILE


	echo "#############################################################################################" | tee -a $LOGFILE
	echo "##  /home/$currentuser/.config/lxsession/LXDE-pi/autostart to stop screensaver and clean up desktop  ##" | tee -a $LOGFILE
	echo "#############################################################################################" | tee -a $LOGFILE
	rm /home/$currentuser/.config/lxsession/LXDE-pi/autostart  | tee -a $LOGFILE
	mkdir -p /home/$currentuser/.config/lxsession/LXDE-pi/ | tee -a $LOGFILE
	touch /home/$currentuser/.config/lxsession/LXDE-pi/autostart | tee -a $LOGFILE
	echo "@lxpanel --profile LXDE-pi" >> /home/$currentuser/.config/lxsession/LXDE-pi/autostart | tee -a $LOGFILE
	echo "@pcmanfm --desktop --profile LXDE-pi" >> /home/$currentuser/.config/lxsession/LXDE-pi/autostart | tee -a $LOGFILE
	echo "@point-rpi" >> /home/$currentuser/.config/lxsession/LXDE-pi/autostart | tee -a $LOGFILE
	echo "@unclutter" >> /home/$currentuser/.config/lxsession/LXDE-pi/autostart | tee -a $LOGFILE
	echo "@xset s 0 0" >> /home/$currentuser/.config/lxsession/LXDE-pi/autostart | tee -a $LOGFILE
	echo "@xset s noblank" >> /home/$currentuser/.config/lxsession/LXDE-pi/autostart | tee -a $LOGFILE
	echo "@xset s noexpose" >> /home/$currentuser/.config/lxsession/LXDE-pi/autostart | tee -a $LOGFILE
	echo "@xset dpms 0 0 0" >> /home/$currentuser/.config/lxsession/LXDE-pi/autostart | tee -a $LOGFILE
	echo | tee -a $LOGFILE

	mkdir /home/piadmin/pibroadcast_update
	chmod 777 /home/piadmin/pibroadcast_update

	mv `pwd`/pibroadcast/pibroadcast-scripts/client_menu.sh /home/$currentuser/.bashrc
	chown $currentuser:$currentuser /home/$currentuser/.bashrc
	chown -R $currentuser:$currentuser /home/$currentuser/
	printf 'feh 10\nserver_sync true\nsync_scripts true\nsync_slides true\nbroadcast_watch true\nclient_pid_create true\nlog_upload true\n' >> /home/$currentuser/.pibroadcast_settings  ## Setting Default Client Settings File ##
	rm -rf `pwd`/pibroadcast/pibroadcast/pibroadcast-scripts
	

fi

echo | tee -a $LOGFILE

rm /etc/profile.d/sshpwd.sh | tee -a $LOGFILE  		##  Remove info popup about ssh and not changing pi passwd on command line  ##
rm /etc/xdg/lxsession/LXDE-pi/sshpwd.sh | tee -a $LOGFILE  	##  Remove info popup about ssh and not changing pi passwd on GUI  ##
#rm /home/$currentuser/.config/autostart/pi-conf-backup.desktop | tee -a $LOGFILE  ## Remove update info pop up after system restart  ##
apt-get autoremove -y | tee -a $LOGFILE 			##  Doing a final cleanup of system before reboot  ##
apt-get purge -y  						##  Doing a final cleanup of system before reboot  ##
#rm `pwd`/pibroadcast/fresh_install.sh					##  Doing a final cleanup of system before reboot  ##

echo "###################" | tee -a $LOGFILE
echo "##  Rebooting Pi ##"  | tee -a $LOGFILE
echo "###################" | tee -a $LOGFILE
#reboot  | tee -a $LOGFILE

exit
