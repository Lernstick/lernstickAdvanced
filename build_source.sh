#!/bin/sh

SOURCE="true"

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

init_build
configure
build_image
