#!/bin/bash

function mainInteractive {
    local username
    local password

    local last_action

    echo "Please enter the name of user:"
    read username
    echo "Creating user: $username"
    echo "Please enter password:"
    read -s password
    echo "User $username created with the provided password."

    last_action=$(main "$username" "$password")
    if [ $? -ne 0 ]; then
        echo "Error within main: $last_action" >&2
        exit 1
    fi

    exit 0
}

function main {
    local username="$1"
    local password="$2"

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
            source \"$current_file\" && mainWithoutFlock \"$username\" \"$password\"
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
    local password="$2"

    local is_user_exists
    local last_action
    local current_file="${BASH_SOURCE[0]}"
    local dir

    if [ -z "$username" ] || [ -z "$password" ]; then
        echo "Username and password must be provided as arguments." >&2
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

    if [[ "$is_user_exists" == "false" ]]; then
        last_action=$(useradd -m "$username")
        if [ $? -ne 0 ]; then
            echo "Error within useradd: $last_action" >&2
            exit 1
        fi
    fi

    last_action=$(changeUserPassword "$username" "$password")
    if [ $? -ne 0 ]; then
        echo "Error within changeUserPassword: $last_action" >&2
        exit 1
    fi

    exit 0
}

function changeUserPassword {
    local username="$1"
    local password="$2"

    local last_action

    last_action=$(echo "$username:$password" | chpasswd)
    if [ $? -ne 0 ]; then
        echo "Error within chpasswd: $last_action" >&2
        exit 1
    fi

    exit 0
}