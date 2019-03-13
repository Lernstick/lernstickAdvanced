#!/bin/sh

. ./functions.sh
check_and_source_constants

# Experience has shown that using a file system in RAM speeds up the build
# process between 5 to 10 times in comparison to using a file system on SSDs or
# classical hard drives with spinning rust.
# Unfortunately, tmpfs doesn't support extended attributes but they are needed
# by some tools during installation, e.g. flatpak. Therefore we can't use
# tmpfs mounts directly but must create an additional image inside the tmpfs
# that must be formatted with another file system that supports extended
# attributes (e.g. ext4).

if findmnt "${TMPFS}" > /dev/null
then
	if findmnt "${TMPFS_IMAGE_MOUNT}" > /dev/null
	then
		fuser -k -m "${TMPFS_IMAGE_MOUNT}"
		umount "${TMPFS_IMAGE_MOUNT}"
		rm -f "${TMPFS_IMAGE}"
	fi
	mkdir -p "${TMPFS_IMAGE_MOUNT}"
	# create sparse file for the image
	truncate -s ${TMPFS_IMAGE_SIZE}G "${TMPFS_IMAGE}"
	mkfs.ext4 "${TMPFS_IMAGE}"
	mount "${TMPFS_IMAGE}" "${TMPFS_IMAGE_MOUNT}"
else
	echo "There is no mounted filesystem in \"${TMPFS}\"."
	exit 1
fi

PWD="$(pwd)"

cp -a "${PWD}/config" "${TMPFS_IMAGE_MOUNT}"
ln -s "${PWD}/cache" "${TMPFS_IMAGE_MOUNT}"
ln -s "${PWD}/templates" "${TMPFS_IMAGE_MOUNT}"
