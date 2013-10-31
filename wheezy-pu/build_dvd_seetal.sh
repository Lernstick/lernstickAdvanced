#!/bin/sh

SOURCE="false"

# variant specific features 
VARIANT="Kantonsschule Seetal "
cp variants/seetal/seetal.chroot config/hooks/ 
cp variants/seetal/seetal.list.chroot config/package-lists/

# common build
. ./functions.sh
init_build
configure
build_image

# cleanup
rm config/hooks/seetal.chroot
rm config/package-lists/seetal.list.chroot
