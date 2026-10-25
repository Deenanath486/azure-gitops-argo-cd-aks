# Enterprise GitOps Best Practices on Azure Kubernetes Service

Implementing GitOps at enterprise scale requires strict architectural discipline across repository structures, security boundaries, and promotion workflows.

---

## 1. Repository Segregation Pattern
Separate **Application Source Code** from **GitOps Manifests**:
- **Application Repo**: Contains microservice source code, unit tests, and Dockerfile. CI builds the image, runs vulnerability scans, pushes to Azure Container Registry (ACR), and updates the image tag in the GitOps repository via Pull Request.
- **GitOps Config Repo** (This repository): Contains Kubernetes manifests, Kustomize overlays, Helm charts, and ArgoCD Application CRDs. Single source of truth for desired cluster state.

---

## 2. The "App-of-Apps" Pattern
Instead of manually applying individual ArgoCD applications, define a single root application (`apps/root-app-of-apps.yaml`) that monitors the `apps/` directory.
- When a new application manifest is added to `apps/`, ArgoCD automatically detects and instantiates the new application on AKS.
- Ensures zero manual `kubectl apply` commands on production clusters.

---

## 3. Automated Self-Healing & Drift Protection
- Always enable `selfHeal: true` in non-prod environments.
- In production, configure `selfHeal: true` combined with `PruneLast=true` to prevent cluster configuration drift while ensuring graceful cascading resource cleanup.
- Revoke direct `write` and `admin` permissions on production AKS kubeconfig for human developers; all changes must pass through Git Pull Requests.

---

## 4. Multi-Environment Promotion Strategy
Use Kustomize overlays (`base/` -> `environments/dev` -> `environments/staging` -> `environments/prod`):
1. **Base**: Holds shared, canonical manifests (Deployment, ClusterIP, ServiceAccount, NetworkPolicy).
2. **Dev Overlay**: Fast reconciliation, automated sync, minimal replicas, debug logging.
3. **Staging Overlay**: Mirrors production scale and ingress configurations for end-to-end integration tests.
4. **Prod Overlay**: High-availability replicas, Horizontal Pod Autoscaler (HPA), strict sync windows, conservative resource limits.

---

## 5. Security & Secret Zero-Trust
- Never commit unencrypted secrets or credentials into Git.
- Use **Azure Workload Identity** with the **Secrets Store CSI Driver** to mount secrets directly into pod volumes from Azure Key Vault.
- Alternatively, leverage Bitnami Sealed Secrets with cluster-specific private keys.
