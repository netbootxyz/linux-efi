#!/bin/sh
dateVAR=$(date +%s)
docker build --build-arg THREADS=$(grep processor /proc/cpuinfo | wc -l) -t linux-efi:$dateVAR .
docker run --rm -v $(pwd):/buildout linux-efi:$dateVAR /dump.sh
