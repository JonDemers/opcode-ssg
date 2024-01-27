#!/bin/bash

set -e

cd $(dirname "$0")

for file in $(grep -l -r 'last_modified_at: ' . | grep -v $(basename "$0")); do
  last_modified_at=$(git log --date=iso "$file"|grep Date|head -n1|awk '{print $2}')
  sed -r -i "s/^last_modified_at:.*/last_modified_at: $last_modified_at/" "$file"
done



bundle exec jekyll clean && bundle exec jekyll build

rm -rf ../opcodesolutions.github.io/*

for file in _site/feed.xml _site/feed/pages.xml; do
  sed -r -i 's|<published></published>||g' "$file"
  sed -r -i 's|<updated></updated>||g' "$file"
  xmllint --format "$file"  > "$file.new" && mv "$file.new" "$file"
done

cp -r _site/* ../opcodesolutions.github.io/

# We have some "<a href='...'" backlinks to this old image from old wordpress website that no longer exists.
# We'll just serve the same (duplicate) html content. We have "rel='canonical'" to the main page.
mkdir -p ../opcodesolutions.github.io/tech/wp-content/uploads/2014/11/2014-11-04-143434_714x503_scrot.png
cp _site/tech/solve-java-lang-outofmemoryerror-java-heap-space/* ../opcodesolutions.github.io/tech/wp-content/uploads/2014/11/2014-11-04-143434_714x503_scrot.png
