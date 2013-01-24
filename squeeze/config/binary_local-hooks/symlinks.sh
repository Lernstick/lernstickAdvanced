#!/bin/bash
cd binary/live || exit 1
vmlinuz=$(ls vmlinuz* | tail -n1)
ln  $vmlinuz vmlinuz || true
initrd=$(ls initrd.img* | tail -n1)
ln  $initrd initrd.img || true

