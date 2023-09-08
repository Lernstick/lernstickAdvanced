#!/bin/sh

set -e

ISO_SUFFIX="_edu"
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

init_build
configure
build_image
