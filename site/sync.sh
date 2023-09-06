#!/bin/bash

# Define the directory to search in
directory=~/Downloads

# Search for files starting with "AnimaPackage-React-" in the directory
file=$(find "$directory" -type f -name "AnimaPackage-React-*" | \
  xargs stat --format="%Y %n" | sort -nr | head -n 1 | cut -d' ' -f2-)

# Check if a file was found
if [ -n "$file" ]; then
  # Print the most recently edited file
  echo "Most recently edited file starting with 'AnimaPackage-React-':"
  echo "$file"
else
  echo "No matching files found."
  exit 1
fi

# Check if the directory is a Git repository and if it's dirty
if [ -n "$(git -C . status --porcelain)" ]; then
  echo "Git repository in $(pwd) is dirty. Aborting."
  exit 1
fi

unzip -o "$file" -d .
