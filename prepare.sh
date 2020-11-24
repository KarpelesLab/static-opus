#!/bin/sh

if [ ! -f opus-1.3.1.tar.gz ]; then
	wget https://archive.mozilla.org/pub/opus/opus-1.3.1.tar.gz
fi

tar xvf opus-1.3.1.tar.gz
cd opus-1.3.1

# gen config.h
./configure

# copy files
cp silk/*.c celt/*.c silk/{arm,fixed,float}/*.c celt/{arm,x86}/*.c src/*.c ../opus/
cp config.h silk/*.h celt/*.h include/*.h src/*.h ../opus/

