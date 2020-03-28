#!/bin/bash

cd $(cd "$( dirname "$0" )" && pwd)

if [ -z "$1" ]; then
    PS_VERSIONS_FILE="tags.txt";
else
    PS_VERSIONS_FILE="$1";
fi

generate_image()
{
    echo "Generate Dockerfile for PHP $version"

    local version=$1
    local folder="${version}";
    local exec="apache2-foreground";

    if [[ $version = *"fpm"* ]]; then
      exec='php-fpm'
    fi


    mkdir -p images/$folder/

    sed '
            s/{PHP_TAG}/'"${version}"'/
        ' Dockerfile.model > images/$folder/Dockerfile

    cp -R config_files/ images/$folder/
    sed '
            s/{PHP_CMD}/'"${exec}"'/
        ' config_files/docker_run.sh > images/$folder/config_files/docker_run.sh
}


# Generate base images for PHP tags
echo "Reading tags in ${PS_VERSIONS_FILE} ..."
while read version; do
    generate_image $version
done < $PS_VERSIONS_FILE
