#!/bin/sh

set -e

SOURCE="false"

. ./functions.sh

init_build
configure
build_image
