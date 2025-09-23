# opcode-ssg

## Setup

Install rbenv and use ruby version 3.2.6

```bash
sudo apt install rbenv
eval "$(rbenv init -)"
rbenv install 3.2.6
rbenv local 3.2.6
rbenv rehash
ruby --version
gem install jekyll bundler
bundle install
```

Clone the 2 repos side by side

```bash
git clone git@github.com:JonDemers/opcode-ssg.git
git clone git@github.com:JonDemers/opcodesolutions.github.io.git
```

Work in opcode-ssg

```bash
cd opcode-ssg
eval "$(rbenv init -)"
```

## Create content and serve locally

```bash
bundle exec jekyll clean && bundle exec jekyll serve
```

Then open browser at [http://localhost:4000/](http://localhost:4000/)

## Deploy content

```bash
./build-and-copy.sh

# Assess changes, commit and push to deploy
cd ../opcodesolutions.github.io
git diff
git add .
git commit -m 'New content'
git push origin HEAD
```


