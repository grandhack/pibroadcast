#!/bin/bash

#==============================================================================
#title          :client_services.sh
#description    :This script is used to detect when the server sends commands
#		:to the client and execute updates
#author		:Justin Holt - githubjh@gmail.com
#date           :January 31 2019
#version        :1.2.1   
#usage		:
#notes          : 
#log file	:/var/log/pibroadcast-client-services.log
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

###################
## All Variables ##
###################

LOGFILE=/var/log/pibroadcast-client-services.log
host=$(hostname)
R_DIR="/server_folders/watch_folder"
L_DIR="/home/pi/local_sync/slides"
R_S_DIR="/server_folders/slides" 											
L_S_DIR="/home/pi/local_sync/slides"  											
R_SC_DIR="/server_folders/scripts"
L_SC_DIR="/home/pi/local_sync/scripts"
#ERRORLOG="/var/log/pibroadcast-error.log"
SYNC_UPDATE_TEMP="/home/pi/.sync_update"
SYNC_TIME="120"
CURTIME=$(date +%s)
SYNC_FILETIME=$(stat $SYNC_UPDATE_TEMP -c %Y)
TIMEDIFF=$(expr $CURTIME - $SYNC_FILETIME)
feh_delay=$(grep feh /home/pi/.pibroadcast_settings | awk '{print $2}')
server_sync_status=$(grep server_sync /home/pi/.pibroadcast_settings | awk '{print $2}')
script_sync_status=$(grep sync_scripts /home/pi/.pibroadcast_settings | awk '{print $2}')
slides_sync_status=$(grep sync_slides /home/pi/.pibroadcast_settings | awk '{print $2}')
broadcast_watch_status=$(grep broadcast_watch /home/pi/.pibroadcast_settings | awk '{print $2}')
client_pid_status=$(grep client_pid_create /home/pi/.pibroadcast_settings | awk '{print $2}')


####################
## Check for root ##
####################

if [ "$(id -u)" != "0" ]; then												## Start Check for sudo or root ##
	echo "Sorry, you do not have root privileges."
	exit 1
fi															## End Check for sudo or root ##

######################
## Log housekeeping ##
######################
sleep 5
echo "$(date): -- rotating log file --" >> 2>&1 $LOGFILE
savelog -n -c 7 $LOGFILE 
#rm $R_DIR/sync_update >> /dev/null
#rm $R_DIR/syncd_clients/$(hostname).pid.sync_not_complete > /dev/null
#rm $R_DIR/$host.pid >> /dev/null
#sudo rm $R_DIR/broadcast_end
rm "$R_DIR/syncd_clients/client_monitor.$host" > /dev/null
if [ -e "/home/pi/"."$(hostname).pid.lock" ]; then
        rm "/home/pi/"."$(hostname).pid.lock" >> 2>&1 $LOGFILE
fi

###########################################
## Network check for ServerPi connection ##
###########################################

echo "$(date): -- client_services.sh started --" >> 2>&1 $LOGFILE							## Begin Test when server is online ##
sudo -u pi DISPLAY=:0.0 feh -Y -x -D 10 -B black -F -Z -z -r $L_SC_DIR/Default_Screen.jpg &
printf "%s" "$(date) Waiting for ServerPi ..." >> 2>&1 $LOGFILE
while ! ping -c 1 -n -w 1 serverpi &> /dev/null
do
    	printf "%c" "." >> 2>&1 $LOGFILE
done
printf "\n%s\n"  "Server is online" >> 2>&1 $LOGFILE									## End Test when server is online ##

if pgrep -f "feh" > /dev/null												## Begin Check if feh is still running Default_Screen.jpg ##
then
    	echo "$(date): -- feh Running --" >> 2>&1 $LOGFILE
	echo "$(date): -- killing feh --" >> 2>&1 $LOGFILE
	sudo kill $(pgrep -x "feh") >> 2>&1 $LOGFILE
else
    	echo "$(date): -- feh Not running --" >> 2>&1 $LOGFILE	
fi															## End Check if feh is still running Default_Screen.jpg ##

##############################
## Mount all network drives ##
##############################

mount -av >> 2>&1 $LOGFILE
echo "$(date): -- mount -av complete --" >> 2>&1 $LOGFILE
sudo rm $R_DIR/client_reboot


##################################
## Check for .pibroadcast_settings file ##
##################################


