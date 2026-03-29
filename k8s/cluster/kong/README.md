# Kong API Gateway Deployment Plan

This directory contains Helm values and manifests for Kong OSS and Kong Enterprise.

## Cleanup

```bash
helm uninstall kong -n kong || true
helm uninstall kong-cp -n kong || true
helm uninstall kong-dp -n kong || true
# kubectl delete namespace kong
```

# Deploy Kong Enterprise KIC/DP (DB-less, Recommended)

This setup deploys Kong Enterprise alongside the Kong Ingress Controller (KIC). This is the best layout for GitOps style setups where Kong configuration and limits are declared in K8S manifests without needing a Postgres DB.

1. Add the Kong Helm repository:

   ```bash
   helm repo add kong https://charts.konghq.com
   helm repo update
   ```

2. Create namespace:

   ```bash
   kubectl create namespace kong
   ```

3. Create Enterprise license secret:

   ```bash
   kubectl -n kong create secret generic kong-enterprise-license \
     --from-file=license=./k8s/cluster/kong/kong-lic.json
   ```

4. Install Kong Enterprise KIC:

   ```bash
   # list chart versions
   helm search repo kong/kong --versions

   helm upgrade --install kong kong/kong \
     -n kong \
     -f k8s/cluster/kong/values-enterprise-kic.yaml \
     --version 3.1.0
   ```


# Other Kong Deployment Options

## Deploy Kong OSS (DB-less)

1. Add the Kong Helm repository:

   ```bash
   helm repo add kong https://charts.konghq.com
   helm repo update
   ```

2. Create namespace:

   ```bash
   kubectl create namespace kong
   ```

3. Install:

   ```bash
   # list chart versions
   helm search repo kong/ingress --versions

   helm upgrade --install kong kong/ingress \
     -n kong \
     -f k8s/cluster/kong/values-oss.yaml \
     --version 0.23.0
   ```


## Deploy Kong Enterprise CP/DP (Hybrid, Non DB-less)

This setup uses two releases:

- CP release: Admin API + Manager, no proxy traffic
- DP release: Proxy traffic only

CP is database-backed (Postgres), and DP connects to CP over mTLS.

1. Add/update repo:

   ```bash
   helm repo add kong https://charts.konghq.com
   helm repo update
   ```

2. Create namespace:

   ```bash
   kubectl create namespace kong
   ```

3. Create Enterprise license secret:

   ```bash
   kubectl -n kong create secret generic kong-enterprise-license \
     --from-file=license=./k8s/cluster/kong/kong-lic.json
   ```

4. Create hybrid cluster certificate secret (shared by CP and DP):

   ```bash
    # secret should include: ca.crt, tls.crt, tls.key
    kubectl -n kong create secret generic kong-cluster-cert \
       --from-file=ca.crt=./ca.crt \
       --from-file=tls.crt=./tls.crt \
       --from-file=tls.key=./tls.key
   ```

5. Configure Postgres in CP values:

    - Edit `k8s/cluster/kong/values-enterprise-cp.yaml` and set:
       - `env.pg_host`
       - `env.pg_port`
       - `env.pg_user`
       - `env.pg_database`
       - `env.pg_password`

6. Install CP and DP:

   ```bash
   # list chart versions
   helm search repo kong/kong --versions

   helm upgrade --install kong-cp kong/kong \
     -n kong \
     -f k8s/cluster/kong/values-enterprise-cp.yaml \
     --version 3.1.0

   helm upgrade --install kong-dp kong/kong \
     -n kong \
     -f k8s/cluster/kong/values-enterprise-dp.yaml \
     --version 3.1.0
   ```

7. Verify:

   ```bash
   kubectl get pods,svc -n kong
   helm list -n kong
   ```

8. Check DP has joined CP:

   ```bash
   kubectl -n kong port-forward svc/kong-cp-kong-admin 8001:8001
   curl -s http://127.0.0.1:8001/clustering/data-planes | jq
   ```


