#!/usr/bin/env bash

need() {
    which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

need "kubeseal"

source ./environment.sh

# Create secrets file
truncate -s 0 "${GENERATED_SECRETS}"

#
# Helm Secrets
#

# Generate Helm Secrets
txt=$(find "${REPO_ROOT}" -type f -name "*.txt")

if [[ ( -n $txt ) ]];
then
    # shellcheck disable=SC2129
    printf "%s\n%s\n%s\n" "#" "# Auto-generated helm secrets -- DO NOT EDIT." "#" >> "${GENERATED_SECRETS}"

    for file in "${CLUSTER_ROOT}"/**/*.txt; do
        # Get the path and basename of the txt file
        # e.g. "deployments/default/pihole/pihole"
        secret_path="$(dirname "$file")/$(basename -s .txt "$file")"
        # Get the filename without extension
        # e.g. "pihole"
        secret_name=$(basename "${secret_path}")
        # Get the relative path of deployment
        deployment=${file#"${CLUSTER_ROOT}"}
        # Get the namespace (based on folder path of manifest)
        namespace=$(echo "${deployment}" | awk -F/ '{print $2}')
        echo "[*] Generating helm secret '${secret_name}' in namespace '${namespace}'..."
        # Create secret
        envsubst <"$file" |
            kubectl -n "${namespace}" create secret generic "${secret_name}-helm-values" \
                --from-file=/dev/stdin --dry-run=client -o json |
            kubeseal --format=yaml --cert="${PUB_CERT}" \
                >>"${GENERATED_SECRETS}"
        echo "---" >>"${GENERATED_SECRETS}"
    done

    # Replace stdin with values.yaml
    sed -i 's/stdin\:/values.yaml\:/g' "${GENERATED_SECRETS}"
fi

#
# Generic Secrets
#

# shellcheck disable=SC2129
printf "%s\n%s\n%s\n" "#" "# Auto-generated generic secrets -- DO NOT EDIT." "#" >> "${GENERATED_SECRETS}"

# Remove empty new-lines
sed -i '/^[[:space:]]*$/d' "${GENERATED_SECRETS}"

# Validate Yaml
if ! yq . "${GENERATED_SECRETS}" >/dev/null 2>&1; then
    echo "Errors in YAML"
    exit 1
fi

git add $GENERATED_SECRETS
git commit -m 'Auto-generated secrets'
git push origin

exit 0