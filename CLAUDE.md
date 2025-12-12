# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Guiding Principle

KISS: Keep it stupid simple. Simple system design consistently beats complex ones on all aspects.

- Fewer lines of code is better
- Fewer comments is better (code should be self-explanatory)
- Clever hacks are OK if they reduce complexity
- Avoid abstractions until absolutely necessary
- Don't add features "just in case"
- Prefer deleting code over adding code
- If it works and it's simple, it's good enough

## Project Overview

This is a Jekyll-based static site generator for OpCode Solutions (opcodesolutions.com). It uses a customized version of the Minima theme and generates a bilingual (English/French) website.

## Common Commands

```bash
# Serve locally for development
bundle exec jekyll clean && bundle exec jekyll serve
# Then open http://localhost:4000/

# Build and deploy (updates sibling opcodesolutions.github.io repo)
./build-and-copy.sh
```

## Architecture

### Content Structure
- `en/` - English pages (solutions, pricing, demo, contact, SaaS products)
- `fr/` - French pages (mirrored structure with French URLs)
- `_posts/` - Tech blog posts (in `tech/` section)
- `tech/` - Tech blog index page

### Layout System
- `_layouts/base.html` - Root layout with head, header, content, footer
- `_layouts/home.html` - Blog listing page
- `_layouts/page.html`, `page-md.html`, `page-jumbotron.html` - Page variants
- `_includes/` - Reusable components (header, footer, head, contact forms)

### Bilingual Configuration
The site uses a custom `site_meta.lang` structure in `_config.yml` for i18n strings. Pages specify their language via `lang: en` or `lang: fr` in front matter.

### Deployment Model
This repo generates static files that are copied to a sibling `opcodesolutions.github.io` repository for GitHub Pages hosting. The `build-and-copy.sh` script:
1. Updates `last_modified_at` dates from git history
2. Builds the Jekyll site
3. Cleans and formats XML feeds
4. Copies output to the deployment repo
