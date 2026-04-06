# Kong API Gateway Deployment Plan

This directory contains Helm values and manifests for Kong OSS and Kong Enterprise.

Kong Enterprise consists of two helm deployments (same chart, different values):
- `kic` - Kong Ingress Controller (KIC) only - reads Kubernetes Gateway API resources and configures the Gateway (proxy).
- `kong proxy` a.k.a. `kong gateway` - the actual Kong Gateway (proxy) that handles data plane traffic.
 
## Cleanup

```bash
helm uninstall kong -n kong || true
helm uninstall kong-cp -n kong || true
helm uninstall kong-dp -n kong || true
# kubectl delete namespace kong
```

# Deploy Kong Enterprise KIC Gateway Discovery (Split, DB-less, Recommended)

1. Add the Kong Helm repository:

   ```bash
   helm repo add kong https://charts.konghq.com
   helm repo update

   # check available versions
   helm search repo kong/kong --versions

   # check available values
   helm show values kong/kong --version 3.1.0
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

4. Install the Gateway release (proxy only):

   ```bash
   # list chart versions
   helm search repo kong/kong --versions

   helm upgrade --install kong-gw-01 kong/kong \
     -n kong \
     -f k8s/cluster/kong/values-enterprise-gw.yaml \
     --version 3.1.0
   ```

5. Install the KIC controller-only release:

   ```bash
   helm upgrade --install kong-kic-01 kong/kong \
     -n kong \
     -f k8s/cluster/kong/values-enterprise-kic.yaml \
     --version 3.1.0
   ```

6. Apply Gateway API resources:

    ```bash
    kubectl apply -f k8s/cluster/kong/gateway.yaml
    kubectl apply -f k8s/cluster/kong/admin-httproute.yaml
    kubectl apply -f k8s/cluster/kong/manager-httproute.yaml
    ```

7. Scale independently:

   ```bash
   # scale Gateway proxy pods
   kubectl scale deploy/kong-kong -n kong --replicas=5

   # scale KIC controller pods
   kubectl scale deploy/kong-kic -n kong --replicas=2
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


