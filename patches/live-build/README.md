# Patches for live-build
We patch live-build to fit our needs.
This unfortunately means that Lernstick doesn't build correctly with normal live-build.

## Patches
* `0001-chroot-hooks-for-sytemd-nspawn-containers.patch` Enables support systemd-nspawn containers.(Used for Flatpak support)
* `0001-execute-binary_hooks-after-binary_grub-efi-so-that-i.patch`
* `0001-improved-mksquashfs.patch` Use zstd for squashfs compression with max compression ratio
* `0001-replaced-tar-with-rsync-as-it-is-much-more-efficient.patch` Performace improvements (currently not used)
* `0002-chroot-includes.patch` Add pre package install and post package install includes
* `no-compression.patch` Disables compression (used for faster development)

Patches can be dis/enabled in the `series` file.

## Patch live-build
Tested with version 20190311
1. Install packaging tools: `apt install packaging-dev debian-keyring devscripts equivs`
2. Download live-build: `apt source live-build` (If this doesn't work add `deb-src http://deb.debian.org/debian/ testing main` to your sources list)
3. `cd live-build-*`
4. `mkdir debian/patches`
5. `cp path/to/patches/* debian/patches/`
6. `export QUILT_PATCHES=debian/patches && export QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"`
7. `quilt push -a`
8. Build package: `dpkg-buildpackage -uc -us`
9. Install package: `cd .. && dpkg -i live-build_*.deb`
