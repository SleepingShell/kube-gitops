#!/bin/bash

#Parts of this taken from billimek/k8s-gitops

REPO_ROOT=$(git rev-parse --show-toplevel)

kubectl create namespace flux

echo "Installing flux"

helm repo add fluxcd https://charts.fluxcd.io
helm upgrade --install flux --values "$REPO_ROOT"/flux/flux-values.yaml --namespace flux fluxcd/flux

sleep 15
echo "Calling add-repo..."

FLUX_KEY=$(kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2)
"$REPO_ROOT"/setup/add-repo-key.sh "$FLUX_KEY"
