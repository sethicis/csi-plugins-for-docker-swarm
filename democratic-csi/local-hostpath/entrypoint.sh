#!/bin/sh

bin/democratic-csi \
  --driver-config-file=config/local-hostpath.yaml \
  --log-level=debug \
  --server-socket=/run/docker/plugins/csi-synology-iscsi.sock \
  --csi-version=1.8.2 \
  --csi-name=csi-synology-iscsi
