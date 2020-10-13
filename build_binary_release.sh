#/bin/sh

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

# cleanup
git checkout debian10
shutdown -h +5
