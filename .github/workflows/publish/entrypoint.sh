#!/bin/bash -l

echo "//registry.npmjs.org/:_authToken=$NPM_AUTH_TOKEN" >> ~/.npmrc

git config --global user.name '(none)' && git config --global user.email 'noreply@github.com' && git remote set-url origin https://x-access-token:${GITHUB_TOKEN}@github.com/$GITHUB_REPOSITORY
npm install
npm run build:dist
npm run build:readme
git add dist
git add package-lock.json
git add readme.md
git commit -n -m "Built dist for $NEW_VERSION"
echo "UPDATING VERSION to $NEW_VERSION ($UPDATE)"

np $NEW_VERSION
git push origin master
git push --tags origin master
exit 0