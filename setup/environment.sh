#!/usr/bin/env bash
shopt -s globstar

export REPO_ROOT=$(git rev-parse --show-toplevel)
export CLUSTER_ROOT="${REPO_ROOT}/cluster"
export PUB_CERT="${REPO_ROOT}/setup/pub-cert.pem"
export SECRETS_ENV="${REPO_ROOT}/setup/.env"
export IP_ENV="${REPO_ROOT}/setup/.ip-env"
export GENERATED_SECRETS="${CLUSTER_ROOT}/zz_generated_secrets.yaml"

# Ensure these cli utils exist
command -v kubectl >/dev/null 2>&1 || {
    echo >&2 "kubectl is not installed. Aborting."
    exit 1
}
command -v envsubst >/dev/null 2>&1 || {
    echo >&2 "envsubst is not installed. Aborting."
    exit 1
}
command -v kubeseal >/dev/null 2>&1 || {
    echo >&2 "kubeseal is not installed. Aborting."
    exit 1
}
command -v yq >/dev/null 2>&1 || {
    echo >&2 "yq is not installed. Aborting."
    exit 1
}

# Check secrets env file exists
[ -f "${SECRETS_ENV}" ] || {
    echo >&2 "Secret enviroment file doesn't exist. Aborting."
    exit 1
}

#TODO: Enable this feature, will use git-crypt to store env encrypted in git
# Check secrets env file is text (git-crypt has decrypted it)
#file "${SECRETS_ENV}" | grep "ASCII text" >/dev/null 2>&1 || {
#    echo >&2 "Secret enviroment file isn't a text file. Aborting."
#    exit 1
#}

# Export environment variables
set -a
. "${SECRETS_ENV}"
. "${IP_ENV}"
set +a

# Check for environment variables
[ -n "${DOMAIN}" ] || {
    echo >&2 "Environment variables are not set. Aborting."
    exit 1
}
