#!/bin/bash

#==============================================================================
#title          :client_menu.sh
#description    :This script is used on boot for each client
#author		:Justin Holt - tgithubjh@gmail.com
#date           :January 31 2019
#version        :1.5.1.1    
#usage		:
#notes          :This is the menu file when you log in to each client.
#log file	: ~/.pibroadcast-profile-menu.log (~ is the user home = /home/pi/)
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

LOGFILE=~/.pibroadcast-profile-menu.log
feh_slide_time=$(grep feh /home/pi/.pibroadcast_settings | awk '{print $2}')
broadcast_watch_status=$(grep broadcast_watch /home/pi/.pibroadcast_settings | awk '{print $2}')
host_ip=$(ifconfig eth0 | grep 'inet ' | awk '{print $2}')
host=$(hostname)
R_DIR="/server_folders/watch_folder"
L_DIR="/home/pi/local_sync/slides"
R_S_DIR="/server_folders/slides" 											
L_S_DIR="/home/pi/local_sync/slides"  											
R_SC_DIR="/server_folders/scripts"
L_SC_DIR="/home/pi/local_sync/scripts"
ERRORLOG=/var/log/pibroadcast-error.log
host_check=$(nmap -sn `ifconfig eth0 | grep 'inet ' | awk '{print $2}' | awk -F "." '/1/ {print $1"."$2"."$3".*"}'` | grep for | awk '{print $5}' | grep Pi | sed 's/(//g' | sed 's/)//g' | awk -F "." '/1/ {print $1}')
test_host=$(printf "$host_check" | grep $combine_newhost)
feh_delay=$(grep feh /home/pi/.pibroadcast_settings | awk '{print $2}')
server_sync_status=$(grep server_sync /home/pi/.pibroadcast_settings | awk '{print $2}')
script_sync_status=$(grep sync_scripts /home/pi/.pibroadcast_settings | awk '{print $2}')
slides_sync_status=$(grep sync_slides /home/pi/.pibroadcast_settings | awk '{print $2}')
broadcast_watch_status=$(grep broadcast_watch /home/pi/.pibroadcast_settings | awk '{print $2}')
client_pid_status=$(grep client_pid_create /home/pi/.pibroadcast_settings | awk '{print $2}')
#pibroadcast_version=$(grep pibroadcast_version /home/pi/.pibroadcast_settings | awk '{print $2}')
pibroadcast_version="1.3"

rm $LOGFILE > /dev/null


echo "$(date): -- Client Menu Start --" >> $LOGFILE

