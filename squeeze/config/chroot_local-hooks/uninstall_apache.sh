#!/bin/sh

# for whatever strange reason, apache gets installed... let's remove it here

apt-get -y purge \
	apache2.2-bin \
	apache2.2-common \
	apache2-mpm-itk \
	apache2-mpm-prefork \
	apache2-utils \
	libapache2-mod-php5 \
	libapache2-mod-php5filter \
	php5-cgi
