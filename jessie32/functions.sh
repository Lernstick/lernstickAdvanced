. ./constants

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
# 	sed -i "s|<version its:translate=\"no\">.*</version>|<version its:translate=\"no\">(Version ${TODAY})</version>|1" \
# 		config/bootloaders/isolinux/xmlboot.config
#	sed -i "s|title-text.*|title-text: \"Lernstick Debian 8 (Version ${TODAY})\"|1" \
#		config/includes.binary/boot/grub/themes/lernstick/theme.txt 

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
                --firmware-chroot true \
                --iso-volume "lernstick${SYSTEM_SUFFIX} ${TODAY}" \
                --mirror-binary http://ftp.ch.debian.org/debian/ \
                --mirror-binary-security http://security.debian.org/ \
                --mirror-bootstrap http://ftp.ch.debian.org/debian/ \
                --mirror-chroot http://ftp.ch.debian.org/debian/ \
                --mirror-chroot-security http://security.debian.org/ \
                --source ${SOURCE} \
                --verbose


	# build image (and produce a log file)
	linux32 lb build 2>&1 | tee logfile.txt

	ISO_FILE="live-image-i386.iso"
	if [ -f ${ISO_FILE} ]
	then
		PREFIX="lernstick_debian8${ISO_SUFFIX}_${TODAY}"
		IMAGE="${PREFIX}.iso"
		mv ${ISO_FILE} ${IMAGE}
		# we must update the zsync file because we renamed the iso file
		echo "Updating zsync file..."
		rm *.zsync
		zsyncmake -C ${IMAGE} -u ${IMAGE}
		echo "Creating MD5 for iso..."
		md5sum ${IMAGE} > ${IMAGE}.md5

		if [ "${SOURCE}" = "true" ]
		then
			# debian live sources
			mv source.debian-live.tar ${PREFIX}_source.debian-live.tar

			# debian sources
			DEBIAN_TAR="${PREFIX}_source.debian.tar"
			mv source.debian.tar ${DEBIAN_TAR}
			md5sum ${DEBIAN_TAR} > ${DEBIAN_TAR}.md5
		fi

		# move files from tmpfs to harddisk
		if [ -d "${BUILD_DIR}" ]
		then
			mv ${PREFIX}* "${BUILD_DIR}"
		fi
	else
		echo "Error: ISO file was not build"
	fi

	echo "Start: ${START}" | tee -a logfile.txt
	echo "Stop : $(date)" | tee -a logfile.txt
	if [ -d "${BUILD_DIR}" ]
	then
		mv logfile.txt "${BUILD_DIR}"
	fi

	# hello, wake up!!! :-)
	#eject
}
