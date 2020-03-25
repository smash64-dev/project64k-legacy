#!/bin/bash
# package.sh

echo "Creating package, please wait..."

cd "$(git rev-parse --show-toplevel)"
git archive --format=zip --output=Release/project64k-legacy-release.zip HEAD

cd "Release/"
sha1sum project64k-legacy-release.zip > sha1sum.txt