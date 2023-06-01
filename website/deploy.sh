#!/bin/bash
hexo clean
hexo generate 
git add .
git add ../docs
git reset ../docs/index.html
