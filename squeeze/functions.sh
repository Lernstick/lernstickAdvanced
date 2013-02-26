init_build()
{
	START=$(date)
	TODAY=$(date +%Y-%m-%d)
}

configure_cd()
{
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
	sed -i "s|lernstick Debian 6 (Version .*)|lernstick Debian 6 (Version ${TODAY})|1" \
		config/templates/syslinux/normal/xmlboot.config

	# update time stamp in syslinux menu
#	sed -i -e "s|menu title.*|menu title lernstick${SYSTEM_SUFFIX} `date -I`|" \
#		config/templates/syslinux/menu/menu.cfg
	#sed -i -e "s|menu label ^lernstick.*|menu label ^lernstick${SYSTEM_SUFFIX} `date -I`|" \
	#	config/templates/syslinux/menu/live.cfg
#	cd gfxboot
#	rm -rf gfxboot-themes-lernstick
#	tar xfz *.tar.gz
#	cd gfxboot-themes-lernstick
#	# whoah, multiline sed rulez!!! :-)
#	sed -i "/msgid \"lernstick\"/{n;s/.*/msgstr \"lernstick${SYSTEM_SUFFIX} `date -I`\"/1}" po/*.po
#	dpkg-buildpackage -rfakeroot
#	cd ../..

	# update configuration
	rm -f config/binary
	rm -f config/bootstrap
	rm -f config/chroot
	rm -f config/common
	rm -f config/source
	#lb clean --purge
	lb clean
	lb config \
		--apt-recommends false \
		--apt-secure false \
		--architectures i386 \
		--archive-areas "main contrib non-free" \
		--binary-images iso \
		--distribution "squeeze" \
		--iso-volume "lernstick${SYSTEM_SUFFIX} ${TODAY}" \
		--linux-flavours "686-pae" \
		--linux-packages "linux-image-3.2.0-0.bpo.4" \
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
	lb build 2>&1 | tee logfile.txt

	# I feel like using Windows...
	reset

#	# gfxboot support
#	cp gfxboot/gfxboot-themes-lernstick/install/* binary/isolinux
#	echo 'background=0xB6875A' > binary/isolinux/gfxboot.cfg
#	cat > binary/isolinux/lang << EOF
#de
#EOF
#	cat > binary/isolinux/langlist << EOF
#de
#fr
#it
#es
#sq
#en
#EOF
#	cat binary/isolinux/live.cfg >> binary/isolinux/isolinux.cfg
#	echo 'ui gfxboot bootlogo' >> binary/isolinux/isolinux.cfg
#	cp /usr/lib/syslinux/gfxboot.c32 binary/isolinux
#	cp /usr/lib/syslinux/vesamenu.c32 binary/isolinux
#	cp /usr/lib/syslinux/isolinux.bin binary/isolinux
#	cat > binary/live/live.cfg << EOF
#LOCALE="de"
#KLAYOUT="ch"
#PERSISTENT="Yes"
#DESKTOP="kde"
#EOF
#	lh config --build-with-chroot false && lh binary_iso --force

	PREFIX="lernstick_debian6${ISO_SUFFIX}_${TODAY}"
	IMAGE="${PREFIX}.iso"
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
	echo "Start: ${START}" >> logfile.txt
	echo "Stop : $(date)"
	echo "Stop : $(date)" >> logfile.txt

	# the build process seems to break vbox
	if [ -e /etc/init.d/vboxdrv ]
	then
		/etc/init.d/vboxdrv restart
	fi

	# hello, wake up!!! :-)
	#eject
}

