#!/bin/bash

set -e

cd $(dirname "$0")/tech

bundle exec jekyll clean && bundle exec jekyll build

cd ..

rm -rf ../opcodesolutions.github.io/tech

cp -r tech/_site ../opcodesolutions.github.io/tech
