#!/bin/bash

function cleanFolder {
    local target_dir="$1"
    local current_dir="$(pwd)"

    cd "$target_dir"
    [ $? -ne 0 ] && exit 1

    for item in * .*; do
        # The glob pattern '.*' matches '.', '..', and '.gitkeep'. We must skip them.
        if [[ "$item" == "." || "$item" == ".." || "$item" == ".gitkeep" ]]; then
        continue # Skip to the next item in the loop.
        fi

        # Remove the item recursively and forcefully.
        rm -rf "$item"
        [ $? -ne 0 ] && exit 1
    done

    cd "$current_dir"
    [ $? -ne 0 ] && exit 1

    exit 0
}

function main {
    local path_to_docker="$1"

    if [ -z "$path_to_docker" ]; then
        echo "Path to docker is required" >&2
        exit 1
    fi

    (cleanFolder "$path_to_docker/get-some-version/versions")
    if [ $? -ne 0 ]; then
        echo "Failed to clean versions folder" >&2
        exit 1
    fi

    exit 0
}