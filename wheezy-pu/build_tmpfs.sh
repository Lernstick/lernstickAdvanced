#!/bin/sh
. ./constants

rm -rf "${TMPFS}"
mkdir "${TMPFS}"

PWD="$(pwd)"

cp -a "${PWD}/config" "${TMPFS}"
ln -s ${PWD}/build_dvd* "${TMPFS}"
ln -s "${PWD}/build_source.sh" "${TMPFS}"
ln -s "${PWD}/cache" "${TMPFS}"
ln -s "${PWD}/functions.sh" "${TMPFS}"
ln -s "${PWD}/constants" "${TMPFS}"
ln -s "${PWD}/variants" "${TMPFS}"
