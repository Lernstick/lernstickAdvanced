#!/bin/bash

set -e

ISO_SUFFIX="_moodle_rdp"
SOURCE="false"

. ./functions.sh
check_and_source_constants

if [ -d "${TMPFS_IMAGE_MOUNT}" ]
then
	cd "${TMPFS_IMAGE_MOUNT}"
elif [ -n "${TMPFS_IMAGE_MOUNT}" ]
then
	echo "WARNING: tmpfs directory \"${TMPFS_IMAGE_MOUNT}\" doesn't exist, building without tmpfs."
fi

if [ -n "${BUILD_DIR}" ] && [ ! -d "${BUILD_DIR}" ]
then
	echo "ERROR: build directory ${BUILD_DIR} doesn't exist."
	echo "Please check the BUILD_DIR definition in your constants file."
	exit 1
fi

prepare_moodle_rdp_profile()
{
	echo "==> Preparing minimal Moodle + RDP profile"

	find config/package-lists -maxdepth 1 -type f -name '*.list.chroot' \
		! -name 'commandline.list.chroot' \
		! -name 'debian_contrib-core.list.chroot' \
		! -name 'debian_main-core.list.chroot' \
		! -name 'debian_non-free.list.chroot' \
		! -name 'gnome-core.list.chroot' \
		! -name 'grub-efi.list.chroot' \
		! -name 'lernstick-core.list.chroot' \
		! -name 'lernstick-drivers.list.chroot' \
		! -name 'lernstick-gnome-core.list.chroot' \
		-delete

	rm -f \
		config/hooks/live/enable-flathub.container \
		config/hooks/live/install-proxam-exam-client.chroot \
		config/includes.chroot_after_packages/etc/xdg/autostart/clipit-startup.desktop \
		config/includes.chroot_after_packages/etc/lernstick-exam-client.conf \
		config/includes.chroot_after_packages/etc/lernstick-firewall/proxy.d/proxam.conf

	cat > config/package-lists/proxam-moodle-rdp.list.chroot <<'EOF'
firefox-esr
firefox-esr-l10n-de
firefox-esr-l10n-en-gb
remmina
remmina-plugin-rdp
zenity
EOF

	mkdir -p config/includes.chroot_after_packages/etc/xdg/autostart
	mkdir -p config/includes.chroot_after_packages/etc
	mkdir -p config/includes.chroot_after_packages/etc/lernstick-firewall/proxy.d
	mkdir -p config/includes.chroot_after_packages/usr/local/bin
	mkdir -p config/includes.chroot_after_packages/usr/share/applications

	install -m 0644 templates/proxam-moodle-rdp/lernstickWelcome \
		config/includes.chroot_after_packages/etc/lernstickWelcome
	install -m 0644 templates/proxam-moodle-rdp/proxam-firewall-whitelist.conf \
		config/includes.chroot_after_packages/etc/lernstick-firewall/proxy.d/proxam.conf
	install -m 0644 templates/proxam-moodle-rdp/proxam-moodle-rdp.conf \
		config/includes.chroot_after_packages/etc/proxam-moodle-rdp.conf
	install -m 0755 templates/proxam-moodle-rdp/proxam-moodle-rdp-launcher \
		config/includes.chroot_after_packages/usr/local/bin/proxam-moodle-rdp-launcher
	install -m 0644 templates/proxam-moodle-rdp/proxam-moodle-rdp.desktop \
		config/includes.chroot_after_packages/etc/xdg/autostart/proxam-moodle-rdp.desktop
	install -m 0644 templates/proxam-moodle-rdp/proxam-moodle-rdp.desktop \
		config/includes.chroot_after_packages/usr/share/applications/proxam-moodle-rdp.desktop
}

init_build
prepare_moodle_rdp_profile
configure
build_image