if [ "$(ls -A /home/pi/.pibroadcast_settings)" ]; then										## Begin check for .pibroadcast_settings file ##
	echo "$(date): -- .pibroadcast_settings file detected --" >> 2>&1 $LOGFILE
	echo "$(date): -- feh time delay: $feh_delay --" >> 2>&1 $LOGFILE
	echo "$(date): -- Broadcast Watch Status: $broadcast_watch_status --" >> 2>&1 $LOGFILE
	echo "$(date): -- Sync Scripts/Slides: $script_sync_status / $slides_sync_status --" >> 2>&1 $LOGFILE
	echo "$(date): -- Client PID creation: $client_pid_status --" >> 2>&1 $LOGFILE

else
	echo "$(date): -- .pibroadcast_settings file not detected --" >> 2>&1 $LOGFILE
	printf 'feh 10\nserver_sync true\nsync_scripts true\nsync_slides true\nbroadcast_watch true\nclient_pid_create true\n' >> /home/pi/.pibroadcast_settings
fi															## End check for .pibroadcast_settings file ##

######################
## Sync with Server ##
######################

if [[ $server_sync_status == true ]]; then										## Begin check/sync for scripts/slides ##
	
	if [[ $script_sync_status == true ]]; then
		echo "$(date): -- Client script folder sync begin --" >> 2>&1 $LOGFILE
		rsync -avh --exclude=".*" $R_SC_DIR/ $L_SC_DIR/ >> 2>&1 $LOGFILE
		cp /home/pi/local_sync/scripts/client_menu.sh /home/pi/.bashrc 
		echo "$(date): -- scripts folder sync end --" >> 2>&1 $LOGFILE
	fi

	if [[ $slides_sync_status == true ]]; then
		echo "$(date): -- Client slide folder sync begin --" >> 2>&1 $LOGFILE
		rsync -avh --exclude=".*" $R_S_DIR/ $L_S_DIR/ --delete  >> 2>&1 $LOGFILE 
		echo "$(date): -- slides folder sync end --" >> 2>&1 $LOGFILE
	fi
fi															## End check/sync for scripts/slides ##

#################################
## Correcting File Permissions ##
#################################
chown pi:pi -R /home/pi


############################
## Determine Slide folder ##
############################

if [[ $host == Entrance* ]]; then slides_folder=Entrance; fi								## Begin Determine picture folder ##
	
if [[ $host == Missions* ]]; then slides_folder=Missions; fi
		
if [[ $host == Children* ]] ; then slides_folder=Children; fi

if [[ $host == West* ]] ; then slides_folder=West; fi

if [[ $host == East* ]] ; then slides_folder=East; fi								

echo "$(date): -- $host -- Slide Folder: $slides_folder --" >> 2>&1 $LOGFILE						## End Determine picture folder ##


########################
## Starting Slideshow ##
########################
while [ $(pgrep -f "lxpanel") -eq 0 ]; do
	echo "$(date): -- lxpanel is not running.  waiting to begin slideshow --" >> 2>&1 $LOGFILE
	sleep 1
done
	echo "$(date): -- lxpanel is running.  Beginning slideshow --" >> 2>&1 $LOGFILE
	sleep 10
	sudo -u pi DISPLAY=:0.0 feh -Y -x -D "$feh_delay" -B black -F -Z -z -r $L_DIR/$slides_folder >> 2>&1 $LOGFILE &	## Start Slideshow ##	
  




