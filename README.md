# opcode-ssg

## Setup

Install Jekyll prerequisites, see [https://jekyllrb.com/docs/installation/ubuntu/](https://jekyllrb.com/docs/installation/ubuntu/)

Clone the 2 repos side by side

```bash
git clone git@github.com:JonDemers/opcode-ssg.git
git clone git@github.com:JonDemers/opcodesolutions.github.io.git
```

Work in opcode-ssg

```bash
cd opcode-ssg
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


