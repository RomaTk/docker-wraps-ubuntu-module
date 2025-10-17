#!/bin/bash

function mainInteractive {
    local username

    local last_action

    echo "Please enter the name of user to check:"
    read username
    echo "Checking if user exists: $username"

    last_action=$(main "$username")
    if [ $? -ne 0 ]; then
        echo "Error within main: $last_action" >&2
        exit 1
    fi

    echo "$last_action"
    exit 0
}

function main {
    local username="$1"

    local current_file="${BASH_SOURCE[0]}"
    local output
    local dir

    dir=$(dirname "$current_file")
    if [ $? -ne 0 ]; then
        echo "Cannot get directory name of the current file: $current_file" >&2
        exit 1
    fi

    output=$(flock -s "$dir/flock-file.lock" -c "
        bash -c '
            source \"$current_file\" && mainWithoutFlock \"$username\"
            exit \$?
        '")
    if [ $? -ne 0 ]; then
        echo "Problem occurred within mainWithoutFlock: $output" >&2
        exit 1
    fi
    echo "$output"

    exit 0
}

function mainWithoutFlock {
    local username="$1"

    local is_user_exists
    local exit_code

    if [ -z "$username" ]; then
        echo "Username must be provided as an argument." >&2
        exit 1
    fi

    is_user_exists=$(LANG=C id "$username" 2>&1)
    exit_code=$?

    if echo "$is_user_exists" | grep -q "no such user"; then
        echo "false"
    elif [ $exit_code -eq 0 ]; then
        echo "true"
    else
        echo "Error checking user existence: $is_user_exists" >&2
        exit 1
    fi

    exit 0
}