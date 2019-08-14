
# Pi Broadcast 

Pi Broadcast was built to utilize Raspberry Pi’s to play a continual slide show and automatically detect when a live broadcast has begun and switch the video feed from slide show to video feed.

This has been written to work on the [x86](https://www.raspberrypi.org/downloads/raspberry-pi-desktop/) and [ARM](https://www.raspberrypi.org/downloads/raspbian/) architecture of Raspbian.

Pi Broadcast was written in ***BASH***

The clients will play the video at the same time based on the UDP protocol.  You can run an unlimited amount of clients.  Any number of clients that can detect/play a UDP broadcast can be used.  It was tested with VLC on (IOS/MacOS/Windows 10/Android).

The omxplayer (at the time) was the only player specifically designed to take advantage of the pi’s decoder chipset.  It was tested on Pi 3 / 3B+ / Pi Zero W.

The slide show (utilizing feh) is built upon standard graphic images (JPEG/PNG/TIFF/GIF).  The images are downloaded from the server upon boot.  The pictures can be pushed from the server manually, or from the client manually.  The slideshows can be individualized to each client based on name (EntrancePi1/2/3 will play a different slide show then EastPi1 and WestPi2). 

Server and Clients are driven by Whiptail menus.  To begin, open a terminal window and the menu should automatically run.  If it does not, or you are running a headless server run:
```
sudo /home/pi/server_menu.sh
```

On a client:
```
sudo /home/pi/client_menu.sh
```



![Image description](https://github.com/grandhack/pibroadcast/blob/master/PIBroadcast.png)



# Links:
NGINX Webserver - http://www.nginx.org

Raspberry PI ASCII Webpage - https://gist.github.com/spfaffly/d774f87b8cf9a1837d05

Dropbox-Uploader - https://github.com/andreafabrizi/Dropbox-Uploader

Webmin - http://www.webmin.com (This is installed purely for ease of administration of samba on the server)

## Getting started
1. Download/Install Raspbian
2. Clone/Download zip pibroadcast from Github
3.  Place pibroadcast in the /boot folder on the fresh install of Raspbian
    - Customize wpa_supplicant.conf as applicable if using WiFi
    - Customize fresh_install.sh with:
      * Dropbox Token and folder architechure
      * Passwords for pi & piadmin users
4. Boot up Raspbian
5. Make sure system has access to the internet
6. Open a terminal window once system is booted and type:
```
sudo /boot/fresh_install.sh
```
7.  Answer the remaining questions
    - Server or Client
    - Client Name
This will install the system and customize the installed software.  This will also create a piadmin account and set the passwords for this account as well as pi.
8.  Once server is installed:
    - Verify connection test a video broadcast sent to server by using a client and direct to rtmp://serverpi/live/test
    - Verify Dropbox system connection has downloaded folder/file architecture you asigned in Step 3b.
    - Verify Samba is running by logging into Webmin: https://serverpi:10000 (This can also be checked from the cli)
9.  Once client is installed:
    - Verify connection to server is up and begin broadcast on server (thru Server Menu)
    - Verify client has synced dropbox folders/pictures from server
    
## Future Growth
Development needed:
 - Integrate with:
   * Google Drive
   * Box.net
   * Remote server
 - Other forms of media streaming to server from external sources
