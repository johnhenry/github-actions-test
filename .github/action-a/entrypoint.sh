#!/bin/bash -l

VERSION=$(cat package.json \
    | grep version \
    | head -1 \
    | awk -F: '{ print $2 }' \
    | sed 's/[",]//g' \
    | tr -d '[[:space:]]')
# https://gist.github.com/DarrenN/8c6a5b969481725a4413
NEW_VERSION=$(cat package.json \
    | grep newVersion \
    | head -1 \
    | awk -F: '{ print $2 }' \
    | sed 's/[",]//g' \
    | tr -d '[[:space:]]')
if [ "$VERSION" == "$NEW_VERSION" ]; then
    echo 'NO UPDATE'
    exit 0
else
    echo "UPDATE: $VERSION -> $NEW_VERSION"
    # https://gist.github.com/maxrimue/ca69ee78081645e1ef62
    version1=${VERSION//./ }
    version2=${NEW_VERSION//./ }
    patch1=$(echo $version1 | awk '{print $3}')
    minor1=$(echo $version1 | awk '{print $2}')
    major1=$(echo $version1 | awk '{print $1}')
    patch2=$(echo $version2 | awk '{print $3}')
    minor2=$(echo $version2 | awk '{print $2}')
    major2=$(echo $version2 | awk '{print $1}')
    update=''

    if [ $patch1 -lt $patch2 ]; then
        update='PATCH'
    fi

    if [ $minor1 -lt $minor2 ]; then
        update='MINOR'
    fi

    if [ $major1 -lt $major2 ]; then
        update='MAJOR'
    fi

    if [ "MAJOR" = $update ]; then
        echo 'MAJOR'
    elif  [ "MINOR" = $update ]; then
        echo 'MINOR'
    elif  [ "PATCH" = $update ]; then
        echo 'PATCH'
    fi
    np $NEW_VERSION
    exit 0
fi
