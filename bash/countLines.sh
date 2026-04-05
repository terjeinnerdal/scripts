#! /usr/bin/bash
FILENAME="$1"
echo "$FILENAME"
COUNTER=0
while IFS= read -r line; do
    echo "$COUNTER": "$line"
    ((COUNTER++))
done < "$FILENAME"
