#!/bin/bash

#Parts of this taken from billimek/k8s-gitops

REPO_ROOT=$(git rev-parse --show-toplevel)

kubectl create namespace flux



helm repo add fluxcd https://charts.fluxcd.io
helm repo add cilium https://helm.cilium.io/
helm repo update

echo "Installing Cilium"
helm -n kube-system -f "$REPO_ROOT"/kube-system/cilium/cilium-values.yaml upgrade --install cilium cilium/cilium

sleep 10

echo "installing fluxv2"
flux check --pre > /dev/null
FLUX_PRE=$?
if [ $FLUX_PRE != 0 ]; then 
  echo -e "flux prereqs not met:\n"
  flux check --pre
  exit 1
fi
if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN is not set! Check $REPO_ROOT/setup/.env"
  exit 1
fi
flux bootstrap github \
  --owner=sleepingshell \
  --repository=kube-gitops \
  --branch master \
  --personal

FLUX_INSTALLED=$?
if [ $FLUX_INSTALLED != 0 ]; then 
  echo -e "flux did not install correctly, aborting!"
  exit 1
fi

FLUX_READY=1
  while [ $FLUX_READY != 0 ]; do
    echo "waiting for flux pod to be fully ready..."
    kubectl -n flux wait --for condition=available deployment/flux
    FLUX_READY="$?"
    sleep 5
  done
echo "Calling add-repo..."

#FLUX_KEY=$(kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2)
#"$REPO_ROOT"/setup/add-repo-key.sh "$FLUX_KEY"