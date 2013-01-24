#!/bin/sh

if [ -f /usr/local/lernstick.html -a -f /usr/local/lernstick_de.html ]
then
	_DATE="$(date -I)"
	sed -i -e "s|@DATE@|${_DATE}|" /usr/local/lernstick.html
	sed -i -e "s|@DATE@|${_DATE}|" /usr/local/lernstick_de.html
fi
