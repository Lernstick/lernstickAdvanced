#/bin/sh

if dialog --yesno "Shutdown system after building is complete?" 0 0
then
	SHUTDOWN_AFTER_BUILDING="true"
fi
clear

# build edu version
git checkout debian12
./build_tmpfs.sh
./build_edu-mini_iso.sh
./build_tmpfs.sh
./build_source.sh

# build exam version
git checkout exam-debian12
./build_tmpfs.sh
./build_source.sh

# cleanup
git checkout debian12

# final shutdown?
if [ -n "$SHUTDOWN_AFTER_BUILDING" ]
then
	shutdown -h +5
fi
