#!/bin/bash

xgettext --language=shell --output=grub.pot ../config/includes.binary/boot/grub/*.cfg
for pofile in *.po; do
  msgmerge "$pofile" grub.pot -U
done
