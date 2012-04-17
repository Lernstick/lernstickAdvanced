#!/bin/sh

if [ -x /usr/sbin/locale-gen ]
then
	echo "de_CH.UTF-8 UTF-8" > /etc/locale.gen
	echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
	echo "fr_CH.UTF-8 UTF-8" >> /etc/locale.gen
	echo "it_CH.UTF-8 UTF-8" >> /etc/locale.gen
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
	echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
	echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
	echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen
	echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
	echo "sq_AL.UTF-8 UTF-8" >> /etc/locale.gen
	locale-gen
fi
