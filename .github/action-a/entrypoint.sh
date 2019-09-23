#!/bin/bash -l
# VERSION=$(cat package.json \
#     | grep version \
#     | head -1 \
#     | awk -F: '{ print $2 }' \
#     | sed 's/[",]//g' \
#     | tr -d '[[:space:]]')
# https://gist.github.com/DarrenN/8c6a5b969481725a4413
# NEW_VERSION=$(cat package.json \
#     | grep newVersion \
#     | head -1 \
#     | awk -F: '{ print $2 }' \
#     | sed 's/[",]//g' \
#     | tr -d '[[:space:]]')

VERSION=$(git show HEAD~1:package.json | jq -r ".version")
NEW_VERSION=$(git show HEAD~0:package.json | jq -r ".version")

if [ "$VERSION" == "$NEW_VERSION" ]; then
    echo "NO UPDATE $VERSION > $NEW_VERSION"
    exit 0
else
    if [ -n "$NPM_AUTH_TOKEN" ]; then
    # Respect NPM_CONFIG_USERCONFIG if it is provided, default to $HOME/.npmrc
    NPM_CONFIG_USERCONFIG="${NPM_CONFIG_USERCONFIG-"$HOME/.npmrc"}"
    NPM_REGISTRY_URL="${NPM_REGISTRY_URL-registry.npmjs.org}"
    NPM_STRICT_SSL="${NPM_STRICT_SSL-true}"
    NPM_REGISTRY_SCHEME="https"
    if ! $NPM_STRICT_SSL
    then
        NPM_REGISTRY_SCHEME="http"
    fi

    # Allow registry.npmjs.org to be overridden with an environment variable
    printf "//%s/:_authToken=%s\\nregistry=%s\\nstrict-ssl=%s" "$NPM_REGISTRY_URL" "$NPM_AUTH_TOKEN" "${NPM_REGISTRY_SCHEME}://$NPM_REGISTRY_URL" "${NPM_STRICT_SSL}" >> "$NPM_CONFIG_USERCONFIG"

    chmod 0600 "$NPM_CONFIG_USERCONFIG"
    fi




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
    git config user.email "noreply@github.com"
    git config user.name "(none)"
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
    str=$(jq -r ".repository.url" package.json)
    regex='github\.com\/(:?[^\/]+)\/(:?[^\/]+)'
    if [[ $str =~ $regex ]]; then
        # set remote origin
        user=${BASH_REMATCH[1]}
        repo=${BASH_REMATCH[2]}
        git remote rm origin
        git remote add origin https://$user:$GITHUB_TOKEN@github.com/$user/$repo
        # set package version to original
        ## create package with older version
        jq ".version = \"$VERSION\"" package.json > package.temp.json
        ## replace package
        mv package.temp.json package.json
        ## add package
        git add package.json
        ## commit
        git commit --message "Pre-publish commit
$NEW_VERSION -> $VERSION"
        git push origin master
        # publish new version

        ordir = $(pwd)
        git clone . --no-checkout ../temp
        cp -R dist/ ../temp/dist/
        cp package.json ../temp/package.json
        cp readme.md ../temp/readme.md
        cd ../temp/
        git add .
        git commit -m "remove cruft for: $NEW_VERSION"
        git push origin master
        cd $ordir

        np $NEW_VERSION
        git push origin master
        git push --tags origin master
    fi
    exit 0
fi
