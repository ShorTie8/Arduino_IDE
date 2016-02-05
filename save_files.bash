#!/bin/bash


if [[ ! -d files ]]; then
    mkdir files
fi

if [[ ! -d files/build_files ]]; then
    mkdir files/build_files
fi

if [[ ! -d files/build-linux_files ]]; then
    mkdir files/build-linux_files
fi

if [[ ! -d files/build-shared_files ]]; then
    mkdir files/build-shared_files
fi

if [[ ! -d files/toolchain-avr_files ]]; then
    mkdir files/toolchain-avr_files
fi

cp -v Arduino/build/*.zip files/build_files
cp -v Arduino/build/libastyle*.sha files/build_files
cp -v Arduino/build/liblistSerials*.sha files/build_files

cp -v Arduino/build/linux/avr-gcc*tar* files/build-linux_files
cp -v Arduino/build/linux/avrdude*tar* files/build-linux_files

cp -v Arduino/build/shared/*.zip files/build-shared_files

cp -v Arduino/build/toolchain-avr/*tar* files/toolchain-avr_files
cp -v Arduino/build/toolchain-avr/*.zip files/toolchain-avr_files

exit 0

