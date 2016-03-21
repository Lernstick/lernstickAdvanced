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
#	mv config/chroot_local-packageslists/lernstick_squeeze.list config/chroot_local-packageslists/lernstick_squeeze
#	mv config/chroot_local-packageslists/bootcd config/chroot_local-packageslists/bootcd.list
}

configure()
{
	echo ""
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
	sed -i "s|title-text.*|title-text: \"Lernstick-Prüfungsumgebung Debian 8 (Version ${TODAY})\"|1" \
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
                --apt-recommends false \
                --architectures i386 \
                --archive-areas "main contrib non-free" \
                --binary-images iso \
                --distribution jessie \
                --iso-volume "lernstick${SYSTEM_SUFFIX} ${TODAY}" \
		--firmware-chroot false \
		--linux-flavours "686-pae 686" \
		--linux-packages linux-image-4.4.0-1+lernstick.2 \
                --mirror-binary ${MIRROR_SYSTEM} \
                --mirror-binary-security ${MIRROR_SECURITY_SYSTEM} \
                --mirror-bootstrap ${MIRROR_BUILD} \
                --source ${SOURCE} \
                --verbose


	# build image (and produce a log file)
	linux32 lb build 2>&1 | tee logfile.txt

	ISO_FILE="live-image-i386.iso"
	if [ -f ${ISO_FILE} ]
	then
		PREFIX="lernstick_pruefungsumgebung_debian8_32bit${ISO_SUFFIX}_${TODAY}"
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

