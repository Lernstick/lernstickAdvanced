#!/bin/bash
while read line
do
	diff -u $line
done < <(dpkg-divert --list | grep desktop | sort | awk '{ print $5 " " $3; }') > desktop_files.diff

vim desktop_files.diff
