#!/bin/sh

PREFERENCES="/etc/apt/preferences"

# linux-image
for i in /lib/modules/*
do
	PACKAGE="linux-image-`echo ${i} | awk -F/ '{ print $4 }'`"
	VERSION=`dpkg -s ${PACKAGE} | grep "Version:" | awk '{ print $2 }'`
	echo "
Package: ${PACKAGE}
Pin: Version ${VERSION}
Pin-Priority: 999" >> ${PREFERENCES}
done

# live-initramfs
PACKAGE="live-initramfs"
VERSION=`dpkg -s ${PACKAGE} | grep "Version:" | awk '{ print $2 }'`
echo "
Package: ${PACKAGE}
Pin: Version ${VERSION}
Pin-Priority: 999" >> ${PREFERENCES}
