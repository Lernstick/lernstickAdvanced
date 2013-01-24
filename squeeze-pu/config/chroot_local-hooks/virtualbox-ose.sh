#!/bin/sh

# This is a hook for live-helper(7) to enable virtualbox-ose module.
# To enable it, copy or symlink this hook into your config/chroot_local-hooks
# directory.

# Enabling loading of vboxdrv
VBOX_DEFAULTS=/etc/default/virtualbox-ose
if [ -e ${VBOX_DEFAULTS} ]
then
	sed -i -e 's|^LOAD_VBOXDRV_MODULE=.*$|LOAD_VBOXDRV_MODULE=1|' ${VBOX_DEFAULTS}
fi
