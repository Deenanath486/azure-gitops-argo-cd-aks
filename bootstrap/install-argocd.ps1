<#
.SYNOPSIS
    Automates ArgoCD Bootstrap on Azure Kubernetes Service (AKS).
.DESCRIPTION
    Creates the argocd namespace, installs ArgoCD HA Helm Chart, configures ingress,
    and applies the master root app-of-apps.
.NOTES
    Author: Deenanath Yadav (Senior Azure DevOps Engineer)
#>

[CmdletBinding()]
param(
    [string]$Namespace = "argocd",
    [string]$ChartVersion = "7.7.7"
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [ArgoCD Bootstrap] Initiating AKS GitOps Setup" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Create Namespace
Write-Host "[1/5] Ensuring namespace '$Namespace' exists..." -ForegroundColor Yellow
kubectl create namespace $Namespace --dry-run=client -o yaml | kubectl apply -f -

# 2. Add Helm Repo
Write-Host "[2/5] Adding Argo Helm repository..." -ForegroundColor Yellow
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# 3. Helm Upgrade/Install
Write-Host "[3/5] Installing ArgoCD High-Availability Helm Chart..." -ForegroundColor Yellow
helm upgrade --install argocd argo/argo-cd `
    --namespace $Namespace `
    --version $ChartVersion `
    -f bootstrap/argocd-helm-values.yaml `
    --wait

# 4. Ingress Route
Write-Host "[4/5] Applying ArgoCD Ingress route..." -ForegroundColor Yellow
kubectl apply -f bootstrap/ingress-argocd.yaml

# 5. Root App of Apps
Write-Host "[5/5] Deploying Root App-of-Apps..." -ForegroundColor Yellow
kubectl apply -f apps/root-app-of-apps.yaml

Write-Host "==========================================================" -ForegroundColor Green
Write-Host " [ArgoCD Bootstrap] Setup Completed Successfully!" -ForegroundColor Green
Write-Host " Retrieving initial admin password..." -ForegroundColor Green
$encoded = kubectl -n $Namespace get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
if ($encoded) {
    $bytes = [Convert]::FromBase64String($encoded)
    $password = [System.Text.Encoding]::UTF8.GetString($bytes)
    Write-Host " ArgoCD Admin Password: $password" -ForegroundColor Magenta
}
Write-Host "==========================================================" -ForegroundColor Green
