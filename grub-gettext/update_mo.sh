#!/bin/bash
for PO_FILE in *.po; do
  MO_FILE="$(echo "${PO_FILE}" | sed 's/\.po$/\.mo/1')"
  msgfmt "${PO_FILE}" -o "../config/includes.binary/boot/grub/locale/${MO_FILE}"
done
