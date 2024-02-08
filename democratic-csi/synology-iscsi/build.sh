#!/bin/bash

USAGE="Usage: ./build.sh <Docker Hub Organization> <Democratic CSI version>"

if [ "$1" == "--help" ] || [ "$#" -lt "2" ]; then
	echo $USAGE
	exit 0
fi

ORG=$1
VERSION=$2

rm -rf rootfs
docker plugin disable csi-iscsi-path:latest
docker plugin rm csi-iscsi-path:latest
docker plugin disable $ORG/swarm-csi-iscsi-path:v$VERSION
docker plugin rm $ORG/swarm-csi-iscsi-path:v$VERSION
docker rm -vf iscsifsimage

docker create --name iscsifsimage docker.io/democraticcsi/democratic-csi:v$VERSION
mkdir -p iscsifs
docker export iscsifsimage | tar -x -C iscsifs
docker rm -vf iscsifsimage
mkdir -p iscsifs/home/csi/app/config
cp entrypoint.sh iscsifs/home/csi/app/
cp synology-iscsi.yaml iscsifs/home/csi/app/config/

docker plugin create $ORG/swarm-csi-iscsi-path:v$VERSION .
docker plugin enable $ORG/swarm-csi-iscsi-path:v$VERSION
docker plugin push $ORG/swarm-csi-iscsi-path:v$VERSION
docker plugin disable $ORG/swarm-csi-iscsi-path:v$VERSION
docker plugin rm $ORG/swarm-csi-iscsi-path:v$VERSION
docker plugin install --alias csi-iscsi-path --grant-all-permissions $ORG/swarm-csi-iscsi-path:v$VERSION
