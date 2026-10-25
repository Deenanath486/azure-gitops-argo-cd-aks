# ArgoCD & GitOps Troubleshooting Runbook

This guide covers real-world troubleshooting scenarios encountered in enterprise AKS environments running ArgoCD GitOps workflows.

---

## 1. Application Status is `OutOfSync`

### Symptom
ArgoCD UI displays the application status in yellow `OutOfSync`.

### Root Cause Analysis
1. **Legitimate Commit**: A new commit was pushed to `main`, and ArgoCD has not reached its scheduled reconciliation interval (default: 3 minutes).
2. **External Drift**: An operator or external process used `kubectl edit` or `kubectl patch` directly on the cluster.
3. **Ignored Differences**: Live fields generated dynamically by Kubernetes (e.g. `caBundle` in webhooks, mutating webhooks adding sidecars).

### Remediation Steps
- **Trigger immediate sync**:
  ```bash
  argocd app sync <app-name> --prune
  ```
- **Inspect drift**:
  ```bash
  argocd app diff <app-name>
  ```
- **Configure `ignoreDifferences`** in the Application CRD if mutating webhooks modify resources:
  ```yaml
  spec:
    ignoreDifferences:
      - group: apps
        kind: Deployment
        jsonPointers:
          - /spec/template/metadata/annotations/kubectl.kubernetes.io~1restartedAt
  ```

---

## 2. Sync Operation Failed: `ComparisonError` / `Kustomize Build Error`

### Symptom
Application health shows `Degraded` or sync error: `kustomize build failed: no such file or directory`.

### Remediation Steps
1. Test the build locally:
   ```bash
   kustomize build environments/dev
   ```
2. Verify all files referenced in `kustomization.yaml` are present and committed to git.
3. Check the ArgoCD Repo Server logs:
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-repo-server --tail=100
   ```

---

## 3. Production Deployment Blocked by Sync Windows

### Symptom
Manual sync or automated sync fails with: `Sync denied by sync window`.

### Remediation Steps
1. Check configured sync windows:
   ```bash
   argocd proj windows list retail-platform
   ```
2. For emergency zero-day hotfixes, an authorized engineer with `admin` privileges can override:
   ```bash
   argocd app sync prod-orders-api --apply-out-of-sync-only --force
   ```

---

## 4. Azure Workload Identity Token Not Mounting

### Symptom
Pods fail to connect to Azure Key Vault with 401/403 unauthorized.

### Remediation Steps
1. Verify pod annotations contain `azure.workload.identity/use: "true"`.
2. Verify ServiceAccount annotation contains `azure.workload.identity/client-id: "<client-id>"`.
3. Check projected service account volume mount:
   ```bash
   kubectl get pod <pod-name> -n prod-orders -o yaml | grep azure-identity-token
   ```
