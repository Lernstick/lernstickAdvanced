#!/bin/bash

# This script creates a CSV file that includes packages and the
# size sum of the package itself and its autoremovable dependencies.
# This data can be the base for deciding what packages to remove from
# the default package lists in case our ISO grows too large.

# refresh package information
sudo apt-get update

START=$(date)

echo "package,autoremove size,removed packages" > checksize.csv

declare -A SIZE_CACHE

PACKAGES="$(dpkg -l | grep ^ii | awk '{ print $2 }')"
PACKAGE_COUNT="$(echo ${PACKAGES} | wc -w)"
COUNTER=1

for i in ${PACKAGES}
do
	echo "$i (${COUNTER}/${PACKAGE_COUNT}): "
        PRIORITY="$(apt-cache show --no-all-versions $i | grep ^Priority | awk '{ print $2 }')"
        echo "   priority: ${PRIORITY}"
        if [ "${PRIORITY}" = "required" ] || [ "${PRIORITY}" = "important" ]
        then
                echo "   skipping because package priority is ${PRIORITY}"
                continue
        fi
	AUTOREMOVE_SIZE=0
	AUTOREMOVE_PACKAGES="$(apt-get -s autoremove $i | grep ^Remv | awk '{ print $2 }' | sort)"
	for j in ${AUTOREMOVE_PACKAGES}
	do
		if [ ${SIZE_CACHE[$j]+_} ]
		then
			SIZE=${SIZE_CACHE[$j]}
			echo "   size of $j: ${SIZE} (cached)"
		else
			SIZE=$(apt-cache show --no-all-versions $j | grep ^Size | awk '{ print $2 }')
			SIZE_CACHE[$j]=${SIZE}
			echo "   size of $j: ${SIZE}"
		fi
		AUTOREMOVE_SIZE=$((${AUTOREMOVE_SIZE} + ${SIZE}))
	done
	echo "   ===> autoremove size of $i: ${AUTOREMOVE_SIZE}"
	#echo "   ---> cache size: ${#SIZE_CACHE[@]}"
	echo -n "$i,${AUTOREMOVE_SIZE}," >> checksize.csv
        for j in ${AUTOREMOVE_PACKAGES}
	do
		echo -n "$j " >> checksize.csv
	done
	echo "" >> checksize.csv
	COUNTER=$((${COUNTER} + 1))
done

echo "Start: ${START}"
echo "Stop : $(date)"
