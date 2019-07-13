#!/bin/sh -l

OLD_VERSION=$(git describe --abbrev=0 --tags)
PACKAGE_VERSION=$(cat package.json \
  | grep version \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g' \
  | tr -d '[[:space:]]')
echo $OLD_VERSION
echo $PACKAGE_VERSION
exit 0
