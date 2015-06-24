#!/bin/sh

set -e

SOURCE="false"

. ./functions.sh
check_and_source_constants
init_build
configure
build_image
