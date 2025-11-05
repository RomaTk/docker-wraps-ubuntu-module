#!/bin/bash

function main {
    local parent_image_name="$1"
    local image_name="$2"

    local image_name_without_tag
    local parent_image_id
    local image_id
    local layers
    local last_layer_of_parent
    local first_layer_of_image

    local exit_code
    local local_tags

    parent_image_id=$(getImageId "$parent_image_name")
    [ $? -ne 0 ] && exit 1

    layers=$(getLayersOfSomeImage "$parent_image_id")
    [ $? -ne 0 ] && exit 1

    last_layer_of_parent=$(echo "$layers" | jq -r '.[-1]')
    [ $? -ne 0 ] && exit 1

    image_name_without_tag=$(getImageNameWithoutTag "$image_name")
    [ $? -ne 0 ] && exit 1

    local_tags=$(docker images "$image_name_without_tag" --format "{{.Tag}}")
    [ $? -ne 0 ] && exit 1

    for tag in $local_tags; do
        image_id=$(getImageId "${image_name_without_tag}:${tag}")
        [ $? -ne 0 ] && exit 1

        layers=$(getLayersOfSomeImage "$image_id")
        [ $? -ne 0 ] && exit 1

        first_layer_of_image=$(echo "$layers" | jq -r '.[0]')
        [ $? -ne 0 ] && exit 1

        if [[ "$first_layer_of_image" == "$last_layer_of_parent" ]]; then
            echo ""
            exit 0
        fi

    done

    echo "--no-cache"

    exit 0
}

function getImageNameWithoutTag {
    local full_image_name="$1"
    local image_name_without_tag

    image_name_without_tag="${full_image_name%%:*}"
    [ $? -ne 0 ] && exit 1

    echo "$image_name_without_tag"

    exit 0
}

function getImageId {
    local image_name="$1"
    local image_id

    image_id=$(docker images --filter "reference=${image_name}" --format "{{.ID}}" --no-trunc)
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo "Error: Failed to retrieve image ID for '$image_name'" >&2
        exit 1
    fi

    if [ -z "$image_id" ]; then
        echo "Error: No image found with name '$image_name'" >&2
        exit 1
    fi

    echo "$image_id"

    exit 0
}

function getLayersOfSomeImage {
    local image_id="$1"
    local layers

    layers=$(docker inspect -f json "$image_id" 2>/dev/null | jq -r '.[0].RootFS.Layers')
    [ $? -ne 0 ] && exit 1

    echo "$layers"

    exit 0
}