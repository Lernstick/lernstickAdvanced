#!/bin/sh

# This script creates a CSV file that includes leaf packages and the
# size sum of the package itself and its autoremovable dependencies.
# This data can be the base for deciding what packages to remove from
# the default package lists in case our ISO grows too large.

# Sometimes leaf packages have cross dependencies (e.g. to a translation
# package) so it might be a good idea to run this script for all packages,
# i.e. without the is_leaf() function and parse the resulting file with
# your eyes and brain...

is_leaf()
{
	if [ $(apt-cache rdepends --installed $1 | wc -l) -eq 2 ]
	then
		return 0
	else
		return 1
	fi
}

autoremove_list()
{
	apt-get -s autoremove $1 | grep ^Remv | awk '{ print $2 }'
}

> checksize.csv

for i in $(dpkg -l | grep ^ii | awk '{ print $2 }')
do
	echo -n "$i: "
	if is_leaf $i
	then
		echo " === leaf application ==="
		AUTOREMOVE_SIZE=0
		for j in $(apt-get -s autoremove $i | grep ^Remv | awk '{ print $2 }')
		do
			SIZE=$(apt-cache show --no-all-versions $j | grep ^Size | awk '{ print $2 }')
			echo "   size of $j: ${SIZE}"
			AUTOREMOVE_SIZE=$((${AUTOREMOVE_SIZE} + ${SIZE}))
		done
		echo "   autoremove size: ${AUTOREMOVE_SIZE}"
		echo "$i,${AUTOREMOVE_SIZE}" >> checksize.csv
	else
		echo " ... no leaf application, skipping..."
	fi
done
