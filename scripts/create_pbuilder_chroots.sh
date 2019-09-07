#!/bin/sh

BIND_MOUNT=/home/debian10/lernstick/backports/buster/
LS_KEYRING=/tmp/lernstick-10.gpg
OTHER_MIRRORS="deb http://security.debian.org/ buster/updates main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-10-backports main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-10-backports-staging main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-10-thirdparty-staging main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-10-staging main contrib non-free"

# pbuilder needs the "dearmored" version of our keyfile
gpg --yes --output $LS_KEYRING --dearmor $(dirname $0)/../config/archives/lernstick-10.key

# main version (Buster 64 Bit)
pbuilder \
	--create \
	--basetgz /var/cache/pbuilder/base-buster-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--debootstrapopts --include=apt-transport-https,ca-certificates,openssl \
	--distribution buster \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"

# second version for backporting 32 Bit packages (e.g. wine)
pbuilder \
	--create \
	--architecture i386 \
	--basetgz /var/cache/pbuilder/base-buster32-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--debootstrapopts --include=apt-transport-https,ca-certificates,openssl \
	--distribution buster \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"
