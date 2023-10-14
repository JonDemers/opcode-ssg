#!/bin/bash

set -e

cd $(dirname "$0")

bundle exec jekyll clean && bundle exec jekyll build

rm -rf ../opcodesolutions.github.io/*

cp -r _site/* ../opcodesolutions.github.io/

rm -rf /mnt/c/Users/demer/git/opcodesolutions.github.io-v2

cp -r _site /mnt/c/Users/demer/git/opcodesolutions.github.io-v2
