#!/bin/sh

set -e

ISO_SUFFIX="_standard"
SOURCE="false"

. ./functions.sh
check_and_source_constants

if [ -d "${TMPFS}" ]
then
	cd "${TMPFS}"
else
	echo "The tmpfs directory \"${TMPFS}\" doesn't exist."
	echo "Do you want to run the build without a tmpfs? (y/n)"
	read answer
	if [ "${answer}" != "y" ]
	then
		exit 0
	fi
fi

if [ ! -d "${BUILD_DIR}" ]
then
	echo "ERROR: build directory ${BUILD_DIR} doesn't exist."
	echo "Please check the BUILD_DIR definition in your constants file."
	exit 0
fi

# copy additional package lists to config directory
cp templates/debian_main-standard.list.chroot config/package-lists/
cp templates/itch.list.chroot config/package-lists/
cp templates/lernstick-standard.list.chroot config/package-lists/

# remove uninstall hook of mini version
rm -f config/hooks/live/uninstall_packages-mini.chroot

init_build
configure
build_image
