#!/bin/bash

set -e

cd $(dirname "$0")

bundle exec jekyll clean && bundle exec jekyll build

rm -rf ../opcodesolutions.github.io/tech

cp -r _site ../opcodesolutions.github.io/tech
