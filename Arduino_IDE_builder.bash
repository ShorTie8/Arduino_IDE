#!/bin/bash -ex
# A simple script to build the Arduino IDE
# GNU General Public License invoked
# Debian dependacies
# apt-get update && apt-get upgrade -y
# apt-get install -y mercurial subversion build-essential gperf bison ant texinfo zip automake flex libusb-dev libusb-1.0-0-dev libtinfo-dev pkg-config
# apt-get install -y libwxbase3.0-dev libtool
# Beerware by ShorTie

# Options, rem out or set to sumfin else to not

# Normally, Update_git is the only 1 needed to be un-rem'd
# The rest are mainly for if your playing with the sources, and my debug, lol.
echo -e "\n\nConfiguration values\n\n"

#Update_git="yes"

#ReBuild_toolchain_avr="yes"
#ReBuild_avrdude="yes"
#ReBuild_arduino_builder="yes"
#ReBuild_Arduino="yes"
#ReBuild_astyle="yes"
#ReBuild_ctags="yes"

#Bossac="yes"
#Coan="yes"
#OpenOCD="yes"

# This is only used on the initial run to sed a few things, mainly in toolchain-avr, can not be re-done without a do over from beginnig
Silence_is_Golden="yes"

#Toolchain_avr_version="3.4.5"
#Toolchain_avr_version="3.5.0"

# Script,
# *****************************************************************
echo -e "\n\nSystem check\n\n"

# Check to see if Arduino_IDE_builder.bash is being run as root
start_time=$(date)
echo "Checking for root .. "
if [ `id -u` != 0 ]; then
    echo -e "\n\nOoops, So, So, Sorry, We play only as root !!\nAnd nop to sudo su either\nHave A Great Day\n\n"
    exit -1
else
    echo "Yuppers .. :)~"
fi

Java_Version=`java -version 2>&1 | sed 's/java version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q'`
echo $JAVA_HOME


# Sortta think this needs set in the IDE too...
# Do not assume env.JAVA_HOME is set right
# <property name="java_home" value="${env.JAVA_HOME}" />

# Check for what version of Java and set JAVA_HOME
if [[ $Java_Version != "18" ]]; then
    echo -e "\n\nOops, you need Java 1.8\n\n"
    exit -1
elif [ `uname -s` == "Linux" ]; then
    if [ `readlink -f /usr/bin/javac | sed "s:bin/javac::" | grep 8` ]; then
        JAVA_HOME=`readlink -f /usr/bin/javac | sed "s:bin/javac::"`
        export JAVA_HOME
    else
        echo -e "\n\nSo, So, Sorry, Could not set JAVA_HOME\n\n"
        exit -1
    fi
fi


# Checking for go
if [ `uname -s` == "Linux" ]; then
    if [[ ! -f /usr/local/go/bin/go ]]; then
        cd /usr/local
        wget https://storage.googleapis.com/golang/go1.4.3.src.tar.gz
        tar -xf go1.4.3.src.tar.gz
        rm go1.4.3.src.tar.gz
        cd go/src
        ./all.bash
        ../bin/./go version
        cd $Start_Directory
    else
        /usr/local/go/bin/./go version
    fi
else
    echo -e "\n\nSo So Sorry, don't know how to check for go"
fi

# Determine system type
if [ `uname -s` == "Linux" ]; then
    if [ `uname -m | grep arm` ]; then
        Sys="arm"
        SysTag="armhf"
    elif [ `getconf LONG_BIT` == "32" ]; then
        Bits="32"
        Sys="linux32"
        SysTag="i686"
    elif [ `getconf LONG_BIT` == "64" ]; then
        Bits="64"
        Sys="linux64"
        SysTag="x86_64"
    fi
    # Lets speed some compiles up
    if [[ `nproc` > "2" ]]; then
        JOBS=$((`nproc`+1))
        # Silence is Golden
        JOBS+=" -s"
    else
        JOBS="2 -s"
    fi
