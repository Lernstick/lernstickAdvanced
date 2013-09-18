#!/bin/sh

SOURCE="false"

# variant specific features 
VARIANT="Aarau "
cp variants/aarau/aarau.list.chroot config/package-lists/

# common build
. ./functions.sh
init_build
configure
build_image

# cleanup
rm config/package-lists/aarau.list.chroot
