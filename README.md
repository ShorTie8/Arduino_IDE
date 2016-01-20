## Arduino_IDE_builder.bash

Living in the land of ARM I found a need to write this

Although it was written for ARM primarily, I do believe it will work on any Linux box.
And with a little help Mac && Windows too...

What it does is use github to get all the various programs.
Compiles them and builds the IDE in 1 simple script .. :)~

Normally, Update_git is the only 1 needed to be un-rem'd
The rest are mainly for if your playing with the sources, and my debug, lol.

### Usage
```
sudo ./Arduino_IDE_builder.bash
```

### To run after building is done
```
sudo Arduino/build/linux/work/./arduino
```

### To install
```
sudo Arduino/build/linux/work/./install.sh
```

I've tested it on a Raspberry Pi2, Odroid C1 and Debian 8.20 i386, and all seems well after dependency are meet.

```
apt-get install -y mercurial subversion build-essential gperf bison ant texinfo zip automake flex libusb-dev libusb-1.0-0-dev libtinfo-dev pkg-config libwxbase3.0-dev libtool
```

The latest Raspbian already has Java 8, so no problems there.
If it is not already installed, like on the Odroid and Debian i386, I did it as follows

```
sudo sh -c 'echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list'
sudo sh -c 'echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list'
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
sudo apt-get update
sudo apt-get install oracle-java8-installer
 ```


Not all options are fully implemented yet,
 But Silence_is_Golden is enabled as it sed's through toolchain-avr on the initial git clone to silence it and make things easier to follow.
  So to do/un-do it, just 'rm -rf Arduino/build/toolchain-avr' and re-run the script.
You can save some download time by coping all the files for toolchain-avr downloads over as git clone is working if you have them.


Ya'll Have A Great Day

ShorTie






### Old

A Debian .deb builder for ARM Boards

From the within the Arduino directory

```
ln -s Arduino_IDE/debian debian
dpkg-buildpackage -uc -b -tc
```
