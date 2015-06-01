#!/bin/sh

set -e

. ./functions.sh
check_and_source_constants
init_build
configure
build_image
