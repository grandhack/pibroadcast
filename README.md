
# Pi Broadcast 

Pi Broadcast was built to utilize Raspberry Pi’s to play a continual slide show and automatically detect when a live broadcast has begun and switch the video feed from slide show to video feed.

Pi Broadcast was written in ***BASH***

The clients will play the video at the same time based on the UDP protocol.  You can run an unlimited amount of clients.  Any number of clients that can detect/play a UDP broadcast can be used.  It was tested with VLC on (IOS/MacOS/Windows 10/Android).

The omxplayer (at the time) was the only player specifically designed to take advantage of the pi’s decoder chipset.  It was tested on Pi 3 / 3B+ / Pi Zero W.

The slide show (utilizing feh) is built upon standard graphic images (JPEG/PNG/TIFF/GIF).  The images are downloaded from the server upon boot.  The pictures can be pushed from the server manually, or from the client manually.  The slideshows can be individualized to each client based on name (EntrancePi1/2/3 will play a different slide show then EastPi1 and WestPi2). 

![Image description]https://github.com/grandhack/pibroadcast/blob/master/PIBroadcast.png

# Links:
NGINX Webserver - http://www.nginx.org
Raspberry PI ASCII Webpage - https://gist.github.com/spfaffly/d774f87b8cf9a1837d05
Dropbox-Uploader - https://github.com/andreafabrizi/Dropbox-Uploader
Webmin - http://www.webmin.com

## Getting started
(More to come)
 
