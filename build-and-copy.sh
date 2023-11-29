#!/bin/bash

set -e

cd $(dirname "$0")

bundle exec jekyll clean && bundle exec jekyll build

rm -rf ../opcodesolutions.github.io/*

cp -r _site/* ../opcodesolutions.github.io/

# We have some "<a href='...'" backlinks to this old image from old wordpress website that no longer exists.
# We'll just serve the same (duplicate) html content. We have "rel='canonical'" to the main page.
mkdir -p ../opcodesolutions.github.io/tech/wp-content/uploads/2014/11/2014-11-04-143434_714x503_scrot.png
cp _site/tech/solve-java-lang-outofmemoryerror-java-heap-space/* ../opcodesolutions.github.io/tech/wp-content/uploads/2014/11/2014-11-04-143434_714x503_scrot.png
