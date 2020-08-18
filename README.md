# Linux-EFI

Contains build logic for a microdistro with an embedded initramfs based on Alpine Linux (https://alpinelinux.org/).

## Build instructions

On a Docker enabled host run: 
```
git clone https://github.com/netbootxyz/linux-efi.git
cd linux-efi
docker build --build-arg THREADS=$(grep processor /proc/cpuinfo | wc -l) -t linux-efi .
docker run --rm -it -v $(pwd):/buildout linux-efi /dump.sh
```

The bootable kernel will be in your working directory named `vmlinuz`
