#!/bin/bash

source ./environment.sh

kapply() {
  if output=$(envsubst < "$@"); then
    printf '%s' "$output" | kubectl apply -f -
  fi
}

kapply $CLUSTER_ROOT/rook-ceph/dashboard/ingress.txtp
kapply $CLUSTER_ROOT/networking/traefik/traefik-dashboard.txtp
kapply $CLUSTER_ROOT/kube-system/cilium/hubble-ingress.txtp
kapply $CLUSTER_ROOT/home/nextcloud/onlyoffice/onlyoffice.txtp
kapply $CLUSTER_ROOT/backup/minio/minio-secret.txtp

#kapply $REPO_ROOT/deployments/default/teslamate/teslamate-cert.txt