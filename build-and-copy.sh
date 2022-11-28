#!/bin/bash

set -e

cd $(dirname "$0")

cd tech

jekyll clean && jekyll build

cd ..

rm -rf ../opcodesolutions.github.io/tech

cp -r tech/_site ../opcodesolutions.github.io/tech
