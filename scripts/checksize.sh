#!/bin/sh

# This script creates a CSV file that includes packages and the
# size sum of the package itself and its autoremovable dependencies.
# This data can be the base for deciding what packages to remove from
# the default package lists in case our ISO grows too large.

echo "package,autoremove size,removed packages" > checksize.csv


for i in $(dpkg -l | grep ^ii | awk '{ print $2 }')
do
	echo "$i: "
	AUTOREMOVE_SIZE=0
	AUTOREMOVE_PACKAGES="$(apt-get -s autoremove $i | grep ^Remv | awk '{ print $2 }')"
	for i in ${AUTOREMOVE_PACKAGES}
	do
		SIZE=$(apt-cache show --no-all-versions $i | grep ^Size | awk '{ print $2 }')
		echo "   size of $i: ${SIZE}"
		AUTOREMOVE_SIZE=$((${AUTOREMOVE_SIZE} + ${SIZE}))
	done
	echo "   ===> autoremove size: ${AUTOREMOVE_SIZE}"
	echo -n "$i,${AUTOREMOVE_SIZE}," >> checksize.csv
        for i in ${AUTOREMOVE_PACKAGES}
	do
		echo -n "$i " >> checksize.csv
	done
	echo "" >> checksize.csv
done
