#!/bin/bash

source ./environment.sh

kapply() {
  if output=$(envsubst < "$@"); then
    printf '%s' "$output" | kubectl apply -f -
  fi
}

#kapply $CLUSTER_ROOT/networking/traefik/wildcard.txtp
kapply $CLUSTER_ROOT/rook-ceph/dashboard/ingress.txtp
kapply $CLUSTER_ROOT/networking/traefik/traefik-dashboard.txtp
kapply $CLUSTER_ROOT/kube-system/cilium/hubble-ingress.txtp
kapply $CLUSTER_ROOT/home/nextcloud/onlyoffice/onlyoffice.txtp
kapply $CLUSTER_ROOT/blockchain/sia/sia-public.txtp
kapply $CLUSTER_ROOT/blockchain/sia/sia-dashboard-ingress.txtp
kapply $CLUSTER_ROOT/home/thelounge/ingress.txtp
kapply $CLUSTER_ROOT/networking/vpn-server/wireguard-config.txtp
kapply $CLUSTER_ROOT/blockchain/bitcoin/bitcoin-svc.txtp
kapply $CLUSTER_ROOT/blockchain/monero/monero-svc.txtp

#kapply $CLUSTER_ROOT/access-mgmt/openldap/phpldapadmin.txtp
#kapply $REPO_ROOT/deployments/default/teslamate/teslamate-cert.txt