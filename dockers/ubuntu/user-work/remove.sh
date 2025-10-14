#!/bin/bash

function mainInteractive {
    local username

    local last_action

    echo "Please enter the name of user to remove:"
    read username
    echo "Removing user: $username"

    last_action=$(main "$username")
    if [ $? -ne 0 ]; then
        echo "Error within main: $last_action" >&2
        exit 1
    fi

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

    output=$(flock -x "$dir/flock-file.lock" -c "
        bash -c '
            source \"$current_file\" && mainWithoutFlock \"$username\"
            exit \$?
        '")
    if [ $? -ne 0 ]; then
        echo "Problem occurred within mainWithoutFlock: $output" >&2
        exit 1
    fi

    exit 0
}

function mainWithoutFlock {
    local username="$1"

    local is_user_exists
    local last_action
    local current_file="${BASH_SOURCE[0]}"
    local dir

    if [ -z "$username" ]; then
        echo "Username must be provided as an argument." >&2
        exit 1
    fi

    dir=$(dirname "$current_file")
    if [ $? -ne 0 ]; then
        echo "Cannot get directory name of the current file: $current_file" >&2
        exit 1
    fi

    is_user_exists=$(
        source "$dir/is-user-exists.sh"
        if [ $? -ne 0 ]; then
            echo "Cannot source is-user-exists.sh" >&2
            exit 1
        fi

        mainWithoutFlock "$username"
    )
    if [ $? -ne 0 ]; then
        echo "Error within is-user-exists.sh: $is_user_exists" >&2
        exit 1
    fi

    if [[ "$is_user_exists" == "true" ]]; then
        last_action=$(userdel -r "$username")
        if [ $? -ne 0 ]; then
            echo "Error within userdel: $last_action" >&2
            exit 1
        fi
    fi

    exit 0
}