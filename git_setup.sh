#!/bin/bash

echo "Type in the user name that you'll like to see on your commits: "
read full_name

echo "Type in your email address used for your GitHub account: "
read email

git config --global user.email "$email"
git config --global user.name "$full_name"

echo "GitHub credentials created. ✅"
