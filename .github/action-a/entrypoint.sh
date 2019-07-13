#!/bin/bash -l

OLD_VERSION=$(git describe --abbrev=0 --tags)
# https://gist.github.com/DarrenN/8c6a5b969481725a4413
CURRENT_VERSION=$(cat package.json \
    | grep version \
    | head -1 \
    | awk -F: '{ print $2 }' \
    | sed 's/[",]//g' \
    | tr -d '[[:space:]]')
if [ "$OLD_VERSION" == "$CURRENT_VERSION" ]; then
    echo 'NO UPDATE'
    exit 0
else
    echo "UPDATE: $OLD_VERSION -> $CURRENT_VERSION"
    # https://gist.github.com/maxrimue/ca69ee78081645e1ef62
    version1=${OLD_VERSION//./ }
    version2=${CURRENT_VERSION//./ }
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
    np $CURRENT_VERSION
    exit 0
fi
