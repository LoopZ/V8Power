#!/bin/sh

git add *.bat SOURCE/* DEMOS/* EXAMPLES/*
git add *.md LICENSE
git add *.txt *.sh
git commit -m "$*"
git push