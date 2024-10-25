#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [[ $# -eq 0 ]]; then
    echo "pass branch/tag/rev to release as argument, e.g. ./release.sh v1.0.5"
    exit 1
fi

IS_CLEAN=$(git status --porcelain -uno)
if [[ ! -z $IS_CLEAN ]]; then
        echo "Please clean your working directory before proceding"
        exit 1
fi
# checkout master branch and merge the git rev passed in as first argument
TARGET_REV=$1
RELEASE_BRANCH=${2:-release}
WAS_DETACHED=

set -x

# make sure stable branch points to origin
git fetch origin
git checkout $RELEASE_BRANCH || git checkout -b $RELEASE_BRANCH origin/$RELEASE_BRANCH
git reset --hard origin/$RELEASE_BRANCH

git merge --no-ff --allow-unrelated-histories -s theirs $TARGET_REV -m "Merge $TARGET_REV into $RELEASE_BRANCH"
# git push origin $RELEASE_BRANCH
