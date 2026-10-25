<div align="center">

# ⚡ Enterprise GitOps Continuous Delivery on Azure Kubernetes Service (AKS)

**Production-ready GitOps pipeline utilizing ArgoCD, Kustomize, and Azure Kubernetes Service (AKS)**  
*App-of-Apps Pattern • Automated Drift Detection & Self-Healing • Multi-Environment Overlays • Zero-Trust Security*

[![GitOps CI](https://github.com/Deenanath486/azure-gitops-argo-cd-aks/actions/workflows/gitops-ci.yml/badge.svg)](https://github.com/Deenanath486/azure-gitops-argo-cd-aks/actions/workflows/gitops-ci.yml)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.29-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-v2.13-EF7B4D?logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Azure AKS](https://img.shields.io/badge/Azure-AKS-0078D4?logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/services/kubernetes-service/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

</div>

---

## 📌 Architectural Overview

This repository demonstrates an enterprise-grade **GitOps Continuous Delivery** implementation on **Azure Kubernetes Service (AKS)**. By establishing Git as the single source of truth, all infrastructure and application changes are audited, version-controlled, and reconciled automatically against the desired state.

```
       +-----------------------------------------------------------+
       |             Git Repository (Source of Truth)              |
       |  github.com/Deenanath486/azure-gitops-argo-cd-aks         |
       +-----------------------------+-----------------------------+
                                     |
                                     | (Webhook / 3-min Polling)
                                     v
       +-----------------------------------------------------------+
       |               ArgoCD Control Plane (AKS)                  |
       |  +-----------------------------------------------------+  |
       |  |              Root App-of-Apps Application           |  |
       |  +-----------+------------------+-------------------+--+  |
       |              |                  |                   |     |
       +--------------|------------------|-------------------|-----+
                      v                  v                   v
             [Dev Application]   [Staging App]       [Prod Application]
                      |                  |                   |
             (Auto-Sync+Prune)   (Auto-Sync+Prune)    (Sync Windows)
                      |                  |                   |
                      v                  v                   v
              +---------------+  +---------------+   +---------------+
              | Namespace:    |  | Namespace:    |   | Namespace:    |
              | dev-orders    |  | staging-orders|   | prod-orders   |
              | (1 Replica)   |  | (2 Replicas)  |   | (4-20 Replicas|
              |               |  |               |   |  + HPA)       |
              +---------------+  +---------------+   +---------------+
                      ^
                      | (Continuous Drift Detection & Self-Healing Loop)
                      +---------------------------------------------+
```

---

## 🎯 Key Architectural Capabilities

| Feature | Implementation | Business Value |
| :--- | :--- | :--- |
| **App-of-Apps Pattern** | Single root declarative application managing environment lifecycle | Zero manual `kubectl` intervention needed on clusters |
| **Multi-Tier Overlays** | Canonical `base/` with Kustomize patches for `dev`, `staging`, `prod` | DRY configuration, transparent environment segregation |
| **Self-Healing** | ArgoCD active reconciliation controller (`selfHeal: true`) | Reverts unauthorized out-of-band manual changes in < 3 mins |
| **Zero-Trust Networking** | K8s `NetworkPolicy` isolating ingress/egress per namespace | Blocks lateral movement and untrusted traffic |
| **Cloud Identity** | Azure Workload Identity with Key Vault Secrets Store CSI Driver | No long-lived passwords or service principal credentials stored in git |
| **Automated Validation** | GitHub Actions running `kubeconform` and `kustomize build` on PRs | Guarantees syntax and schema compliance prior to merge |

---

## 📂 Repository Directory Structure

```plaintext
azure-gitops-argo-cd-aks/
├── .github/
│   └── workflows/
│       └── gitops-ci.yml             # Automated Kustomize & Kubeconform CI gate
├── apps/
│   ├── appproject.yaml               # Enterprise RBAC & namespace permission boundary
│   ├── root-app-of-apps.yaml         # Master application instantiating child apps
│   └── environment-applications.yaml # Dev, Staging, and Prod Application CRDs
├── base/                             # Canonical Kubernetes manifests
│   ├── deployment.yaml               # Hardened container spec (non-root, read-only FS)
│   ├── service.yaml                  # Internal ClusterIP service
│   ├── ingress.yaml                  # Azure Application Gateway Ingress route
│   ├── hpa.yaml                      # HorizontalPodAutoscaler (CPU/Memory targets)
│   ├── networkpolicy.yaml            # Zero-trust namespace traffic isolation
│   ├── configmap-and-sa.yaml         # App config & Azure Workload Identity ServiceAccount
│   └── kustomization.yaml            # Base resource composition
├── environments/                     # Environment Kustomize overlays
│   ├── dev/                          # 1 replica, debug logs, rapid iteration
│   ├── staging/                      # 2 replicas, integration testing
│   └── prod/                         # 4-20 replicas, HPA scaling, sync windows
├── bootstrap/                        # ArgoCD installation & initialization
│   ├── argocd-helm-values.yaml       # HA configuration, Redis-HA, Entra ID SSO
│   ├── ingress-argocd.yaml           # Ingress route with TLS for ArgoCD UI
│   ├── install-argocd.sh             # Linux/macOS automated deployment script
│   └── install-argocd.ps1            # Windows/PowerShell automated deployment script
├── infra/                            # Terraform IaC for AKS & Cloud Infrastructure
│   ├── main.tf                       # AKS with OIDC, Workload Identity & Key Vault
│   ├── variables.tf                  # Tunable infrastructure variables
│   ├── outputs.tf                    # Cluster endpoints & kubeconfig helpers
│   └── terraform.tfvars.example      # Sample production configuration
└── docs/                             # Operational runbooks & architecture guides
    ├── troubleshooting.md            # OutOfSync, drift detection, and sync errors
    └── gitops-best-practices.md      # Enterprise GitOps design principles
```

---

## 🚀 Quickstart Guide

### 1. Provision AKS Infrastructure via Terraform

```bash
cd infra
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Connect your local kubectl context to the new cluster
az aks get-credentials --resource-group rg-gitops-aks-prod --name aks-gitops-enterprise-01 --overwrite-existing
```

### 2. Bootstrap ArgoCD on the Cluster

Run the automated bootstrap script (PowerShell or Bash):

**Using Bash:**
```bash
chmod +x bootstrap/install-argocd.sh
./bootstrap/install-argocd.sh
```

**Using PowerShell:**
```powershell
.\bootstrap\install-argocd.ps1
```

### 3. Access the ArgoCD Web Dashboard

1. Retrieve the initial admin password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```
2. Port-forward the ArgoCD server:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
3. Open `https://localhost:8080` in your browser (Username: `admin`).

---

## 🛡️ Drift Detection & Self-Healing in Action

To experience ArgoCD self-healing firsthand:

1. Intentionally scale down the dev deployment using direct `kubectl`:
   ```bash
   kubectl scale deployment dev-order-processing-api --replicas=0 -n dev-orders
   ```
2. Within seconds, ArgoCD detects the discrepancy between the live cluster state and the Git repository:
   - State flips to **OutOfSync**.
   - The reconciliation controller triggers an automated self-healing sync.
   - The deployment is restored back to the Git-defined replica count (`replicas: 1`).

---

## 👤 Author & Maintainer

**Deenanath Yadav**  
*Senior Azure DevOps & Cloud Infrastructure Engineer*  
- **GitHub**: [@Deenanath486](https://github.com/Deenanath486)  
- **LinkedIn**: [linkedin.com/in/deenanath-yadav-08b265147](https://www.linkedin.com/in/deenanath-yadav-08b265147/)  
- **Email**: deenanath.yadav@hotmail.com  

---

<div align="center">
⭐ If you find this GitOps pattern helpful, please star the repository!
</div>
