#! /bin/sh

set -e

if [ ! -d "lib" ];
then
    echo "===> syncing dependencies"
    smlpkg sync
fi

echo "===> building container"
docker build . -t hateoas
