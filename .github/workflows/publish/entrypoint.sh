#!/bin/bash -l

echo "//registry.npmjs.org/:_authToken=$NPM_AUTH_TOKEN" >> ~/.npmrc

# https://gist.github.com/maxrimue/ca69ee78081645e1ef62
version1=${VERSION//./ }
version2=${NEW_VERSION//./ }
patch1=$(echo $version1 | awk '{print $3}')
minor1=$(echo $version1 | awk '{print $2}')
major1=$(echo $version1 | awk '{print $1}')
patch2=$(echo $version2 | awk '{print $3}')
minor2=$(echo $version2 | awk '{print $2}')
major2=$(echo $version2 | awk '{print $1}')
UPDATE=''
if [ $patch1 -lt $patch2 ]; then
    UPDATE='PATCH'
fi

if [ $minor1 -lt $minor2 ]; then
    UPDATE='MINOR'
fi

if [ $major1 -lt $major2 ]; then
    UPDATE='MAJOR'
fi
git config --global user.name '(none)' && git config --global user.email 'noreply@github.com' && git remote set-url origin https://x-access-token:${GITHUB_TOKEN}@github.com/$GITHUB_REPOSITORY
npm install
npm run build:dist
npm run build:readme
git add dist
git add package-lock.json
git add readme.md
git commit -n -m "Built dist for $NEW_VERSION"
echo "UPDATING VERSION: $VERSION => $NEW_VERSION ($UPDATE)"

np $NEW_VERSION
git push origin master
git push --tags origin master

exit 0