#!/bin/bash

FILE="reverse-dependencies.csv"

START=$(date)

# refresh package information
sudo apt-get update

PACKAGES="$(dpkg -l | grep ^ii | awk '{ print $2 }')"
PACKAGE_COUNT="$(echo ${PACKAGES} | wc -w)"
COUNTER=1

echo "package,reverse dependencies counter,package size" > ${FILE}

for i in $PACKAGES
do
	echo -n "${COUNTER}/${PACKAGE_COUNT} "
	COUNT=$(apt-rdepends -r $i --follow=Depends,PreDepends,Recommends --show=Depends,PreDepends,Recommends --state-show=Installed --state-follow=Installed 2>/dev/null | grep "Reverse Depends\|Reverse Recommends" | wc -l)
	SIZE=$(apt-cache show --no-all-versions $i | grep ^Size | awk '{ print $2 }')
	echo "${i},${COUNT},${SIZE}" | tee -a ${FILE}
	COUNTER=$((${COUNTER} + 1))
done

echo "Start: ${START}"
echo "Stop : $(date)"
