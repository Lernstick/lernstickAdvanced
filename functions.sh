check_and_source_constants()
{
	if [ -e constants ]
	then
		. ./constants
	else
		echo "Please copy the file \"constants.example\" to \"constants\" and adopt the settings to your build environment."
		exit
	fi
}

init_build()
{
	START=$(date)
	TODAY=$(date +%Y-%m-%d)
}

configure_cd()
{
	ISO_SUFFIX="_bootcd"
	SYSTEM_SUFFIX=" Boot-CD"
	# mv config/chroot_local-packageslists/lernstick_squeeze.list config/chroot_local-packageslists/lernstick_squeeze
	# mv config/chroot_local-packageslists/bootcd config/chroot_local-packageslists/bootcd.list
}

configure()
{
	echo ""
}

get_version_number()
{
	echo $1 | sed 's/.*_\(.*\)_.*/\1/' | sed 's/%3a/:/'
}

cache_cleanup()
{
	echo "removing deprecated packages from cache"
	for DIR in cache/packages.*
	do
		echo "checking directory ${DIR}"
		for FILE in ${DIR}/*
		do
			BASE_NAME=$(basename ${FILE})
			PACKAGE_NAME=$(echo ${BASE_NAME} | sed 's/_.*//')
			VERSIONS=$(ls ${DIR}/${PACKAGE_NAME}_*)
			COUNTER=$(echo ${VERSIONS} | wc -w)
			if [ ${COUNTER} -gt 1 ]
			then
				PACKAGE_VERSION="$(get_version_number ${BASE_NAME})"
				for VERSION in ${VERSIONS}
				do
					OTHER_VERSION="$(get_version_number ${VERSION})"
					if dpkg --compare-versions "${PACKAGE_VERSION}" lt "${OTHER_VERSION}"
					then
						echo "removing deprecated cache file ${FILE} (newer version ${OTHER_VERSION} found)"
						rm ${FILE}
						break
					fi
				done
			fi
		done
	done
}

build_image()
{
	# update time stamp in bootloaders
	# ISOLINUX/SYSLINUX
	BOOTLOGO="config/bootloaders/isolinux/bootlogo"
	BOOTLOGO_DIR="${BOOTLOGO}.dir"
	cp templates/xmlboot.config ${BOOTLOGO_DIR}
	sed -i "s|<version its:translate=\"no\">.*</version>|<version its:translate=\"no\">(Version ${TODAY})</version>|1" \
		${BOOTLOGO_DIR}/xmlboot.config
	gfxboot --archive ${BOOTLOGO_DIR} --pack-archive ${BOOTLOGO}
	cp ${BOOTLOGO} ${BOOTLOGO}.orig
	# GRUB
	GRUB_THEME_DIR="config/includes.binary/boot/grub/themes/lernstick"
	cp templates/theme.txt ${GRUB_THEME_DIR}
	sed -i "s|title-text.*|title-text: \"Lernstick Debian 12 (Version ${TODAY})\"|1" \
		${GRUB_THEME_DIR}/theme.txt

	# update configuration
	rm -f config/binary
	rm -f config/bootstrap
	rm -f config/build
	rm -f config/chroot
	rm -f config/common
	rm -f config/source
	lb clean
	lb config \
		--apt-indices false \
		--apt-recommends true \
		--architectures amd64 \
		--archive-areas "main contrib non-free non-free-firmware" \
		--bootloaders "syslinux,grub-efi" \
		--chroot-squashfs-compression-level 22 \
		--chroot-squashfs-compression-type zstd \
		--debootstrap-options "--include=ca-certificates,openssl" \
		--distribution bookworm \
		--firmware-chroot false \
		--iso-volume "lernstick${ISO_SUFFIX} ${TODAY}" \
		--linux-packages linux-image-6.12.9+bpo \
		--mirror-binary ${MIRROR_SYSTEM} \
		--mirror-binary-security ${MIRROR_SECURITY_SYSTEM} \
		--mirror-bootstrap ${MIRROR_BUILD} \
		--security true \
		--source ${SOURCE} \
		--updates true \
		--verbose
		#--linux-packages linux-image-6.1.0-0.deb11.7 \
		# let's hope that we are no longer encountering machines that just freeze with isohybrid images:
		# https://lists.debian.org/debian-live/2011/08/msg00144.html
		# if this is still a problem we need to change back from the default of "iso-hybrid" to plain "iso"
		# --binary-images iso \

	# build image (and produce a log file)
	lb build 2>&1 | tee logfile.txt

	check_nvidia_versions_match

	ISO_FILE="live-image-amd64.hybrid.iso"
	if [ -f ${ISO_FILE} ]
	then
		PREFIX="lernstick_debian12${ISO_SUFFIX}_${TODAY}"
		IMAGE="${PREFIX}.iso"
		mv ${ISO_FILE} ${IMAGE}
		# we must update the zsync file because we renamed the iso file
		echo "Updating zsync file..." | tee -a logfile.txt
		rm *.zsync
		zsyncmake -C ${IMAGE} -u ${IMAGE}
		echo "Creating MD5 for iso..." | tee -a logfile.txt
		md5sum ${IMAGE} > ${IMAGE}.md5

		if [ "${SOURCE}" = "true" ]
		then
			# debian live sources
			mv live-image-source.live.tar ${PREFIX}-source.live.tar

			# debian sources
			DEBIAN_TAR="${PREFIX}-source.debian.tar"
			mv live-image-source.debian.tar ${DEBIAN_TAR}
			md5sum ${DEBIAN_TAR} > ${DEBIAN_TAR}.md5
		fi

		# move files from tmpfs to harddisk
		if [ -d "${BUILD_DIR}" ]
		then
			mv ${PREFIX}* "${BUILD_DIR}"
		fi
	else
		echo "Error: ISO file was not build" | tee -a logfile.txt
	fi

	cache_cleanup

	# When installing firmware-b43legacy-installer downloads.openwrt.org is
	# sometimes down. Building doesn't fail in this situation but we would
	# have produced an image without support for some legacy broadcom cards.
	# Therefore we must check via eyeballs what happened...
	grep downloads.openwrt.org logfile.txt

	echo "Start: ${START}" | tee -a logfile.txt
	echo "Stop : $(date)" | tee -a logfile.txt
	if [ -d "${BUILD_DIR}" ]
	then
		mv logfile.txt "${BUILD_DIR}"
	fi

	# hello, wake up!!! :-)
	#eject
}

