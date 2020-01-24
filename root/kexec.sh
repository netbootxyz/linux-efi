#!/bin/bash

live_endpoint="https://github.com/netbootxyz"
kernel_url="${live_endpoint}/ubuntu-core-19.10/releases/download/19.10-055f9330/"

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="NETBOOT.XYZ"
TITLE="Ubuntu Live CDs"
MENU="Choose one of the following Live CDs:"

OPTIONS=("xfce" "Ubuntu 19.10 Eoan XFCE"
         "kde" "Ubuntu 19.10 Eoan KDE")

exec 3>&1;
CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 1>&3);
exec 3>&-;

clear
case $CHOICE in
  "xfce")
    squash_url="${live_endpoint}/ubuntu-squash/releases/download/862cad91-9437400f/filesystem.squashfs"
    ;;
  "kde")
    squash_url="${live_endpoint}/ubuntu-squash/releases/download/9854741e-b243fefb/filesystem.squashfs"
    ;;
  *)
    exit 0
    ;;
esac


# grab initrd/vmlinuz
wget ${kernel_url}vmlinuz
wget ${kernel_url}initrd

# load kexec
kexec -l vmlinuz \
--initrd=initrd \
--command-line="ip=dhcp boot=casper netboot=url url=${squash_url} initrd=initrd"
kexec -e
