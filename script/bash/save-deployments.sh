#!/bin/bash

source_folder="$PWD/deployments/tmp"
destination_root="$PWD/deployments"

# Find all subfolders containing JSON files and process them
find "$source_folder" -type f -name "*.json" | while read -r json_file; do
    subfolder=$(dirname "$json_file")
    subfolder_name=$(basename "$subfolder")
    destination_folder="$destination_root/$subfolder_name"

    # Find the latest JSON file in the subfolder
    latest_file=$(ls -t "$subfolder"/*.json | head -n 1)

    if [ -n "$latest_file" ]; then
        # Copy the latest JSON file to the destination folder to keep track of the latest deployment
        cp "$latest_file" "$destination_root/$subfolder_name.json"
    else
        echo "No matching files found in $subfolder_name."
    fi
done