#/bin/sh

if dialog --yesno "Shutdown system after building is complete?" 0 0
then
	SHUTDOWN_AFTER_BUILDING="true"
fi
clear

# build edu version
git checkout debian11
./build_tmpfs.sh
./build_mini_iso.sh
./build_tmpfs.sh
./build_standard_iso.sh

# build exam version
git checkout exam-debian11
./build_tmpfs.sh
./build_iso.sh

# checkout main repo
git checkout debian11

# final shutdown?
if [ -n "$SHUTDOWN_AFTER_BUILDING" ]
then
	shutdown -h +5
fi
