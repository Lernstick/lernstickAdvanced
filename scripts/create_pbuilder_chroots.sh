#!/bin/sh

BIND_MOUNT=/home/debian12/lernstick/backports/bookworm/
LS_KEYRING=/tmp/lernstick-12.gpg
OTHER_MIRRORS="deb https://security.debian.org/debian-security bookworm-security main contrib non-free|deb https://packages.lernstick.ch/lernstick lernstick-12-backports main contrib non-free|deb https://packages.lernstick.ch/lernstick lernstick-12-backports-staging main contrib non-free|deb https://packages.lernstick.ch/lernstick lernstick-12-thirdparty-staging main contrib non-free|deb https://packages.lernstick.ch/lernstick lernstick-12-staging main contrib non-free"

# pbuilder needs the "dearmored" version of our keyfile
gpg --yes --output $LS_KEYRING --dearmor $(dirname $0)/../config/archives/lernstick-12.key

# main version (Bullseye 64 Bit)
pbuilder create \
	--basetgz /var/cache/pbuilder/base-bookworm-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--components "main contrib non-free non-free-firmware" \
	--distribution bookworm \
	--extrapackages ca-certificates \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"

# second version for backporting 32 Bit packages (e.g. wine)
pbuilder create \
	--architecture i386 \
	--basetgz /var/cache/pbuilder/base-bookworm32-bpo.tar.gz \
	--bindmounts $BIND_MOUNT \
	--components "main contrib non-free non-free-firmware" \
	--distribution bookworm \
	--extrapackages ca-certificates \
	--keyring $LS_KEYRING \
	--othermirror "$OTHER_MIRRORS"