function advancedMenu() {
    ADVSEL=$(whiptail --title "$(hostname) Menu" --fb --menu --cancel-button Exit "\nChoose an option" 20 50 7 \
        "1" "Change Slide Pause" \
	"2" "Client Broadcast Settings" \
	"3" "Client Sync Settings" \
	"4" "Change Hostname (Slideshow)" \
	"5" "Update Server IP" \
        "6" "Client Settings Menu" \
	"7" "System Info" 3>&1 1>&2 2>&3)
	

exitstatus=$?							## Check for Cancel Button ##
	if [ $exitstatus = 0 ]; then
    		#echo "Your chosen option:" $OPTION >> /dev/null		## For testing ##
		echo $exitstatus >> /dev/null
	else
    		#echo "You chose Cancel." >> /dev/null			## For testing ##
		exit
	fi

    case $ADVSEL in
        1)
		feh_pause_menu=$(whiptail --title "Change Slide Time" --fb --inputbox "\nIt is currently: $feh_slide_time seconds.\nWhat would you like to change it to?" 10 60 3>&1 1>&2 2>&3)
		if [ -z "$feh_pause_menu" ]
		then
      			echo "\$feh_pause_menu is empty"
		else
      			echo "\$feh_pause_menu is NOT empty"
			sudo sed -i "s/$feh_slide_time/$feh_pause_menu/g" /home/pi/.pibroadcast_settings >> 2>&1 $LOGFILE 
			feh_pause_current=$feh_pause_menu
			sudo kill $(ps aux | grep [f]eh | awk '{print $2}') >> 2>&1 $LOGFILE
			sudo -u pi DISPLAY=:0.0 feh -Y -x -D "$feh_delay" -B black -F -Z -z -r $L_DIR/$slides_folder >> 2>&1 $LOGFILE &

		fi
		
		exitstatus=$?
		if [ $exitstatus = 0 ]; then
    			echo "$(date): -- Time is set to:  $feh_pause_menu --" >> 2>&1 $LOGFILE
    			advancedMenu
		else
    			echo "$(date): -- You chose Cancel --" >> 2>&1 $LOGFILE
    			advancedMenu
		fi

        ;;

	2)
           
	    	echo "$(date): -- Disable Broadcast --" >> 2>&1 $LOGFILE
		advancedMenu2		
		advancedMenu
        ;;

        
	3)
            	echo "$(date): -- Client Sync Settings --" >> 2>&1 $LOGFILE
		advancedMenu3
		advancedMenu
		
        ;;
	4)
            	echo "$(date): -- Change Hostname (Slideshow) --" >> 2>&1 $LOGFILE
		advancedMenu1
		
		
		
		if [ "$(hostname)" = "$combine_newhost" ]
		then
			echo "$(date): -- This is the same machine name --" >> 2>&1 $LOGFILE
			whiptail --msgbox "This machine name is already $(hostname)" 7 45
			advancedMenu1
		fi
			newhostnumber=$(whiptail --title "$newhostname Number#" --fb --inputbox "\nWhat number $newhostname is this going to be (1, 2, 3...etc...)? " 10 60 3>&1 1>&2 2>&3)
                	combine_newhost=$newhostname$newhostnumber	

		if [ -z "$newhostnumber" ]
                then
                        echo "\$newhostnumber is empty" >> /dev/null
			advancedMenu1
                else
                        echo "\$newhostnumber is NOT empty" >> /dev/null
                                {
                                for ((i = 0 ; i <=100 ; i+=20)); do
                                sleep .1
                                echo $i
                                done < <($test_host)
                                } | whiptail --gauge "Please wait while scanning network" 6 60 0
                fi
		
		
                if [ "$test_host" = "$combine_newhost" ]
                then
                        echo "$(date): -- There is already a $combine_newhost on this network.  You will have to choose another number --" >> 2>&1 $LOGFILE
                        whiptail --title "Duplicate Host" --fb --msgbox "There is already a $combine_newhost on this network.\n\nCurrently on the network:\n\n$host_check" 20 70
			advancedMenu1
                else
			sudo sed -i "s/$(hostname)/$combine_newhost/g" /etc/hostname | tee -a $LOGFILE
			sudo sed -i "s/$(hostname)/$combine_newhost/g" /etc/hosts | tee -a $LOGFILE
                        echo $(date): -- $combine_newhost -- >> 2>&1 $LOGFILE
			sudo rm /server_folders/watch_folder/$(hostname).pid
			echo "$(date): -- Changing hostname to $combine_newhost --" >> 2>&1 $LOGFILE
                        echo "$(date): -- Rebooting for changes to take affect in 5 seconds --" >> 2>&1 $LOGFILE
			for i in $(seq 1 100)
			do
				sleep .1
				echo $i
				done | whiptail --title "Valid Hostname" --gauge "\n$combine_newhost is not a duplicate hostname.\nSystem is rebooting for changes to take affect.\nShutting down system processes..." 10 60 0	
                        reboot
                fi		

 
		 
	
	;;
	5)
           	echo "$(date): -- Update Server IP --" >> 2>&1 $LOGFILE
		current_server_ip=$(cat /etc/hosts | grep 'ServerPi' | awk '{print $1}')
		new_server_ip=$(whiptail --title "Update Server IP" --fb --inputbox "\nThe ServerPi IP is currently: $current_server_ip\nWhat would you like to change it to?" 10 60 3>&1 1>&2 2>&3)
		if [ -z "$new_server_ip" ]
		then
      			echo "\$new_server_ip is empty"
		else
      			echo "\$var is NOT empty"
			sudo sed -i "s/$current_server_ip/$new_server_ip/g" /etc/hosts | tee -a 2>&1 $LOGFILE
		fi
		
		advancedMenu
        ;;

        6)
            	advancedMenu4
		advancedMenu
        ;;
	7)
		echo "$(date): -- System Info --" >> 2>&1 $LOGFILE
		whiptail --title "System Information" --msgbox "$(
		echo "System name: $(hostname)"
		echo "pibroadcast Software Version: $pibroadcast_version"
		echo "System IP: eth0: $(ifconfig | grep -A 1 'eth0' | grep -A 1 'inet' | awk ' { FS = " "; print $2}') / wlan0: $(ifconfig | grep -A 1 'wlan0' | grep -A 1 'inet' | awk ' { FS = " "; print $2}')"
		echo --
		echo "System temp: $(awk '{printf("%.1f°F\n",(($1*1.8)/1e3)+32)}' /sys/class/thermal/thermal_zone0/temp)"
		echo "PI Broadcast Settings:"
		grep feh .pibroadcast_settings | awk '{print "  Slide delay: " $2 " seconds"}'
		
		if [ "$(grep server_sync .pibroadcast_settings | awk '{print  $2 }')" == "true" ]; then echo "  - Server Sync: Enabled"
		else 
		echo "  - Server Sync: Disabled" 
		fi

		if [ "$(grep sync_scripts .pibroadcast_settings | awk '{print  $2 }')" == "true" ]; then echo "  - Server Sync Scripts: Enabled"
		else 
		echo "  - Server Sync Scripts: Disabled" 
		fi

		if [ "$(grep sync_slides .pibroadcast_settings | awk '{print  $2 }')" == "true" ]; then echo "  - Server Sync Slides: Enabled"
		else 
		echo "  - Server Sync Slides: Disabled" 
		fi

		if [ "$(grep broadcast_watch .pibroadcast_settings | awk '{print  $2 }')" == "true" ]; then echo "  - Auto-broadcast Detect: Enabled"
		else 
		echo "  - Auto-broadcast Detect: Disabled" 
		fi

		if [ "$(grep client_pid_create .pibroadcast_settings | awk '{print  $2 }')" == "true" ]; then echo "  - Server Pid Creation: Enabled"
		else 
		echo "  - Server Pid Creation: Disabled" 
		fi
		##
		echo
		echo "Server Folders:"
		if grep -qs '/server_folders/slides' /proc/mounts; then
    			echo "  - Slides: mounted"
		else
    			echo "  - Slides: not mounted"
		fi
		if grep -qs '/server_folders/scripts' /proc/mounts; then
    			echo "  - Scripts: mounted"
		else
    			echo "  - Scripts: not mounted"
		fi
		if grep -qs '/server_folders/watch_folder' /proc/mounts; then
    			echo "  - Watch Folder: mounted"
		else
    			echo "  - Watch Folder: not mounted"
		fi
		##
		)" 28 57
		advancedMenu
	;;
	
    esac
}


