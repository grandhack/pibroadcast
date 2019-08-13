#!/bin/bash
#==============================================================================
#title          :server_menu.sh
#description    :This script is used on boot for the server
#author		:Justin Holt - githubjh@gmail.com
#date           :April 08 2019
#version        :1.3 
#usage		:
#notes          :This is the menu file when you log in to the server.
#log file	:/var/log/pibroadcast-server.log
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

LOGFILE=/var/log/pibroadcast-server.log
L_DIR=/smb_shares
connected_host_ip=$(sudo smbstatus -fb | awk 'FNR > 4 {print $4 $5}')
connected_host_ip1=$(ls /smb_shares/watch_folder/*.pid | gawk -F/ '{print $4}' | gawk -F. '{print $1}')
#pibroadcast_version=$(grep pibroadcast_version /home/pi/.pibroadcast_settings | awk '{print $2}')
pibroadcast_version="1.3"

export LC_ALL=C

function broadcast() {
broadcast_test=$(test -f $L_DIR/watch_folder/broadcast_begin; echo $?)
        if [ $broadcast_test == 0 ]; then
                broadcast_status=Running
        else
                broadcast_status=Stopped
        fi

  answer=$(whiptail --title "Broadcast Control" --yesno --yes-button Start --no-button Stop "$1" 0 0 3>&1 1>&2 2>&3; echo $?)
  echo "Answer <$answer>"
        if [ $answer == 0 ]; then
			sudo echo "-- Starting Broadcast --" 2>&1 >> $LOGFILE
             sudo touch $L_DIR/watch_folder/broadcast_begin
        else
             broadcast_test=$(test -f $L_DIR/watch_folder/broadcast_begin; echo $?)
			if [ $broadcast_test == 0 ]; then
				sudo echo "-- Ending Broadcast --" 2>&1 >> $LOGFILE
             	sudo rm /$L_DIR/watch_folder/broadcast_begin
             fi
        fi
}


function advancedMenu() {
    ADVSEL=$(whiptail --title "$(hostname) Menu" --fb --menu --cancel-button Exit "\nChoose an option" 20 40 9 \
        "1" "Sync Dropbox" \
	"2" "Client Control" \
        "3" "Broadcast Control" \
	"4" "Update PI Broadcast Software" \
	"5" "System Config" \
	"6" "Update System OS" \
	"7" "System Info" \
	"8" "Reboot $(hostname)" \
	"9" "Power Off $(hostname)" 3>&1 1>&2 2>&3)
    case $ADVSEL in
        1)
		echo "$(date): -- Dropbox Sync --" 2>&1 >> $LOGFILE
		echo "$(date): -- Begin Dropbox sync --" 2>&1 >> $LOGFILE
		rm -rf /home/pi/dropbox_media_slides/
		sudo -u pi /smb_shares/scripts/Dropbox-Uploader/dropbox_uploader.sh download /Media_Slides/ServerPi /home/pi/dropbox_media_slides/ | tee -a $LOGFILE
		echo "$(date): -- Syncing All Dropbox and Server Folders --" 2>&1 >> $LOGFILE
		chmod -R 755 /home/pi/dropbox_media_slides/
		chmod -R 755 /smb_shares/slides/
		rsync -avh --exclude=".*" /home/pi/dropbox_media_slides/ /smb_shares/slides/ --delete | tee -a $LOGFILE
		echo "$(date): -- Finish Dropbox sync --" 2>&1 >> $LOGFILE 
		chmod 755 -R /smb_shares/slides/

		for i in $connected_host_ip1
		do
			touch /smb_shares/watch_folder/syncd_clients/"$i.pid.sync_not_complete"
        	echo "$(date): -- Created $i.pid.sync_not_complete file --" | tee -a $LOGFILE 2>&1
        	chmod 755 /smb_shares/watch_folder/syncd_clients/"$i.pid.sync_not_complete"
		done
		
		touch /smb_shares/watch_folder/sync_update 

		echo "$(date): -- Sync_update file created for clients--" >> $LOGFILE 2>&1
		echo "$(date): -- Waiting on all clients to finish updating --" >> $LOGFILE 2>&1

		while [ "$(ls /smb_shares/watch_folder/syncd_clients/ | grep not)" ]; do

			sleep .002
		done
		echo "$(date): -- All clients have finished syncing...removing sync_update file --" >> $LOGFILE 2>&1
		rm /smb_shares/watch_folder/sync_update
		echo "$(date): -- Sync_update file Removed --" >> $LOGFILE 2>&1		

    		advancedMenu
		;;

	2)
            	advancedClientMenu
		advancedMenu
		;;

        3)
            	broadcast "Broadcast is currently: $broadcast_status "
		advancedMenu
        	;;

	4)
            	echo "$(date): -- PI Broadcast Software Update --" 2>&1 >> $LOGFILE
		files_check=$(test -f /home/piadmin/pibroadcast/update; echo $?)
		if [ $files_check == 0 ]; then
			echo "$(date): -- Files detected --" 2>&1 >> $LOGFILE
			echo "$(date): -- These files will be updated: $(ls /home/piadmin/pibroadcast_update) --" | tee -a $LOGFILE
			chmod +x /home/piadmin/pibroadcast_update/*.sh
				if [ -e server_menu.sh ]; then
					echo "$(date): -- Moving server_menu.sh --" 2>&1 >> $LOGFILE
					mv /home/piadmin/pibroadcast_update/server_menu.sh /home/pi/server_menu.sh
					chown pi:pi /home/pi/server_menu.sh
					chmod +x /home/pi/server_menu.sh
					whiptail --msgbox "-- You must reboot the server to complete this update --" 7 45
					echo "-- You must reboot the server to complete this update --" 2>&1 >> $LOGFILE
					break
				fi
			mv /home/piadmin/pibroadcast_update/*.{sh,md,jpg} /smb_shares/scripts/
			echo "$(date): -- Changing file permissions --" 2>&1 >> $LOGFILE
			chown -R pi:pi ./*
			echo "$(date): -- Updating Clients --" 2>&1 >> $LOGFILE

			for i in $connected_host_ip1
				do
        				touch /smb_shares/watch_folder/syncd_clients/$i.pid.sync_not_complete
        				echo "$(date): -- Created $i.pid.sync_not_complete file --" | tee -a $LOGFILE 2>&1
					chmod 755 /smb_shares/watch_folder/syncd_clients/$i.pid.sync_not_complete
				done

			sudo touch /smb_shares/watch_folder/sync_update 
		
			echo "$(date): -- Sync_update file created --" 2>&1 >> $LOGFILE
			echo "$(date): -- Waiting on all clients to finish updating --" 2>&1 >> $LOGFILE

			while [ "$(ls /smb_shares/watch_folder/syncd_clients/ | grep not)" ]; do

				sleep .002
			done
			echo "$(date): -- All clients have finished syncing...removing sync_update file --" 2>&1 >> $LOGFILE
			sudo rm /smb_shares/watch_folder/sync_update
			echo "$(date): -- File Removed --" 2>&1 >> $LOGFILE
			echo "$(date): -- Rebooting Clients to complete software update --" 2>&1 >> $LOGFILE
			sudo touch /smb_shares/watch_folder/client_reboot
		else
			echo "$(date): -- No files detected --" 2>&1 >> $LOGFILE
			echo "$(date): -- Nothing to update --" 2>&1 >> $LOGFILE
			whiptail --msgbox "No files detected.  Nothing to update" 7 45
			
		fi
		advancedMenu
        	;;

	5)
            	echo "$(date): -- System Config --" 2>&1 >> $LOGFILE
		sudo raspi-config
		advancedMenu
        	;;
	
	6)
            	echo "$(date): -- Update System OS --" >> $LOGFILE 2>&1
		if (whiptail --title "Update System OS" --yesno "\n** WARNING: This may have unforeseen affects on the broadcast or client sync ability.  **\nThis will reboot the system after it has completed.  Do you still wish to proceed?" 12 93)
		then
			# Run apt-get update, saves time. Instead of for every install running apt-get update
    			{
    			i=0
    			while read -r line; do
        			i=$(( $i + 50 ))
        			echo $i
    			done < <(sudo apt-get update)
    			} | whiptail --title "System Update Progress" --gauge "\nPlease wait while repo's update" 8 60 0 

    			{
    			i=0
    			while read -r line; do
        			i=$(( $i + 1 ))
        			echo $i
    			done < <(sudo apt-get full-upgrade -y)
    			} | whiptail --title "System Update Progress" --gauge "\nPlease wait while system updates" 8 60 0

    			{
    			i=0
    			while read -r line; do
       				i=$(( $i + 1 ))
        			echo $i
    			done < <(sudo apt-get autoremove -y)
    			} | whiptail --title "System Update Progress" --gauge "\nRemoving old software" 8 60 0

    			{
   			 i=99
    			while read -r line; do
    			    	i=$(( $i + 1 ))
        			echo $i
    			done < <(sudo apt-get clean)
    			} | whiptail --title "System Update Progress" --gauge "\nClearing cache" 8 60 0

			echo "Reboot System"
			if (whiptail --title "System Reboot" --yesno "Reboot machine?" 8 78)
    			then
				sudo reboot
    			else
				echo "$(date): -- System Update Cancelled --" 2>&1 >> $LOGFILE
				echo /dev/null
    			fi

	    	else
       			echo /dev/null 
    		fi
		advancedMenu
		;;

	7)	echo "$(date): -- System Info --" 2>&1 >> $LOGFILE
		whiptail --title "System Information" --msgbox "$(
		echo "System name: $(hostname)"
		echo "Pi Broadcast Software Version: $pibroadcast_version"
		echo "System temp: $(awk '{printf("%.1f°F\n",(($1*1.8)/1e3)+32)}' /sys/class/thermal/thermal_zone0/temp)"
		echo --
		echo "System IP: eth0: $(ifconfig | grep -A 1 'eth0' | grep -A 1 'inet' | awk ' { FS = " "; print $2}') / wlan0: $(ifconfig | grep -A 1 'wlan0' | grep -A 1 'inet' | awk ' { FS = " "; print $2}')"
		echo --
		##
		echo "System Uptime:" $(uptime | awk -F'( |,|:)+' '{print $6,$7",",$8,"hours,",$9,"minutes."}')
		##
		echo --
		echo "Current Connected Clients:"
		    	#for i in $connected_host_ip
				
			#	do
        				
        				#echo "	$(cat /smb_shares/watch_folder/$i.pid | awk -F "--" '/1/ {print $3}')-- $i" 2>&1 | tee -a $LOGFILE
			#		echo "-- $i" 2>&1 | tee -a $LOGFILE
					
			#	done
sudo smbstatus -fb | awk 'FNR > 4 {print $4 $5}' | tr "(" : | tr ")" " " |  sed 's/ipv4//' | awk -F':' '{print "  "$1" -- "$3}'
broadcast_test=$(test -f $L_DIR/watch_folder/broadcast_begin; echo $?)
        if [ $broadcast_test == 0 ]; then
                echo "Broadcast is currently: Running"
        else
                echo "Broadcast is currently: Stopped"
        fi
		##
		)" 20 70
		advancedMenu
		;;
	
	8)
            	echo "$(date): -- Reboot System Menu --" 2>&1 >> $LOGFILE
		if (whiptail --title "System Reboot" --yesno "Reboot $(hostname)?" 8 40)
    		then
			echo "$(date): -- Reboot System Selected --" 2>&1 >> $LOGFILE
			sudo reboot
    		else
			echo "$(date): -- Reboot System Cancelled --" 2>&1 >> $LOGFILE
			echo /dev/null
    		fi
		advancedMenu
        	;;

	9)
            echo "$(date): -- Power off System Menu --" >> $LOGFILE 2>&1

		if (whiptail --title "Power off System" --yesno "Do you wish to power off $(hostname)?" 8 78)
    		then
			for i in $(seq 1 100)
			do
    				sleep .1 
    				echo $i
				done | whiptail --title 'Power off System' --gauge 'Shutting down system processes...' 6 60 0
				echo "$(date): -- Power off System Selected --" 2>&1 >> $LOGFILE
				sudo poweroff
    		else
        		echo "$(date): -- Power off System Cancelled --" 2>&1 >> $LOGFILE
			advancedMenu 
    		fi

		;;
    esac
}

function advancedClientMenu() {

		OPTION=$(whiptail --title "Change Hostname" --fb --menu "\nCurrent Machine Name: $(hostname)\n\nChoose your option" 20 50 5 \
			"1" "Sync Clients" \
			"2" "Reboot Client" 3>&1 1>&2 2>&3) 
		
		exitstatus=$?							## Check for Cancel Button ##
			if [ $exitstatus = 0 ]; then
    				echo "Your chosen option:" $OPTION >> /dev/null		## For testing ##
				echo $exitstatus >> /dev/null
			else
    				echo "You chose Cancel." >> /dev/null			## For testing ##
				advancedMenu
			fi
		
		case $OPTION in

			1)	echo "$(date): -- Advanced Client Menu --" 2>&1 >> $LOGFILE
				echo "$(date): -- Sync Clients Menu --" 2>&1 >> $LOGFILE

				for i in $connected_host_ip1
				
				do
					touch "/smb_shares/watch_folder/syncd_clients/$i.pid.sync_not_complete"
        			echo "$(date): -- Created $i.pid.sync_not_complete file --" 2>&1 | tee -a $LOGFILE
        			chmod 755 "/smb_shares/watch_folder/syncd_clients/$i.pid.sync_not_complete"
				done

				sudo touch /smb_shares/watch_folder/sync_update 
		
				echo "$(date): -- Sync_update file created for clients --" 2>&1 >> $LOGFILE
				echo "$(date): -- Waiting on all clients to finish updating --" 2>&1 >> $LOGFILE

				while [ "$(ls /smb_shares/watch_folder/syncd_clients/ | grep not)" ]; do

					sleep .002
				done
				echo "$(date): -- All clients have finished syncing...removing sync_update file --" 2>&1 >> $LOGFILE
				sudo rm /smb_shares/watch_folder/sync_update
				echo "$(date): -- Sync_update File Removed --" 2>&1 >> $LOGFILE
				echo "$(date): -- Rebooting Clients to complete update--" 2>&1 >> $LOGFILE
				sudo touch /smb_shares/watch_folder/client_reboot
				
				;;

			2) 	echo "$(date): -- Advanced Client Menu --" 2>&1 >> $LOGFILE
				echo "$(date): -- Reboot Clients Menu --" 2>&1 >> $LOGFILE
				if (whiptail --title "Client Reboot" --yesno "This will reboot all clients.  Would you like to continue?" 8 40)
    				then
					echo "$(date): -- Reboot Clients was selected --" 2>&1 >> $LOGFILE
					sudo touch /smb_shares/watch_folder/client_reboot 
    				else
					echo "$(date): -- Reboot Clients was NOT selected --" 2>&1 >> $LOGFILE
					echo /dev/null
    				fi
				;;
			esac


			
		}



advancedMenu


exit