check_nvidia_versions_match() {
  echo "Checking nvidia kernel module and flatpak version compatibility..."

  # Path to build chroot (same one you pass to `chroot`)
  CHROOT_PATH="$(pwd)/chroot"

  # Track what we mounted so we can clean up
  mounted_proc=0; mounted_sys=0; mounted_dev=0; mounted_devpts=0

  if ! mountpoint -q "$CHROOT_PATH/proc"; then
    sudo mount -t proc proc "$CHROOT_PATH/proc" || { echo "mount proc failed"; exit 1; }
    mounted_proc=1
  fi
  if ! mountpoint -q "$CHROOT_PATH/sys"; then
    sudo mount -t sysfs sysfs "$CHROOT_PATH/sys" || { echo "mount sys failed"; exit 1; }
    mounted_sys=1
  fi
  if ! mountpoint -q "$CHROOT_PATH/dev"; then
    sudo mount --bind /dev "$CHROOT_PATH/dev" || { echo "mount dev failed"; exit 1; }
    mounted_dev=1
  fi
  if ! mountpoint -q "$CHROOT_PATH/dev/pts"; then
    sudo mount --bind /dev/pts "$CHROOT_PATH/dev/pts" || { echo "mount dev/pts failed"; exit 1; }
    mounted_devpts=1
  fi

  # Cleanup function runs when we leave this function
  cleanup_mounts() {
    [[ $mounted_devpts -eq 1 ]] && sudo umount "$CHROOT_PATH/dev/pts"
    [[ $mounted_dev    -eq 1 ]] && sudo umount "$CHROOT_PATH/dev"
    [[ $mounted_sys    -eq 1 ]] && sudo umount "$CHROOT_PATH/sys"
    [[ $mounted_proc   -eq 1 ]] && sudo umount "$CHROOT_PATH/proc"
  }
  trap cleanup_mounts RETURN

  # Get kernel module version
  NVIDIA_KERNEL_VERSION=$(chroot "$CHROOT_PATH" dpkg -l | sed -n "s/.*nvidia-kernel-\([0-9.]*\)-.*/\1/p")

  # Get Flatpak driver version
  FLATPAK_DRIVER_VERSION_RAW=$(chroot "$CHROOT_PATH" flatpak list --columns=application \
    | sed -n 's/.*\.nvidia-\(.*\)/\1/p')

  # Normalize: change dashes to dots
  FLATPAK_DRIVER_VERSION=$(printf '%s' "$FLATPAK_DRIVER_VERSION_RAW" | sed 's/-/./g')

  echo "Kernel module version: $NVIDIA_KERNEL_VERSION"
  echo "Flatpak driver version (raw): $FLATPAK_DRIVER_VERSION_RAW"
  echo "Flatpak driver version (dots): $FLATPAK_DRIVER_VERSION"

  if [[ -z $NVIDIA_KERNEL_VERSION || -z $FLATPAK_DRIVER_VERSION ]]; then
    echo "ERROR: Could not determine NVIDIA versions correctly."
    exit 1
  fi

  if [[ "$FLATPAK_DRIVER_VERSION" != "$NVIDIA_KERNEL_VERSION" ]]; then
    echo "ERROR: Versions do not match!"
    echo "       Kernel module: $NVIDIA_KERNEL_VERSION"
    echo "       Flatpak      : $FLATPAK_DRIVER_VERSION"
    exit 1
  fi

  echo "OK: NVIDIA versions match."
}