function advancedMenu1() {

		OPTION=$(whiptail --title "Change Hostname" --fb --menu "\nCurrent Machine Name: $(hostname)\n\nChoose your option" 20 50 5 \
			"1" "EntrancePi" \
			"2" "MissionsPi" \
			"3" "ChildrensPi" \
			"4" "WestPi" \
			"5" "EastPi" 3>&1 1>&2 2>&3) 
		
		exitstatus=$?							## Check for Cancel Button ##
			if [ $exitstatus = 0 ]; then
    				echo "Your chosen option:" $OPTION >> /dev/null		## For testing ##
				echo $exitstatus >> /dev/null
			else
    				echo "You chose Cancel." >> /dev/null			## For testing ##
				advancedMenu
			fi
		
		case $OPTION in

			1)
				newhostname="EntrancePi"
				;;
			2)
				newhostname="MissionsPi"
				;;
			3)
				newhostname="ChildrensPi"
				;;
			4)
				newhostname="WestPi"
				;;
			5) 
				newhostname="EastPi"	
				;;
			esac


			
		}

function advancedMenu2() {

		OPTION=$(whiptail --title "Client Broadcast Settings" --fb --menu "\nChoose your option" 20 50 3 \
			"1" "Temporary Disable" \
			"2" "Permanent Disable" \
			"3" "Enable Broadcast" 3>&1 1>&2 2>&3) 
		
		exitstatus=$?							## Check for Cancel Button ##
			if [ $exitstatus = 0 ]; then
    				echo "Your chosen option:" $OPTION >> /dev/null		## For testing ##
				echo $exitstatus >> /dev/null
			else
    				echo "You chose Cancel." >> /dev/null			## For testing ##
				advancedMenu
			fi
		
		case $OPTION in

			1)	echo "$(date): -- Client Broadcast Settings -- Temporary Disable --" >> 2>&1 $LOGFILE
				if (whiptail --title "Temporary Disable" --yesno "This will temporarily disable auto-broadcast.\nThis will re-enable after a reboot.\nDo you wish to continue?" 8 78)
    				then
      		  			echo "Yes"
					if pgrep -x "client_broadcast_watch" > /dev/null
                                                then
                                                sudo kill $(pgrep -x "client_broadcast_watch")
						sudo kill $(pgrep -x "omxplayer")
                                     
                                        fi

					
    				else
        				echo "No"
					
				fi
			;;

			2)	echo "$(date): -- Client Broadcast Settings -- Permanent Disable --" >> 2>&1 $LOGFILE
				if (whiptail --title "Permanent Disable" --yesno "This will permanently disable auto-broadcast.\nDo you wish to continue?" 8 78)
    				then
      		  			echo "Yes"
					sudo sed -i 's|broadcast_watch true|broadcast_watch false|g' /home/pi/.pibroadcast_settings
					if pgrep -x "client_broadcast_watch" > /dev/null
                                                then
                                                sudo kill $(pgrep -x "client_broadcast_watch")
						sudo kill $(pgrep -x "omxplayer")
                                     
                                        fi
                                        
					
    				else
        				echo "No"
					
				fi
			;;

			3)	echo "$(date): -- Client Broadcast Settings -- Enable Broadcast --" >> 2>&1 $LOGFILE
				if (whiptail --title "Enable Broadcast" --yesno "Re-enable auto-broadcast?" 8 78)
    				then
      		  			echo "Yes"
					sudo sed -i 's|broadcast_watch false|broadcast_watch true|g' /home/pi/.pibroadcast_settings

					
					whiptail --title "Information" --msgbox "You will have to restart the broadcast on the ServerPi for this to work correctly." 8 78
								
    				else
        				echo "No"
					
				fi
			;;
			

			esac
			
		}

