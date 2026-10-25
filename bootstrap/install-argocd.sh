#!/usr/bin/env bash
# ==============================================================================
# Enterprise ArgoCD Installation & Bootstrap on AKS
# Author: Deenanath Yadav (Senior Azure DevOps Engineer)
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo " Starting ArgoCD GitOps Bootstrap on AKS"
echo "=========================================================="

NAMESPACE="argocd"
ARGOCD_VERSION="7.7.7" # Helm Chart version for ArgoCD v2.13+

echo "[1/5] Ensuring namespace '$NAMESPACE' exists..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "[2/5] Adding Argo Helm repository..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

echo "[3/5] Installing/Upgrading ArgoCD via Helm..."
helm upgrade --install argocd argo/argo-cd \
  --namespace "$NAMESPACE" \
  --version "$ARGOCD_VERSION" \
  -f bootstrap/argocd-helm-values.yaml \
  --wait

echo "[4/5] Applying ArgoCD Ingress route..."
kubectl apply -f bootstrap/ingress-argocd.yaml

echo "[5/5] Bootstrapping Root App-of-Apps..."
kubectl apply -f apps/root-app-of-apps.yaml

echo "=========================================================="
echo " ArgoCD GitOps Bootstrap Completed Successfully!"
echo " Retrieving Initial Admin Password:"
echo "=========================================================="
kubectl -n "$NAMESPACE" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""
echo "=========================================================="
