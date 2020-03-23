#!/bin/sh

set -e

ISO_SUFFIX="_mini"
SOURCE="false"

. ./functions.sh
check_and_source_constants

if [ -d "${TMPFS_IMAGE_MOUNT}" ]
then
	cd "${TMPFS_IMAGE_MOUNT}"
else
	echo "The tmpfs directory \"${TMPFS_IMAGE_MOUNT}\" doesn't exist."
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

# make sure that the additional package lists of the standard version are removed
rm -f config/package-lists/debian_contrib-default.list.chroot
rm -f config/package-lists/debian_main-standard.list.chroot
rm -f config/package-lists/lernstick-standard.list.chroot
rm -f config/package-lists/libreoffice-core.list.chroot

# Enabling flatpak adds around 8 GB (uncompressed) data to the image.
# Therefore we need to disable this hook for the mini version.
rm -f config/hooks/live/enable-flathub.container

# copy uninstall hook to right place
cp templates/uninstall_packages-mini.chroot config/hooks/live/

init_build
configure
build_image
