init_build()
{
	START=$(date)
	TODAY=$(date +%Y-%m-%d)
}

configure_cd()
{
	configure
	ISO_SUFFIX="_bootcd"
	SYSTEM_SUFFIX=" Boot-CD"
	mv config/chroot_local-packageslists/lernstick_squeeze.list config/chroot_local-packageslists/lernstick_squeeze
	mv config/chroot_local-packageslists/bootcd config/chroot_local-packageslists/bootcd.list
}

configure()
{
	mv config/chroot_local-packageslists/lernstick_squeeze config/chroot_local-packageslists/lernstick_squeeze.list
	mv config/chroot_local-packageslists/bootcd.list config/chroot_local-packageslists/bootcd
}

build_image()
{
	# update time stamp in gfxboot menu
        sed -i "s|Debian 6 (Version .*)|Debian 6 (Version ${TODAY})|1" \
                config/templates/syslinux/normal/xmlboot.config

	# update configuration
	rm -f config/binary
	rm -f config/bootstrap
	rm -f config/chroot
	rm -f config/common
	rm -f config/source
	#lh clean --purge
	lh clean
	lh config \
		--apt-recommends false \
		--apt-secure false \
		--archive-areas "main contrib non-free" \
		--binary-images iso \
		--distribution "squeeze" \
		--iso-volume "lernstick${SYSTEM_SUFFIX} ${TODAY}" \
		--linux-packages "linux-image-3.2.0-0.bpo.4" \
		--linux-flavours "686-pae" \
		--mirror-binary http://ftp.ch.debian.org/debian/ \
		--mirror-bootstrap http://ftp.ch.debian.org/debian/ \
		--mirror-chroot http://ftp.ch.debian.org/debian/ \
		--mirror-chroot-security http://security.debian.org/ \
		--source ${SOURCE} \
                --syslinux-menu false \
		--templates "config/templates"

	# disable volatile
	sed -i -e 's|LB_VOLATILE=.*|LB_VOLATILE=false|g' config/chroot

	# build image (and produce a log file)
	lh build 2>&1 | tee logfile.txt

	# I feel like using Windows...
	reset

	# with kernel version...
	#IMAGE=lernstick_${KERNEL}_${TODAY}${ISO_SUFFIX}.iso
	PREFIX="lernstick_pruefungsumgebung_debian6_${TODAY}"
	IMAGE="${PREFIX}${ISO_SUFFIX}.iso"
	mv binary.iso ${IMAGE}
	echo "Creating MD5 for iso..."
	md5sum ${IMAGE} > ${IMAGE}.md5

	if [ "${SOURCE}" = "true" ]
	then
		# debian live sources
		mv source.debian-live.tar.gz ${PREFIX}_source.debian-live.tar.gz

		# debian xources
		DEBIAN_TAR="${PREFIX}_source.debian.tar.gz"
		mv source.debian.tar.gz	${DEBIAN_TAR}
		md5sum ${DEBIAN_TAR} > ${DEBIAN_TAR}.md5
	fi

	echo "Start: ${START}"
	echo "Stop : $(date)"

	# the build process seems to break vbox
	/etc/init.d/vboxdrv restart

	# hello, wake up!!! :-)
	#eject
}

