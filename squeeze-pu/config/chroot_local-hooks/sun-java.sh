#!/bin/sh

SUN_JAVA=/usr/lib/jvm/java-6-sun/jre/bin/java
if [ -e ${SUN_JAVA} ]
then
	update-alternatives --set java ${SUN_JAVA}
fi
