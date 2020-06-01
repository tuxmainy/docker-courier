#!/bin/bash

base=`dirname $0`
base=`readlink -f "$base"`
docker run -v "$base/conftest:/conf" --rm -it "$1" "$2"

