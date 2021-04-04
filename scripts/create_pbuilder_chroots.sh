#!/bin/sh

BIND_MOUNT=/home/debian11/lernstick/backports/bullseye/
LS_KEYRING=/tmp/lernstick-11.gpg
#OTHER_MIRRORS="deb http://security.debian.org/ bullseye/updates main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-11-backports main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-11-backports-staging main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-11-thirdparty-staging main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-11-staging main contrib non-free"
OTHER_MIRRORS=""

# pbuilder needs the "dearmored" version of our keyfile
gpg --yes --output $LS_KEYRING --dearmor $(dirname $0)/../config/archives/lernstick-11.key

# main version (Bullseye 64 Bit)
pbuilder \
	--create \
	--basetgz /var/cache/pbuilder/base-bullseye-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--debootstrapopts --include=apt-transport-https,ca-certificates,openssl \
	--distribution bullseye \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"

# second version for backporting 32 Bit packages (e.g. wine)
pbuilder \
	--create \
	--architecture i386 \
	--basetgz /var/cache/pbuilder/base-bullseye32-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--debootstrapopts --include=apt-transport-https,ca-certificates,openssl \
	--distribution bullseye \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"
