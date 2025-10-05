#!/bin/bash

function main {
    local version="$1"
    local path_to_docker="$2"
    local file_path
    local image_info
    local should_be_image_name
    local id_1
    local id_2
    local is_to_create_image="false"
    local is_ubuntu_image_was_loaded_by_this_script="false"

    if [ -z "$version" ]; then
        version="latest"
    fi

    if [ -z "$path_to_docker" ]; then
        echo "Path to docker is required" >&2
        exit 1
    fi

    file_path="$path_to_docker/get-some-version/versions/$version.tar"

    image_info=$(docker image inspect "ubuntu:$version" 2> /dev/null)
    if [[ "$image_info" != "[]" && $? -ne 0 ]]; then
        echo "Problem inspecting docker image" >&2
        exit 1
    fi

    if [[ "$image_info" == "[]" ]]; then

        if [[ -f "$file_path" ]]; then
            docker load -i "$file_path"
            if [ $? -ne 0 ]; then
                echo "Failed to load docker image from $file_path" >&2
                exit 1
            fi
        else
            docker pull "ubuntu:$version"
            if [ $? -ne 0 ]; then
                echo "Failed to pull docker image ubuntu:$version" >&2
                exit 1
            fi
        fi

        is_ubuntu_image_was_loaded_by_this_script="true"
        
    fi

    if [[ ! -f "$file_path" ]]; then
        docker save -o "$file_path" "ubuntu:$version"
        if [ $? -ne 0 ]; then
            echo "Failed to save docker image to $file_path" >&2
            exit 1
        fi
    fi

    should_be_image_name=$(./envs.sh get name image ubuntu-get-some-version)
    if [ $? -ne 0 ]; then
        echo "Failed to get image name from envs.sh" >&2
        exit 1
    fi

    image_info=$(docker image inspect "$should_be_image_name" 2> /dev/null)
    if [[ "$image_info" != "[]" && $? -ne 0 ]]; then
        echo "Problem inspecting docker image" >&2
        exit 1
    fi

    if [[ "$image_info" != "[]" ]]; then
        id_1=$(docker image inspect --format='{{.Id}}' "ubuntu:$version" 2> /dev/null)
        [ $? -ne 0 ] && exit 1
        id_2=$(docker image inspect --format='{{.Id}}' "$should_be_image_name" 2> /dev/null)
        [ $? -ne 0 ] && exit 1

        if [[ "$id_1" != "$id_2" ]]; then
            docker rmi -f "$should_be_image_name"
            if [ $? -ne 0 ]; then
                echo "Failed to remove existing docker image $should_be_image_name" >&2
                exit 1
            fi

            is_to_create_image="true"
        fi
    else
        is_to_create_image="true"
    fi

    if [[ "$is_to_create_image" == "true" ]]; then
        docker tag "ubuntu:$version" "$should_be_image_name"
        if [ $? -ne 0 ]; then
            echo "Failed to tag docker image" >&2
            exit 1
        fi
    fi
    

    if [[ "$is_ubuntu_image_was_loaded_by_this_script" == "true" ]]; then
        docker rmi -f "ubuntu:$version"
        if [ $? -ne 0 ]; then
            echo "Failed to remove docker image ubuntu:$version" >&2
            exit 1
        fi
    fi

    exit 0

}