function advancedMenu3() {

		OPTION=$(whiptail --title "Client Sync Settings" --fb --menu "\nChoose your option" 20 50 3 \
			"1" "Temporary Disable Auto-sync" \
			"2" "Permanent Disable Auto-sync" \
			"3" "Enable Client Auto-sync" 3>&1 1>&2 2>&3) 
		
		exitstatus=$?							## Check for Cancel Button ##
			if [ $exitstatus = 0 ]; then
    				echo "Your chosen option:" $OPTION >> /dev/null		## For testing ##
				echo $exitstatus >> /dev/null
			else
    				echo "You chose Cancel." >> /dev/null			## For testing ##
				advancedMenu
			fi
		
		case $OPTION in

			1)	echo "$(date): -- Client Sync Settings -- Temporary Disable --" >> 2>&1 $LOGFILE
				if (whiptail --title "Temporary Disable Sync" --yesno "This will temporarily disable auto-sync.\nThis will re-enable after a reboot.\nDo you wish to continue?" 8 78)
    				then
      		  			echo "Yes"
					if pgrep -x "client_sync" > /dev/null
                                                then
						echo $(date): -- $(pgrep -x "client_sync") is running -- >> 2>&1 $LOGFILE
						echo $(date): -- $(pgrep -x "client_pid_create") is running -- >> 2>&1 $LOGFILE
						echo "$(date): -- Shutting down client_sync and client_pid_create --" >> 2>&1 $LOGFILE
                                                sudo kill $(pgrep -x "client_sync")
						sudo kill $(pgrep -x "client_pid_create")
						sudo rm /server_folders/watch_folder/$(hostname).pid
                                     
                                        fi

					
    				else
        				echo "No" > /dev/null
					
				fi
			;;

			2)	echo "$(date): -- Client Sync Settings -- Permanent Disable --" >> 2>&1 $LOGFILE
				if (whiptail --title "Permanent Disable Sync" --yesno "This will permanently disable auto-sync.\nDo you wish to continue?" 8 78)
    				then
      		  			echo "Yes"
					sudo sed -i 's|server_sync true|server_sync false|g' /home/pi/.pibroadcast_settings
					sudo sed -i 's|sync_scripts true|sync_scripts false|g' /home/pi/.pibroadcast_settings
					sudo sed -i 's|sync_slides true|sync_slides false|g' /home/pi/.pibroadcast_settings
					sudo sed -i 's|client_pid_create true|client_pid_create false|g' /home/pi/.pibroadcast_settings
					if pgrep -x "client_sync" > /dev/null
                                                then
                                                echo $(date): -- $(pgrep -x "client_sync") is running -- >> 2>&1 $LOGFILE
						echo $(date): -- Shutting down client_sync -- >> 2>&1 $LOGFILE
						sudo kill $(pgrep -x "client_sync")
						sudo rm /server_folders/watch_folder/$(hostname).pid
                                     
                                        fi
                                        
					
    				else
        				echo "No" > /dev/null
					
				fi
			;;

			3)	echo "$(date): -- Client Sync Settings -- Enable Broadcast --" >> 2>&1 $LOGFILE
				if (whiptail --title "Enable Client Auto-sync" --yesno "Re-enable auto-sync?" 8 78)
    				then
      		  			echo "Yes"
					echo "Enabling client_sync" >> 2>&1 $LOGFILE
					sudo sed -i 's|server_sync false|server_sync true|g' /home/pi/.pibroadcast_settings
					sudo sed -i 's|sync_scripts false|sync_scripts true|g' /home/pi/.pibroadcast_settings
					sudo sed -i 's|sync_slides false|sync_slides true|g' /home/pi/.pibroadcast_settings
					sudo sed -i 's|client_pid_create false|client_pid_create true|g' /home/pi/.pibroadcast_settings
					echo "$(date): -- Client script folder sync begin --" >> 2>&1 $LOGFILE
					rsync -avh --exclude=".*" $R_SC_DIR/ $L_SC_DIR/ >> 2>&1 $LOGFILE
					cp /home/pi/local_sync/scripts/client_menu.sh /home/pi/.bashrc 
					echo "$(date): -- scripts folder sync end --" >> 2>&1 $LOGFILE
					echo "$(date): -- Client slide folder sync begin --" >> 2>&1 $LOGFILE
					rsync -avh --exclude=".*" $R_S_DIR/ $L_S_DIR/ --delete  >> 2>&1 $LOGFILE 
					echo "$(date): -- slides folder sync end --" >> 2>&1 $LOGFILE
				
					whiptail --title "Information" --msgbox "System will now reboot for these settings to take effect." 8 78
					reboot			
    				else
        				echo "No" > /dev/null
					
				fi
			;;
			

			esac
			
		}

