#!/bin/sh
DIR="../config/includes.binary/boot/grub"
ckbcomp de | grub-mklayout -o ${DIR}/de.gkb
ckbcomp us | grub-mklayout -o ${DIR}/us.gkb
ckbcomp ch | grub-mklayout -o ${DIR}/ch.gkb
