Traffic Signal on Raspberry Pi
==============================

Things You'll Need
------------------
- [Raspberry Pi Model B](http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=Raspberry+Pi+Model+B)
- [5V Micro USB Power Supply](http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=5V+Micro+USB+Power+Supply)
- [USB WiFi Adapter](http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=USB+WiFi+Adapter) (Optional)
- [Traffic Light](http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=Traffic+Light)
- [4GB+ SD Card](http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=4GB+SD+Card)
- [Relay Board](http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=Relay+Board) ([The one I used](http://www.amazon.com/gp/product/B0057OC5O8/ref=oh_aui_detailpage_o00_s00?ie=UTF8&psc=1))
- For setup you'll need an [HDMI Cable](http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=HDMI+Cable) (or [RCA Cable](http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=RCA+Cable)) and a [USB Keyboard](http://www.amazon.com/s?url=search-alias%3Daps&field-keywords=USB+Keyboard).

Setting up the Raspberry Pi
---------------------------

Download the [Arch Linux disk image for the Raspberry Pi](http://archlinuxarm.org/platforms/armv6/raspberry-pi) and extract the contents.
```sh
$ wget http://downloads.raspberrypi.org/arch_latest --output-document alarmpi.zip
$ unzip alarmpi.zip
```

Using `dd`, copy the image onto your SD card. Replace `/dev/sdX` with your SD card's device. **Warning:** Be careful that `of=` points to your SD card device. If you chose the wrong option, it may overwrite your hard disk, causing severe data loss.
```sh
$ dd bs=1M if=archlinux-hf-2013-07-22.img of=/dev/sdX
```

Now you should be able to insert the SD card and connect your Raspberry Pi to power. By default, the root password is `root`. If you ran into problems, refer to one of the many guides online and be sure to check out [the official guide](http://archlinuxarm.org/platforms/armv6/raspberry-pi).

If you want to set up WiFi, grab yourself a USB Wifi dongle and enter the WiFi menu.
```sh
$ wifi-menu -o
```

In order to get the Wifi connection to activate automaticlly on boot, you'll need to use something like the following:
```sh
$ pacman -Syu wpa_actiond
$ ls /etc/netctl/ 
$ netctl enable PROFILE_IN_ETC_NETCTL
```

Since the image file may be out of date, you may as well run some updates.
```sh
$ pacman -Syyu
```

You may want to change the root password. I chose not to add another user since you need root access to change the *GPIO* state.
```sh
$ passwd
```

Wiring the Raspberry Pi to the Relay Board
------------------------------------------

![test](http://developer-blog.net/wp-content/uploads/2013/09/raspberry-pi-rev2-gpio-pinout.jpg)

- **+5V** *(pin 2)* from the Raspberry Pi goes to the **VCC** of the relay board.
- **Ground** *(pin 6)* from the Raspberry Pi goes to the **Ground** of the relay board.
- **GPIO 14** *(pin 8)* from the Raspberry Pi goes to the **IN1** of the relay board.
- **GPIO 15** *(pin 10)* from the Raspberry Pi goes to the **IN2** of the relay board.
- **GPIO 18** *(pin 12)* from the Raspberry Pi goes to the **IN3** of the relay board.

Setting up the Traffic Signal Interface
---------------------------------------

The scripts I wrote use a Python library called `RPi.GPIO`. You can use [pip](http://www.pip-installer.org/) or the [Arch AUR](https://aur.archlinux.org/). Below are the instructions to install it using the AUR.
```sh
$ pacman -Syu file base-devel abs git
$ wget https://aur.archlinux.org/packages/py/python-raspberry-gpio/python-raspberry-gpio.tar.gz
$ tar xzvf python-raspberry-gpio.tar.gz
$ cd python-raspberry-gpio/
$ makepkg -scif --asroot
$ pacman -U python-raspberry-gpio*.tar.xz
```

Next, you'll need to clone this repository onto your Raspberry Pi and copy the control script into `/usr/bin`.
```sh
$ git clone https://github.com/mide/traffic-light-controller.git
$ chmod +x traffic-light-controller/light-control.py
$ cp traffic-light-controller/light-control.py /usr/bin/light-control
```

You can now test the light controller by running the following commands.
```sh
$ light-control red on
$ light-control green on -v
$ light-control red off -v
$ light-control yellow on
$ # You can keep going, but that verifies the light-control script works.
```

Setting up the Uptime Watcher
-----------------------------

Now it's time to set up the uptime watcher module. **This logic is application specific**, so this is the part you'll need to change to match your setup. I've documented what I did to get you on the right direction. *The default file that comes with this project just randomly changes the lights.*
```sh
$ pacman -Syu python-lxml
$ git clone https://github.com/mide/traffic-light-controller.git
$ chmod +x traffic-light-controller/uptime-watcher.py
$ cp traffic-light-controller/uptime-watcher.py /usr/bin/uptime-watcher
```

In order to make the state change automatically, you'll want to edit your crontab. You can do so by running `crontab -e`. The following will run `uptime-watcher` once a minute.

    * * * * * uptime-watcher

You may need to install and enable cron, depending on your setup.
```sh
$ pacman -Syu cronie
$ systemctl enable cronie
$ systemctl start cronie
```

Usage and License
-----------------

This project is licensed under [the MIT License](LICENSE.txt), so feel free to use it for your company or home network. The only thing that will need to be changed is the `uptime-watcher.py`, since that has the display calculation logic.

Made with :heart: for [Veracross](http://github.com/veracross) by [Mark Ide](http://github.com/mide). Made public with the [the MIT License](LICENSE.txt).
