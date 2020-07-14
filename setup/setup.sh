#!/bin/bash

#Parts of this taken from billimek/k8s-gitops

REPO_ROOT=$(git rev-parse --show-toplevel)

kubectl create namespace flux

echo "Installing flux"

helm repo add fluxcd https://charts.fluxcd.io
helm repo update
helm upgrade --install flux --values "$REPO_ROOT"/flux/flux-values.yaml --namespace flux fluxcd/flux
helm upgrade --install helm-operator --values "$REPO_ROOT"/flux/flux-helm-operator-values.yaml --namespace flux fluxcd/helm-operator

FLUX_READY=1
  while [ $FLUX_READY != 0 ]; do
    echo "waiting for flux pod to be fully ready..."
    kubectl -n flux wait --for condition=available deployment/flux
    FLUX_READY="$?"
    sleep 5
  done
echo "Calling add-repo..."

FLUX_KEY=$(kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2)
"$REPO_ROOT"/setup/add-repo-key.sh "$FLUX_KEY"