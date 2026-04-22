#!/bin/sh

BIND_MOUNT=/home/debian13/lernstick/backports/trixie/
LS_KEYRING=/tmp/lernstick-13.gpg
OTHER_MIRRORS="deb https://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware|deb https://packages.lernstick.ch/lernstick lernstick-13-backports main contrib non-free non-free-firmware|deb https://packages.lernstick.ch/lernstick lernstick-13-backports-staging main contrib non-free non-free-firmware|deb https://packages.lernstick.ch/lernstick lernstick-13-thirdparty-staging main contrib non-free non-free-firmware|deb https://packages.lernstick.ch/lernstick lernstick-13-staging main contrib non-free non-free-firmware"

# pbuilder needs the "dearmored" version of our keyfile
gpg --yes --output $LS_KEYRING --dearmor $(dirname $0)/../config/archives/lernstick-13.key

# main version (Bullseye 64 Bit)
pbuilder create \
	--basetgz /var/cache/pbuilder/base-trixie-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--components "main contrib non-free non-free-firmware" \
	--distribution trixie \
	--extrapackages ca-certificates \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"

# second version for backporting 32 Bit packages (e.g. wine)
pbuilder create \
	--architecture i386 \
	--basetgz /var/cache/pbuilder/base-trixie32-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--components "main contrib non-free non-free-firmware" \
	--distribution trixie \
	--extrapackages ca-certificates \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"
