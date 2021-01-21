#/bin/sh

if dialog --yesno "Shutdown system after building is complete?" 0 0
then
	SHUTDOWN_AFTER_BUILDING="true"
fi
clear

# build mini and standard versions
git checkout debian10
./build_tmpfs.sh
./build_mini_iso.sh
./build_tmpfs.sh
./build_standard_iso.sh

# build exam version
git checkout exam-debian10
./build_tmpfs.sh
./build_iso.sh

# checkout main repo
git checkout debian10

# final shutdown?
if [ -n "$SHUTDOWN_AFTER_BUILDING" ]
then
	shutdown -h +5
fi
