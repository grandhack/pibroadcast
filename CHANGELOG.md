# CHANGELOG
## Version 1.3.1 - 31 January 2019
* Update all Scripts
	- Replaced $LOGFILE 2>&1 to 2>&1 $LOGFILE to send all errors to the log file as well.

## Version 1.3 - 16 September 2018
* Updated fresh_install.sh
	- Added new password for pi user
	- Added OS architecture detection for x86 or arm.  Allowing future use on older PC's and Virtual Environment
		*- Created two different software package install/remove lists to reflect which chip environment it is installed on
	- Added West/East Pi code
	- Added settings file for server
		*- Added log upload selection for Dropbox
	- Updated settings file for client
		*- Removed duplicate log upload selection for Dropbox




## Version 1.2.4.1 - 22 August 2018
* Updated server_menu.sh
	- Added System Uptime to System Info
	- Added Pi Broadcast Software version info under System Info
* Updated .pibroadcast_settings to include PI Broadcast Software Version
	- Added to all clients
	- Added file to server

## Version 1.2.4 - 21 August 2018
* Updated server_menu.sh
	- Modified Dropbox client sync area 
		-- added:
			*- touch /smb_shares/watch_folder/syncd_clients/"$i.pid.sync_not_complete"
			*- echo "$(date): -- Created $i.pid.sync_not_complete file --" | tee -a $LOGFILE 2>&1
			*- chmod 755 /smb_shares/watch_folder/syncd_clients/"$i.pid.sync_not_complete"
			
		-- removed:
			*- touch /smb_shares/watch_folder/syncd_clients/$(host $i | tail -n 1 | sed -e "s/^.* //;s/[[:punct:]]*$//" | awk -F "." '/1/ {print $1}').pid.sync_not_complete
			*- echo "$(date): -- Created $(host $i | tail -n 1 | sed -e "s/^.* //;s/[[:punct:]]*$//" | awk -F "." '/1/ {print $1}').pid.sync_not_complete file --" | tee -a $LOGFILE 2>&1
			*- chmod 755 /smb_shares/watch_folder/syncd_clients/$(host $i | tail -n 1 | sed -e "s/^.* //;s/[[:punct:]]*$//" | awk -F "." '/1/ {print $1}').pid.sync_not_complete
			
	- Created secondary variable: connected_host_ip1=$(ls /smb_shares/watch_folder/*.pid | gawk -F/ '{print $4}' | gawk -F. '{print $1}')
	- Modified advancedClientMenu area
		-- added:
			*- touch "/smb_shares/watch_folder/syncd_clients/$i.pid.sync_not_complete"
			*- echo "$(date): -- Created $i.pid.sync_not_complete file --" | tee -a $LOGFILE 2>&1
			*- chmod 755 "/smb_shares/watch_folder/syncd_clients/$i.pid.sync_not_complete"
		-- removed:
			*- #touch /smb_shares/watch_folder/syncd_clients/$(host $i | tail -n 1 | sed -e "s/^.* //;s/[[:punct:]]*$//" | awk -F "." '/1/ {print $1}').pid.sync_not_complete
			*- #echo "$(date): -- Created $(host $i | tail -n 1 | sed -e "s/^.* //;s/[[:punct:]]*$//" | awk -F "." '/1/ {print $1}').pid.sync_not_complete file --" | tee -a $LOGFILE 2>&1
			*- #chmod 755 /smb_shares/watch_folder/syncd_clients/$(host $i | tail -n 1 | sed -e "s/^.* //;s/[[:punct:]]*$//" | awk -F "." '/1/ {print $1}').pid.sync_not_complete
	- Removed Alpha Code Section and created new fork of testing code
			
* Updated client_services.sh
	- Created a new .pid.lock file to fix log overflow bug
		-- Check for .pid.lock file function
		-- Check for .pid.lock file exsits / Prevents continual log entry every second which updated .pid file for Server
			*- If it doesn't exsist, it is created.
			
## Version 1.2.3 - 1 August 2018
* Updated server_menu.sh
	- Modified menu options to remove --fb option for menu artifacts
* Updated client_menu.sh
	- Modified menu options to remove --fb option for menu artifacts

## Version 1.2.2 - 25 July 2018
* Changes to fresh_install.sh
	- Added a Fresh/Reinstall Test in the beginning of the file


## Version 1.2.1 - July 17 2018
* Changes to fresh_install.sh
	- Added echo '192.168.1.247		ServerPi' >> /etc/hosts | tee -a $LOGFILE  on the client_install area.  The clients were not connecting to the server after the install due to an error in the /etc/hosts file

## Version 1.2 - 2 June 2018
* Changes to fresh_install.sh
	- Reorganized dropbox area
	- Disabled Bluetooth after reboot
	- Updated .pibroadcast_settings defaults to include live_broadcast & client_monitor
	- Cleaned/Removed unused code from bottom of fresh_install.sh to Unused Code file
* Updated client_menu.sh with new items and fixed to work with client_services.sh
	- Created new Client Setting menu
* Combined all client daemons into one service client_services.sh:
	- client_broadcast_watch.sh
	- client_pid_create.sh (removed - moved process check to server)
	- client_reboot.sh
	- client_slideshow_start.sh
	- client_sync.sh
* Updated/Combined server menu/daemons into one file server_menu.sh:
	- dropbox_sync.sh
	- added server info item
	- added a test if broadcast_begin is already created
	

## Version 1.1 - 25 May 2018
* Added longer network connection test to server before client boots fully.  Client will show default slide until connection to the server is done on eth0 (cat5) or wlan0 (wifi) in boot.sh
* Created/Added .pibroadcast_settings in /home/pi for keeping settings on reboot in fresh_install.sh
	- Settings Added: (default settings)
	  -- feh 10 (slide show pause)
	  -- server_sync true
	  -- sync_scripts true
	  -- sync_slides true
	  -- broadcast_watch true 
	  -- client_pid_create true

* Reorganized boot.sh to read from .pibroadcast_settings and use stored settings
* Added .pibroadcast_settings file detect/creation in boot.sh with default values
* Updated process kill statement for feh test in boot.sh
* Created update folder in /home/pi on server for piadmin.  This will also add to server menu.  Allowing for PI Broadcast software updates.  Added this folder creation to fresh_install.sh
* Created 3 new client menu items: Client Broadcast Settings, Client Sync Settings, System Info
	- Client Broadcast Settings - submenu items: Temp Disable Auto-broadcast, Perm Disable Auto-broadcast, Enable Auto-broadcast
	- Client Sync Settings - submenu items: Temp Disable Auto-sync, Perm Disable Auto-sync, Enable Auto-sync
	- System Info - System Name, Host IP, CPU Temp, Server folders mounted status, pibroadcast settings


## Version 1.0.1 - 24 May 2018
* Add Disable Broadcast Menu - client_menu.sh
* Corrected process kill statement in client_sync.sh

## Version 1.0 - 3 May 2018
* Initial release
