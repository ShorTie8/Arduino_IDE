# Arduino_IDE_builder.bash

This repository contains a script for building the Arduino IDE and toolchain from source on Linux.  Although it was written for ARM platforms primarily, such as the Raspberry Pi or ODroid, I do believe it will work on any Linux box (and possibly with a little help Mac and Windows too). The script has been tested on Raspberry Pi 2, Odroid C1 and Debian 8.20 i386, and all seems well.

It works by retrieving the souces for the various projects from GitHub and building everything locally.

## Instructions

1. Install prerequisites:
   ```
   apt-get install -y mercurial subversion build-essential gperf bison ant texinfo zip automake flex libusb-dev libusb-1.0-0-dev libtinfo-dev pkg-config libwxbase3.0-dev libtool
   ```
   
   Java is also required, and is included with Raspian on the Raspberry Pi. For ODroid and other platforms without
   Java, you will need to install it:
   ```
   sudo sh -c 'echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list'
   sudo sh -c 'echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list'
   sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
   sudo apt-get update
   sudo apt-get install oracle-java8-installer
   ```

1. Clone this repository:
   ```
   git clone https://github.com/ShorTie8/Arduino_IDE.git
   ```

1. Execute the build script. (This can take many hours):
   ```
   cd Arduino_IDE
   sudo ./Arduino_IDE_builder.bash
   ```
   
1. Either run directly with:
   ```
   sudo Arduino/build/linux/work/./arduino
   ```

1. Or install as a local user with (installing as root doesn't work):
   ```
   Arduino/build/linux/work/./install.sh
   ```

## Notes

* Not all options are fully implemented yet, but `Silence_is_Golden` is enabled as it `sed`'s through `toolchain-avr` on the initial git clone to silence it and make things easier to follow; to do/undo it, just `rm -rf Arduino/build/toolchain-avr` and re-run the script.

* You can save some download time by coping all the files for `toolchain-avr` downloads over as git clone is working if you have them.

## Old

A Debian .deb builder for ARM Boards

From the within the Arduino directory

```
ln -s Arduino_IDE/debian debian
dpkg-buildpackage -uc -b -tc
```
