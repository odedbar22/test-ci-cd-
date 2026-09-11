#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Usage: deploy-local.sh IMAGE}"
REPOSITORY="ghcr.io/odedbar22/cicd-lab"

if [[ "$IMAGE" != "$REPOSITORY":* ]]; then
    echo "Expected image from $REPOSITORY" >&2
    exit 1
fi

TAG="${IMAGE#"$REPOSITORY":}"

echo "Deploying registry image: $IMAGE"

helm lint ./helm/cicd-web

helm upgrade --install cicd-web ./helm/cicd-web \
    --kube-context minikube \
    --namespace cicd-lab \
    --create-namespace \
    --set-string image.repository="$REPOSITORY" \
    --set-string image.tag="$TAG" \
    --set-string image.pullPolicy=Always \
    --wait \
    --timeout 180s

kubectl --context minikube \
    get deployment,pods -n cicd-lab
