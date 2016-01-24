#!/bin/bash


cp -v files/build_files/* Arduino/build

cp -v files/build-linux_files/* Arduino/build/linux

cp -v files/build-shared_files/* Arduino/build/shared

cp -v files/toolchain-avr_files/* Arduino/build/toolchain-avr

exit 0

