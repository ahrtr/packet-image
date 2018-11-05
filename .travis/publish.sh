#!/bin/bash

GIT_MAIL="paulfantom@gmail.com"
GIT_USER="paulfantom"
git config user.email "${GIT_MAIL}"
git config user.name "${GIT_USER}"
GIT_URL=$(git config --get remote.origin.url)
GIT_URL=${GIT_URL#*//}

git add image.tar.gz Dockerfile
git commit -m "[ci skip] new image build for commit $TRAVIS_COMMIT"
git push "https://${GH_TOKEN}:@${GIT_URL}" || exit 0