function advancedMenu4() {

		OPTION=$(whiptail --title "Client Settings Menu" --fb --menu "\nCurrent Machine Name: $(hostname)\n\nChoose your option" 20 50 5 \
			"1" "Enable/Disable Bluetooth" \
			"2" "Update System OS" \
			"3" "Raspberry Pi System Config" \
			"4" "Reboot Client" \
			"5" "Power off System" 3>&1 1>&2 2>&3) 
		
		exitstatus=$?							## Check for Cancel Button ##
			if [ $exitstatus = 0 ]; then
    				echo "Your chosen option:" $OPTION >> /dev/null		## For testing ##
				echo $exitstatus >> /dev/null
			else
    				echo "You chose Cancel." >> /dev/null			## For testing ##
				advancedMenu
			fi
		
		case $OPTION in

			1)	echo "$(date): -- Client Settings -- Bluetooth --" >> 2>&1 $LOGFILE
				if (whiptail --title "Bluetooth Settings" --yesno --yes-button Enable --no-button Disable "Enable/Disable Bluetooth?" 8 78)
    				then
      		  			echo "$(date): -- Enable Bluetooth Selected --" >> 2>&1 $LOGFILE
					sudo sed -i 's|dtoverlay=pi3-disable-bt|#dtoverlay=pi3-disable-bt|g' /boot/config.txt
					systemctl enable hciuart.service
					systemctl enable bluealsa.service
					systemctl enable bluetooth.service				
					whiptail --title "Information" --msgbox "System will now reboot for these settings to take effect." 8 78
					reboot			
    				else
        				echo "$(date): -- Disable Bluetooth Selected --" >> 2>&1 $LOGFILE
					sudo sed -i 's|#dtoverlay=pi3-disable-bt|dtoverlay=pi3-disable-bt|g' /boot/config.txt
					systemctl disable hciuart.service
					systemctl disable bluealsa.service
					systemctl disable bluetooth.service				
					whiptail --title "Information" --msgbox "System will now reboot for these settings to take effect." 8 78
					reboot			

					
				fi

				;;
			2)
				echo "$(date): -- Update System OS --" >> 2>&1 $LOGFILE
				if (whiptail --title "Update System OS" --fb --yesno "\n** WARNING: This may have unforeseen affects on the broadcast or client sync ability.  **\nThis will reboot the system after it has completed.  Do you still wish to proceed?" 12 93)
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

					echo "Reboot Client"
					if (whiptail --title "System Reboot" --fb --yesno "Reboot machine?" 8 78)
    					then
						sudo reboot
    					else
						echo /dev/null
    					fi

	    			else
       					echo /dev/null 
    				fi
				advancedMenu

				;;
			3)	
				echo "$(date): -- System Config --" >> 2>&1 $LOGFILE
				sudo raspi-config | tee -a $LOGFILE
				advancedMenu

				;;
			4)
				echo "$(date): -- Reboot Client --" >> 2>&1 $LOGFILE
				if (whiptail --title "System Reboot" --fb --yesno "Reboot machine?" 10 78)
    				then
					sudo reboot
    				else
					echo /dev/null
    				fi
				advancedMenu

				;;
			5) 
				echo "$(date): -- Power off System --" >> 2>&1 $LOGFILE

				if (whiptail --title "Power off System" --yesno "Do you wish to power off $(hostname)?" 8 78)
    				then
					for i in $(seq 1 100)
					do
    						sleep .1 
    						echo $i
					done | whiptail --title 'Power off System' --gauge 'Shutting down system processes...' 6 60 0
					sudo poweroff
    				else
        				advancedMenu 
    				fi
	
				;;
			esac


			
		}

advancedMenu


exit