elif [ `uname -s` == "Darwin" ]; then
    Sys="macosx"
    echo "So So Sorry, not fully implemented yet"
    exit 0
elif [ `uname -s | grep CYGWIN` ]; then
    Sys="windows"
    echo "So So Sorry, not fully implemented yet"
    exit 0
elif [ `uname -s | grep MINGW` ]; then
    Sys="windows"
    echo "So So Sorry, not fully implemented yet"
    exit 0
fi
echo -e "\n\nBuilding Arduino_IDE for $Sys\n\n"

Start_Directory=`pwd`
Working_Directory=`pwd`/Arduino/build


if [[ ! -d Arduino ]]; then
    echo -e "\n\nRetriving Arduino_IDE for $Sys form github and remove some junk\n\n"
    if [[ $Sys != "arm" ]]; then
        git clone --depth 1 https://github.com/arduino/Arduino.git
    else
        git clone --depth 1 -b ARM https://github.com/NicoHood/Arduino.git
    fi
    rm -rfv Arduino/build/arduino-builde*
    rm -v Arduino/build/linux/avr-gcc*
    rm -v Arduino/build/linux/avrdude*
fi

if [[ $Update_git == "yes" ]]; then
    echo -e "\n\nChecking for Arduino_IDE github updates\n\n"
    cd Arduino
    # http://stackoverflow.com/questions/3258243/check-if-pull-needed-in-git
    if [[ ! `git status -uno | grep up-to-date` ]]; then
        git remote -v update
        cd build
        ant clean
    else
        cd build
    fi
else
    cd Arduino/build
fi