###############################
## Main loop to watch server ##
###############################
echo "$(date): -- Beginning main program --" >> 2>&1 $LOGFILE
while [ ! "$(mountpoint $R_DIR | grep not)" ]; do									## Main Loop ##

	if [ -e $R_DIR/sync_update ]; then										## Start of Sync_Update ##

		if [[ $server_sync_status == true ]]; then
		
	
			if [ "$TIMEDIFF" -gt "$SYNC_TIME" ]; then				
				echo -- "$(date): -- sync last updated --  > /home/pi/.sync_update"
				echo -- "$(date): -- sync_update file detected...beginning update" -- >> 2>&1 $LOGFILE
				echo "$(date): -- Server Sync Status: $server_sync_status" >> 2>&1 $LOGFILE
				rsync -avh --exclude=".*" /server_folders/slides/ /home/pi/local_sync/ --delete >> 2>&1 $LOGFILE
				rsync -avh --exclude=".*" /server_folders/scripts/ /home/pi/local_sync/ --delete >> 2>&1 $LOGFILE
				chown -R pi:pi /home/pi/local_sync 
				cp $L_SC_DIR/client_menu.sh /home/pi/.bashrc
				sudo chown pi:pi -R /home/pi
				rm "$R_DIR/syncd_clients/$(hostname).pid.sync_not_complete"
				echo "$(date): -- $(hostname).pid.sync_not_complete removed --" >> 2>&1 $LOGFILE
				echo "$(date): -- Restarting feh slideshow --" >> 2>&1 $LOGFILE
				sudo kill $(pgrep -x "feh") >> 2>&1 $LOGFILE
				sudo -u pi DISPLAY=:0.0 feh -Y -x -D "$feh_delay" -B black -F -Z -z -r $L_DIR/$slides_folder &
			else
				echo "$(date): -- /home/pi/.sync_update file exists.  This client has been updated within the last 2 minutes" >> 2>&1 $LOGFILE
				cat /home/pi/.sync_update >> 2>&1 $LOGFILE
				rm "$R_DIR/syncd_clients/$(hostname).pid.sync_not_complete"
			fi


		fi

	fi														## End of Sync_Update ##

	
	if [ "$(pgrep omxplayer | wc -l)" -eq 2 ]; then									## Start of Broadcast_End ##
    		if [ ! -f $R_DIR/broadcast_begin ]; then
			echo "$(date): -- broadcast_begin file not detected...killing omxplayer" >> 2>&1 $LOGFILE
                        sudo kill $(pgrep -f omxplayer)
                        sudo sed -i "s/live_broadcast on/live_broadcast off/g" /home/pi/.pibroadcast_settings | tee -a $LOGFILE

		fi
    		
  	fi														## End of Broadcast_End ##


	if [ -e $R_DIR/broadcast_begin ]; then										## Start of Broadcast_Begin ##
		if [[ $broadcast_watch_status == true ]]; then
		
	
			if pgrep -f omxplayer >/dev/null 2>&1; then
				echo "$(date): -- omxplayer is already running" > /dev/null				## Used for troubleshooting/do not remove ##
			else
				echo "$(date): -- broadcast_begin file created...starting omxplayer" >> 2>&1 $LOGFILE
				sudo sed -i "s/live_broadcast off/live_broadcast on/g" /home/pi/.pibroadcast_settings | tee -a $LOGFILE
				DISPLAY=:0.0 omxplayer -b rtmp://serverpi/live/test >> 2>&1 $LOGFILE &
				#DISPLAY=:0.0 omxplayer -b http://192.168.1.243:8090 >> 2>&1 $LOGFILE &			## Samples for changing broadcast type ##
				#DISPLAY=:0.0 omxplayer -b udp://239.255.42.42:5004 >> 2>&1 $LOGFILE &			## Samples for changing broadcast type ##
			fi
		fi
	fi														## End of Broadcast_Begin ##
		
	
	if [ -e $R_DIR/client_reboot ]; then										## Start of Client_Reboot ##
		echo "$(date): -- client_reboot file detected...rebooting --" >> 2>&1 $LOGFILE
		rsync -avh --exclude=".*" /server_folders/scripts /home/pi/local_sync/scripts/ --delete  >> 2>&1 $LOGFILE
		rm "$R_DIR/$host.pid"
		reboot
	fi														## End of Client_Reboot ##
	
	if [[ $client_pid_status == true ]]; then									## Start of Pid_Create ##
		if [ ! -f "/home/pi/"."$(hostname).pid.lock" ]; then
			if [ -e "$R_DIR/$host.pid" ]; then
				echo "$(date): -- $host.pid already created.  Updating file --" >> 2>&1 $LOGFILE
				echo "$(date): -- $(hostname) -- $(hostname -I) -- connected --" > "$R_DIR/$host.pid"			
				touch /home/pi/".""$(hostname).pid.lock" >> 2>&1 $LOGFILE 
				echo "$(date): -- Changing ownership of $(hostname).pid.lock file" >> 2>&1 $LOGFILE
				chown pi:pi /home/pi/".""$(hostname).pid.lock"
			else
				echo "$(date): -- $(hostname) -- $(hostname -I) -- connected --" > "$R_DIR/$host.pid"
				echo "$(date): -- $host.pid created" >> 2>&1 $LOGFILE
				echo "$(date): -- ."$(hostname)".pid.lock file created" >> 2>&1 $LOGFILE
				touch /home/pi/".""$(hostname).pid.lock" >> 2>&1 $LOGFILE
				echo "$(date): -- Changing ownership of "."$(hostname).pid.lock file" >> 2>&1 $LOGFILE
				chown pi:pi /home/pi/".""$(hostname).pid.lock"
			fi
		fi
	fi														## End of Pid_Create ##

	sleep 1
done

########################################
## Start Default_Screen if no network ##
########################################

echo "$(date): -- $R_DIR not mounted from ServerPi.  All client services disabled. Starting Default_Screen --" >> 2>&1 $LOGFILE
sudo -u pi DISPLAY=:0.0 feh -Y -x -D 10 -B black -F -Z -z -r $L_SC_DIR/Default_Screen.jpg &

exit
