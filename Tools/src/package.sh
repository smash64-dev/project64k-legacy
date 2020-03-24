#!/bin/bash
# package.sh

cd $(git rev-parse --show-toplevel)
git archive --format=zip --output=project64k-legacy-release.zip HEAD
