#!/bin/bash
hexo clean
hexo generate 
git add .
git add ../docs

# ===== If there is not a new entry
# git reset ../docs/index.html
# 
# ===== If there is a new entry
# change the about w/o the last '/'
# change the links of the list to add 'web-security-class/' before the path.
