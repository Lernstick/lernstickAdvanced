#!/bin/bash
# ProXam Exam ISO Build Script
# Builds a Lernstick-based exam ISO with the proxam-exam-client pre-installed.
#
# Usage:
#   ./build_proxam_exam_iso.sh
#
# Requirements:
#   - Debian 13 (Trixie) host or container
#   - live-build, rsync, zsync, gfxboot, libhtml-parser-perl installed
#   - constants file present (copy from constants.example and adapt)

set -e

. ./functions.sh
check_and_source_constants

init_build

ISO_SUFFIX="_proxam_exam"
SOURCE="false"

echo "==> Building ProXam Exam ISO (suffix: ${ISO_SUFFIX})"
echo "==> Build started: $(date)"

# Override distribution to trixie for debian13 branch
build_image_proxam()
{
    TODAY=$(date +%Y-%m-%d)

    rm -f config/binary config/bootstrap config/build config/chroot config/common config/source
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
        --distribution trixie \
        --firmware-chroot false \
        --iso-volume "proxam-exam ${TODAY}" \
        --mirror-binary "${MIRROR_SYSTEM}" \
        --mirror-binary-security "${MIRROR_SECURITY_SYSTEM}" \
        --mirror-bootstrap "${MIRROR_BUILD}" \
        --security true \
        --source false \
        --updates true \
        --verbose

    lb build 2>&1 | tee logfile.txt

    ISO_FILE="live-image-amd64.hybrid.iso"
    if [ -f "${ISO_FILE}" ]; then
        PREFIX="proxam-exam_debian13${ISO_SUFFIX}_${TODAY}"
        IMAGE="${PREFIX}.iso"
        mv "${ISO_FILE}" "${IMAGE}"
        rm -f ./*.zsync
        zsyncmake -C "${IMAGE}" -u "${IMAGE}"
        md5sum "${IMAGE}" > "${IMAGE}.md5"

        if [ -d "${BUILD_DIR}" ]; then
            mv "${PREFIX}"* "${BUILD_DIR}"
            mv logfile.txt "${BUILD_DIR}"
        fi

        echo "==> ISO built successfully: ${IMAGE}"
    else
        echo "ERROR: ISO was not built. Check logfile.txt for details." | tee -a logfile.txt
        exit 1
    fi
}

build_image_proxam
