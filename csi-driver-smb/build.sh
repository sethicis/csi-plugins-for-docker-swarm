#!/bin/bash

USAGE="Usage: ./build.sh <Docker Hub Organization> <SMB CSI version>"

if [ "$1" == "--help" ] || [ "$#" -lt "2" ]; then
	echo $USAGE
	exit 0
fi

ORG=$1
VERSION=$2

rm -rf rootfs
docker plugin disable csi-smb:latest
docker plugin rm csi-smb:latest
docker plugin disable $ORG/swarm-csi-smb:v$VERSION
docker plugin rm $ORG/swarm-csi-smb:v$VERSION
docker rm -vf rootfsimage

docker create --name rootfsimage registry.k8s.io/sig-storage/smbplugin:v$VERSION
mkdir -p rootfs
docker export rootfsimage | tar -x -C rootfs
docker rm -vf rootfsimage
cp entrypoint.sh rootfs/

docker plugin create $ORG/swarm-csi-smb:v$VERSION .
docker plugin enable $ORG/swarm-csi-smb:v$VERSION
docker plugin push $ORG/swarm-csi-smb:v$VERSION
docker plugin disable $ORG/swarm-csi-smb:v$VERSION
docker plugin rm $ORG/swarm-csi-smb:v$VERSION
docker plugin install --alias csi-smb --grant-all-permissions $ORG/swarm-csi-smb:v$VERSION
