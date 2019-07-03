#!/bin/sh

BIND_MOUNT=/home/lernstick_debian9/lernstick/backports/stretch/
LS_KEYRING=/tmp/lernstick-9.gpg
OTHER_MIRRORS="deb http://security.debian.org/ stretch/updates main|deb http://packages.lernstick.ch/lernstick lernstick-9-backports main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-9-backports-staging main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-9-thirdparty-staging main contrib non-free|deb http://packages.lernstick.ch/lernstick lernstick-9-staging main contrib non-free"

# pbuilder needs the "dearmored" version of our keyfile
gpg --yes --output $LS_KEYRING --dearmor $(dirname $0)/../config/archives/lernstick-9.key

# main version (Stretch 64 Bit)
pbuilder \
	--create \
	--basetgz /var/cache/pbuilder/base-stretch-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--debootstrapopts --include=apt-transport-https,ca-certificates,openssl \
	--distribution stretch \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"

# second version for backporting 32 Bit packages (e.g. wine)
pbuilder \
	--create \
	--architecture i386 \
	--basetgz /var/cache/pbuilder/base-stretch32-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--debootstrapopts --include=apt-transport-https,ca-certificates,openssl \
	--distribution stretch \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"
