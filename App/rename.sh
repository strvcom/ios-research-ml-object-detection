#!/bin/bash

original=FruitDetector

find . -type f -not -path "./.git*" -not -path "./fastlane*" -not -path "./Pods*" -not -path ".rename.sh" -print0 | while IFS= read -r -d '' file; do
    sed "s/$original/$1/g" "$file" 2> /dev/null 1> "$file.tmp"
    rm "$file"
    mv "$file.tmp" "$file"
done

find . -type d -name "*$original*" -print0 | while IFS= read -r -d '' file; do
    new=`echo "$file" | sed "s/$original/$1/g"`
    mv "$file" "$new"
done

find . -type f -name "*$original*" -print0 | while IFS= read -r -d '' file; do
    new=`echo $file | sed "s/$original/$1/g"`
    mv "$file" "$new"
done