# toolchain-avr
if [[ ! -d toolchain-avr ]]; then
    echo -e "\n\nRetriving toolchain-avr form github\n\n"
    git clone  --depth 1 https://github.com/arduino/toolchain-avr.git
    # Silence is Golden
    if [[ "$Silence_is_Golden" == "yes" ]]; then
        sed -i 's/cp -v -f/cp -f/' toolchain-avr/*.bash
        sed -i 's/tar xfjv/tar xf/' toolchain-avr/*.bash
        sed -i 's/tar xfv/tar xf/' toolchain-avr/*.bash
        sed -i 's/tar -cjvf/tar -cjf/' toolchain-avr/*.bash
        sed -i 's/unzip/unzip -q/' toolchain-avr/*.bash
        sed -i 's/make install/make install -s/' toolchain-avr/*.bash
        sed -i 's/patch -/patch -s -/' toolchain-avr/*.bash
        #sed -i 's@/configure @/configure --silent @' toolchain-avr/*.bash
        sed -i 's@/configure @/configure --silent --with-pkgversion="Arduino" @' toolchain-avr/*.bash
    fi
fi

if [[ $Update_git == "yes" ]]; then
    echo -e "\n\nChecking for toolchain-avr github updates\n\n"
    cd toolchain-avr
    if [[ ! `git status -uno | grep up-to-date` ]]; then
        git remote -v update
        rm -v ../linux/avr-gcc*arduino* ../linux/avrdude*arduino*
    fi
    cd ..
fi

if [[ $ReBuild_toolchain_avr == "yes" ]]; then
    echo -e "\n\nDelete stuff to enable Rebuilding of toolchain-avr\n\n"
    if [[ `ls linux/avr-gcc*bz2*` ]]; then
        rm -v linux/avr-gcc*arduino*
    fi
fi

if [[ $ReBuild_avrdude == "yes" ]] || [[ $ReBuild_toolchain_avr == "yes" ]]; then
    echo -e "\n\nDelete stuff to enable Rebuilding of avrdude\n\n"
    if [[ `ls linux/avrdude*bz2*` ]]; then
        rm -v linux/avrdude*arduino*
    fi
fi

if [ ! `ls linux/avr-gcc*bz2` ]; then
    echo -e "\n\nBuilding toolchain-avr\n\n"
    cd toolchain-avr
    if [ `uname -s` == "Linux" ]; then
        if [ $Sys == "arm" ]; then
            MAKE_JOBS="$JOBS" ./arch.arm.build.bash
            shasum avr-gcc-4.8.1-arduino5-armhf-pc-linux-gnu.tar.bz2 | awk '{ print $1 }' > avr-gcc-4.8.1-arduino5-armhf-pc-linux-gnu.tar.bz2.sha
            shasum avrdude-6.0.1-arduino5-armhf-pc-linux-gnu.tar.bz2 | awk '{ print $1 }' > avrdude-6.0.1-arduino5-armhf-pc-linux-gnu.tar.bz2.sha
        elif [ $Sys == "linux32" ]; then
            MAKE_JOBS="$JOBS" ./arch.linux32.build.bash
            shasum avr-gcc-4.8.1-arduino5-i686-pc-linux-gnu.tar.bz2 | awk '{ print $1 }' > avr-gcc-4.8.1-arduino5-i686-pc-linux-gnu.tar.bz2.sha
            shasum avrdude-6.0.1-arduino5-i686-pc-linux-gnu.tar.bz2 | awk '{ print $1 }' > avrdude-6.0.1-arduino5-i686-pc-linux-gnu.tar.bz2.sha
        elif [ $Sys == "linux64" ]; then
            MAKE_JOBS="$JOBS" ./arch.linux64.build.bash
            shasum avr-gcc-4.8.1-arduino5-x86_64-pc-linux-gnu.tar.bz2 | awk '{ print $1 }' > avr-gcc-4.8.1-arduino5-x86_64-pc-linux-gnu.tar.bz2.sha
            shasum avrdude-6.0.1-arduino5-x86_64-pc-linux-gnu.tar.bz2 | awk '{ print $1 }' > avrdude-6.0.1-arduino5-x86_64-pc-linux-gnu.tar.bz2.sha
        fi
    elif [ `uname -s` == "Darwin" ]; then
        MAKE_JOBS="$JOBS" arch.mac32.build.bash
        shasum avr-gcc-4.8.1-arduino5-i386-apple-darwin11.tar.bz2 | awk '{ print $1 }' > avr-gcc-4.8.1-arduino5-i386-apple-darwin11.tar.bz2.sha
        shasum avrdude-6.0.1-arduino5-i686-i386-apple-darwin11.tar.bz2 | awk '{ print $1 }' > avrdude-6.0.1-arduino5-i386-apple-darwin11.tar.bz2.sha
    fi
    mv -v avr-gcc* ../linux/
    mv -v avrdude*arduino* ../linux/
    cd $Working_Directory
fi


if [ ! `ls linux/avrdude*arduino*bz2` ]; then
    echo -e "\n\nBuilding avrdude\n\n"
    cd toolchain-avr
    if [ `uname -s` == "Linux" ]; then
        if [ $Sys == "arm" ]; then
            ./clean.bash
            MAKE_JOBS="$JOBS" ./avrdude.build.bash
            shasum avrdude-6.0.1-arduino5-armhf-pc-linux-gnu.tar.bz2 | awk '{ print $1 }' > avrdude-6.0.1-arduino5-armhf-pc-linux-gnu.tar.bz2.sha
        elif [ $Sys == "linux32" ]; then
            ./clean.bash
            MAKE_JOBS="$JOBS" ./avrdude.build.bash
            shasum avrdude-6.0.1-arduino5-i686-pc-linux-gnu.tar.bz2 | awk '{ print $1 }' > avrdude-6.0.1-arduino5-i686-pc-linux-gnu.tar.bz2.sha
        elif [ $Sys == "linux64" ]; then
            ./clean.bash
            MAKE_JOBS="$JOBS" ./avrdude.build.bash
            shasum avrdude-6.0.1-arduino5-x86_64-pc-linux-gnu.tar.bz2 | awk '{ print $1 }' > avrdude-6.0.1-arduino5-x86_64-pc-linux-gnu.tar.bz2.sha
        fi
    elif [ `uname -s` == "Darwin" ]; then
        ./clean.bash
        MAKE_JOBS="$JOBS" ./avrdude.build.bash
        shasum avrdude-6.0.1-arduino5-i686-i386-apple-darwin11.tar.bz2 | awk '{ print $1 }' > avrdude-6.0.1-arduino5-i386-apple-darwin11.tar.bz2.sha
    fi
    mv -v avrdude*arduino* ../linux/
    cd $Working_Directory
fi

# End toolchain-avr

# Asyle
if [[ ! -d astyle ]]; then
    echo -e "\n\nGetting astyle\n"
    git clone https://github.com/arduino/astyle
    sed -i 's/svn co/svn co  --quiet/' astyle/setup.bash
fi

if [[ $ReBuild_astyle == "yes" ]]; then
    echo -e "\n\nDelete stuff to enable Rebuilding of astyle\n"
    if [ `ls libastylej*.zip` ]; then
        rm -v ./libastylej*.zip
    fi
    if [ `ls libastylej*.sha` ]; then
        rm -v ./libastylej*.sha
    fi
fi

if [ $Update_git == "yes" ]; then
    echo -e "\n\nChecking for astyle github updates\n"
    cd astyle
    if [[ ! `git status -uno | grep up-to-date` ]]; then
        git remote -v update
        rm -v ../libastylej*.zip
        rm -v ../libastylej*.sha
    fi
    cd ..
fi

# Note: if the directory was the same as the name of the file it be easier to upgrade
# <param name="archive_file" value="./libastylej-2.05.1.zip" />

if [[ ! -f libastylej-2.05.1.zip ]]; then
    echo -e "\n\nBuilding astyle\n"
    if [ `uname -s` == "Linux" ]; then
        cd astyle
        ./setup.bash
        cd astyle-code/AStyle/build/gcc/

        if [ $Sys == "arm" ]; then
            CFLAGS="-Os" LDFLAGS="-s" make java -j $JOBS
            cd bin
            mkdir libastylej-2.05.1
            cp libastyle*.so libastylej-2.05.1/libastylej_arm.so
        else
            CFLAGS="-m$Bits -Os" LDFLAGS="-m$Bits -s" make java -s
            cd bin
            mkdir libastylej-2.05.1
            cp libastyle*.so libastylej-2.05.1/libastylej$Bits.so
        fi
    elif [ `uname -s` == "Darwin" ]; then
        # UN-tested
        cd astyle
        ./setup.bash
        cd astyle-code/AStyle/build/mac/
        CFLAGS="-arch i386 -arch x86_64 -Os" LDFLAGS="-arch i386 -arch x86_64 -liconv" make java
        cd bin
        mkdir libastylej-2.05.1
        cp libastyle*.dylib libastylej-2.05.1/libastylej.jnilib
    fi

    zip -rv libastylej-2.05.1.zip libastylej-2.05.1
    shasum libastylej-2.05.1.zip | awk '{ print $1 }' > libastylej-2.05.1.zip.sha
    mv libastylej-2.05.1.zip* $Working_Directory
    cd $Working_Directory
fi

# End Asyle


# ctags
if [[ ! -d ctags ]]; then
    echo -e "\n\nChecking for ctags\n"
    git clone --depth 1 https://github.com/arduino/ctags.git
fi

if [[ $ReBuild_ctags == "yes" ]]; then
    echo -e "\n\nDelete stuff to enable Rebuilding of ctags\n"
    if [[ `ls linux/work/tools-builder/ctags/5.8-arduino5/ctags` ]]; then
        rm -v linux/work/tools-builder/ctags/5.8-arduino5/ctags
    fi
    if [ `ls arduino-builder/arduino-builder-$Sys/tools/5.8-arduino5/ctags` ]; then
        rm -v arduino-builder/arduino-builder-$Sys/tools/5.8-arduino5/ctags
    fi
fi

if [[ $Update_git == "yes" ]]; then
    echo -e "\n\nUpdate ctags git\n"
    cd ctags
    if [[ ! `git status -uno | grep up-to-date` ]]; then
        git remote -v update
        if [[ `ls linux/work/tools-builder/ctags/5.8-arduino5/ctags` ]]; then
            rm -v linux/work/tools-builder/ctags/5.8-arduino5/ctags
        fi
        if [ `ls arduino-builder/arduino-builder-$Sys/tools/5.8-arduino5/ctags` ]; then
            rm -v arduino-builder/arduino-builder-$Sys/tools/5.8-arduino5/ctags
        fi
    fi
    cd ..
fi

if [[ ! -f ctags/ctags ]]; then
    echo -e "\n\nBuilding ctags\n"
    cd ctags
    if [[ -f ctags ]]; then
        make distclean
    fi
    ./configure --silent
    make -j $JOBS
    cd ..
fi

# end ctags


# Bossac
if [[ $Bossac == "yes" ]]; then

    if [[ ! `ls linux/bossac*arduino*` ]]; then
        # bossac  bossac-1.6.1-arduino-i486-linux-gnu.tar.gz
        #    apt-get install libwxbase3.0-dev

        if [ ! `which wx-config` ]; then
            echo "nope, You need libwxbase3.0-dev"
            exit 1
        fi
        if [[ ! -f Bossa-1.6.1-arduino.tar.gz  ]]; then
	        wget -N https://github.com/shumatech/BOSSA/archive/1.6.1-arduino.tar.gz
	        mv 1.6.1-arduino.tar.gz Bossa-1.6.1-arduino.tar.gz
        fi
        tar xf Bossa-1.6.1-arduino.tar.gz

        cd BOSSA-1.6.1-arduino
        sed -i 's/-j4/-j4 -s/' arduino/make_package.sh
        arduino/./make_package.sh

        shasum arduino/bossac-1.6.1-arduino-arm-linux-gnueabihf.tar.gz | awk '{ print $1 }' > arduino/bossac-1.6.1-arduino-arm-linux-gnueabihf.tar.gz.sha
        mv arduino/bossac*arduino* ../linux
        cd ..
    fi
fi

# End Bossac

# Coan
if [[ $Coan == "yes" ]]; then

    if [[ ! `ls linux/coan*arduino*` ]]; then
        if [[ ! -f coan-5.2.tar.gz  ]]; then
	        wget -N http://sourceforge.net/projects/coan2/files/v5.2/coan-5.2.tar.gz
        fi

        rm -rf coan-5.2
        tar xf coan-5.2.tar.gz
        cd coan-5.2
        PREFIX=`pwd`
        ./configure --prefix=$PREFIX
        make -j $JOBS
        make install -j $JOBS

        shasum arduino/bossac-1.6.1-arduino-arm-linux-gnueabihf.tar.gz | awk '{ print $1 }' > coan-5.2-arduino-arm-linux-gnueabihf.tar.gz.sha
        mv coan*arduino* ../linux
        cd ..
    fi
fi

# End Coan

# OpenOCD
if [[ $OpenOCD == "yes" ]]; then

    if [[ ! `ls linux/OpenOCD*` ]]; then

        if [[ ! -d OpenOCD ]]; then
            git clone https://github.com/arduino/OpenOCD.git
        fi

        if [ $Update_git == "yes" ]; then
            cd OpenOCD
            if [[ ! `git status -uno | grep up-to-date` ]]; then
                git remote -v update
                rm ctags
            fi
            cd ..
        fi


        cd OpenOCD
        PREFIX=`pwd`/OpenOCD-0.9.0-dev-arduino
        #bootstrap: Error: libtool is required
        ./bootstrap
        ./configure --prefix=$PREFIX
        make -j $JOBS
        make install -j $JOBS

        tar -cjf OpenOCD-0.9.0-arduino-i486-linux-gnu.tar.bz2 OpenOCD-0.9.0-dev-arduino
        sha256sum OpenOCD-0.9.0-arduino-i486-linux-gnu.tar.bz2 | awk '{print$1}' > OpenOCD-0.9.0-arduino-i486-linux-gnu.tar.bz2.sha
        mv  OpenOCD*arduino*bz2* ../linux
        cd ..
    fi
fi

# OpenOCD

# arduino-builder
if [[ ! -d arduino-builder ]]; then
    echo -e "\n\nGetting Arduino_builder\n"
    git clone --depth 1 https://github.com/arduino/arduino-builder
    cd arduino-builder
    export PATH=$PATH:/usr/local/go/bin/
    export GOPATH=`pwd`
    export GOROOT=/usr/local/go
    go get github.com/go-errors/errors
    go get github.com/stretchr/testify
    go get golang.org/x/codereview/patch
    go get github.com/jstemmer/go-junit-report
    go get golang.org/x/tools/cmd/vet
    cd ..
fi

if [ $Update_git == "yes" ]; then
    echo -e "\n\nChecking for github updates for Arduino_builder\n"
    cd arduino-builder
    if [[ ! `git status -uno | grep up-to-date` ]]; then
        git remote -v update
        rm arduino-builder
        go clean
    fi
    cd ..
fi

if [[ $ReBuild_arduino_builder == "yes" ]]; then
    echo -e "\n\nDelete stuff to enable Rebuilding of Arduino_builder\n"
    if [[ -f arduino-builder/arduino-builder ]]; then
        rm -v arduino-builder/arduino-builder
    fi
fi

# [mkdir] Created dir: /usr/local/src/test_builder/Arduino/build/linux/arduino-builder-linux32
if [[ ! -f arduino-builder/arduino-builder ]]; then
    echo -e "\n\nBuilding Arduino_builder\n"
    cd arduino-builder
    if [[ -d arduino-builder-$Sys ]]; then
        rm -rvf arduino-builder-$Sys
    fi
    export PATH=$PATH:/usr/local/go/bin/
    export GOPATH=`pwd`
    export GOROOT=/usr/local/go
    go clean
    go build

    mkdir -p arduino-builder-$Sys/{hardware,tools/5.8-arduino5}
    cp -v arduino-builder arduino-builder-$Sys/
    cp $Working_Directory/ctags/ctags arduino-builder-$Sys/tools/5.8-arduino5/
    wget https://raw.githubusercontent.com/arduino/arduino-builder/master/src/arduino.cc/builder/hardware/platform.keys.rewrite.txt --directory-prefix=arduino-builder-$Sys/hardware
    wget https://raw.githubusercontent.com/arduino/arduino-builder/master/src/arduino.cc/builder/hardware/platform.txt --directory-prefix=arduino-builder-$Sys/hardware

    Arduino_Builder_version=`arduino-builder-$Sys/./arduino-builder -version | grep Builder | cut -d " " -f3`
    tar -cjSf ./arduino-builder-$Sys-$Arduino_Builder_version.tar.bz2 -C ./arduino-builder-$Sys/ ./
    shasum arduino-builder-$Sys-$Arduino_Builder_version.tar.bz2 | awk '{ print $1 }' > arduino-builder-$Sys-$Arduino_Builder_version.tar.bz2.sha
    cp -v arduino-builder-$Sys-$Arduino_Builder_version.tar.bz2* $Working_Directory
    cd $Working_Directory
fi

# End arduino-builder

echo -e "\n\nSome Checksums\n"
avr_gcc_sha=`cat linux/avr-gcc-*-$SysTag-*gnu.tar.bz2.sha`
avrdude_sha=`cat linux/avrdude-*-$SysTag-*gnu.tar.bz2.sha`
arduino_builder_sha=`cat  arduino-builder-*tar.bz2.sha`


# Building Arduino_IDE
ant clean build
mkdir -p linux/work/tools-builder/ctags/5.8-arduino5
cp ctags/ctags linux/work/tools-builder/ctags/5.8-arduino5/

echo $Start_time
date
exit 0


# Too run, if'n in X11
Arduino/build/linux/work/./arduino


