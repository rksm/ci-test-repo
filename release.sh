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

# merge the current branch into stable without conflict, i.e. we don't need to
# force push but need to do some merge dance...
git checkout $TARGET_REV

git merge --no-ff -s ours $RELEASE_BRANCH -m "new release"

# are we in a detached state? in this case we need an extra tag to merge the
# release branch
if [[ ! $(git symbolic-ref -q HEAD) ]]; then
    # back to the original branch and discard the merge commit
    WAS_DETACHED=1
    TARGET_REV="$TARGET_REV-$RELEASE_BRANCH"
    git tag $TARGET_REV
fi
git checkout $RELEASE_BRANCH
git merge $TARGET_REV

# publish!
git push origin $RELEASE_BRANCH

if [[ -n $WAS_DETACHED ]]; then
    # delete the extra tag
    git tag -d $TARGET_REV
fi
