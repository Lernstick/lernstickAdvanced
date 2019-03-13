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
	echo "found tmpfs mounted on \"${TMPFS}\""
	if findmnt "${TMPFS_IMAGE_MOUNT}" > /dev/null
	then
		echo "found tmpfs image mounted on \"${TMPFS_IMAGE_MOUNT}\""
		echo "killing all processes still accessing \"${TMPFS_IMAGE_MOUNT}\""
		fuser -v -k -m "${TMPFS_IMAGE_MOUNT}"
		sleep 3
		echo "unmounting \"${TMPFS_IMAGE_MOUNT}\""
		if umount "${TMPFS_IMAGE_MOUNT}"
		then
			rm -f "${TMPFS_IMAGE}"
		else
			echo "unmounting \"${TMPFS_IMAGE_MOUNT}\" failed, exiting..."
			exit 1
		fi
	else
		echo "no tmpfs image mounted on \"${TMPFS_IMAGE_MOUNT}\" found"
	fi
	echo "creating tmpfs mount point \"${TMPFS_IMAGE_MOUNT}\""
	mkdir -p "${TMPFS_IMAGE_MOUNT}"
	# create sparse file for the image
	echo "creating new tmpfs image (${TMPFS_IMAGE_SIZE}G) at \"${TMPFS_IMAGE}\""
	truncate -s ${TMPFS_IMAGE_SIZE}G "${TMPFS_IMAGE}"
	echo "creating ext4 file system in tmpfs image..."
	mkfs.ext4 "${TMPFS_IMAGE}"
	echo "mount tmpfs image to \"${TMPFS_IMAGE_MOUNT}\""
	mount "${TMPFS_IMAGE}" "${TMPFS_IMAGE_MOUNT}"
else
	echo "There is no mounted filesystem in \"${TMPFS}\"."
	exit 1
fi

PWD="$(pwd)"

cp -a "${PWD}/config" "${TMPFS_IMAGE_MOUNT}"
ln -s "${PWD}/cache" "${TMPFS_IMAGE_MOUNT}"
ln -s "${PWD}/templates" "${TMPFS_IMAGE_MOUNT}"
