#!/usr/bin/env bash
OLDCWD=$(pwd)

cd /root/img/
curl -O https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

cd $OLDCWD
