#!/bin/sh

wget -nv -r http://backports.undebian.org/repositories/backports-other/archive-key.asc -O debian-backports.chroot.gpg
wget -nv -r http://custom.undebian.org/repository/archive-key.asc -O debian-custom.chroot.gpg
wget -nv -r http://live.debian.net/debian/archive-key.asc -O debian-live.chroot.gpg
wget -nv -r http://restricted.undebian.org/repositoriy/archive-key.asc -O debian-restricted.chroot.gpg

wget -nv -r http://unsupported.undebian.org/repositories/custom-imedias/archive-key.asc -O phso.chroot.gpg
