#!/bin/sh

SOURCE="true"

. ./functions.sh
check_and_source_constants
init_build
configure
build_image
