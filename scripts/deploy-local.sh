#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Usage: deploy-local.sh IMAGE}"
TAG="${IMAGE#cicd-lab:}"

if [[ "$IMAGE" != cicd-lab:* ]]; then
    echo "Expected an image tagged cicd-lab:TAG" >&2
    exit 1
fi

echo "Deploying tested image: $IMAGE"

minikube image load "$IMAGE"

helm lint ./helm/cicd-web

helm upgrade --install cicd-web ./helm/cicd-web \
    --kube-context minikube \
    --namespace cicd-lab \
    --create-namespace \
    --set-string image.repository=cicd-lab \
    --set-string image.tag="$TAG" \
    --set-string image.pullPolicy=Never \
    --wait \
    --timeout 180s

kubectl --context minikube \
    get deployment,pods -n cicd-lab
