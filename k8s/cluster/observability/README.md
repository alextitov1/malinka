# Add the prometheus-community Helm repo

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

# Install the stack into a new namespace called 'monitoring'

```
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --version 84.1.0 \
  --values k8s/cluster/observability/kube-prometheus-stack-values.yaml
```

Prometheus Operator: It installs the Prometheus Operator, which lets you configure monitoring declaratively using Kubernetes Custom Resources (like ServiceMonitor and PodMonitor).
All-in-One Bundle: It automatically provisions the entire stack:
* Prometheus (for metrics storage & scraping)
* Grafana (pre-loaded with excellent Kubernetes dashboards)
* Alertmanager (for routing alerts)
* kube-state-metrics (for cluster-level metrics like pod states, deployments, etc.)
* Node Exporter (for machine-level CPU/memory/disk metrics on your nodes)
* Pre-configured Alerts: It comes with thoughtful default alert rules for Kubernetes health (e.g., node down, high CPU, crashlooping pods).

<!-- ## Raspberry Pi temperature monitoring

The stack is configured to reuse the built-in `prometheus-node-exporter` DaemonSet for Raspberry Pi thermal metrics.

### What is added

- enables the node-exporter textfile collector
- mounts host thermal files from `/sys/class/thermal`
- runs a lightweight sidecar that writes Prometheus metrics into the textfile collector directory
- limits real thermal collection to the Raspberry Pi node `malinka3`

### Exposed metrics

- `pi_thermal_zone_temperature_celsius`
- `pi_thermal_zone_temperature_millidegrees`
- `pi_thermal_scrape_success`

Labels:

- `hostname`
- `zone`
- `type`

### Deploy or upgrade

If the stack is already installed, apply the updated values with a Helm upgrade.

```
helm upgrade prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --version 84.1.0 \
  --values k8s/cluster/observability/kube-prometheus-stack-values.yaml
```

### Verify the collector in Kubernetes

After the upgrade:

1. check that the `node-exporter` pod on `malinka3` has the `pi-thermal-collector` sidecar
2. verify the generated file exists in `/var/lib/node-exporter/textfile-collector/pi_thermal.prom`
3. confirm `/metrics` contains `pi_thermal_` series
4. create a Grafana panel or dashboard manually using the PromQL examples below

### Example PromQL

CPU / main thermal zone in Celsius:

`pi_thermal_zone_temperature_celsius{hostname="malinka3"}`

Average Pi temperature over 5 minutes:

`avg_over_time(pi_thermal_zone_temperature_celsius{hostname="malinka3"}[5m])`

Only show successful collection:

`pi_thermal_zone_temperature_celsius{hostname="malinka3"} and on() (pi_thermal_scrape_success == 1)`

### Grafana panel idea

Create a time series panel with:

- query: `pi_thermal_zone_temperature_celsius{hostname="malinka3"}`
- unit: `celsius (°C)`
- legend: `{{zone}} {{type}}`

Useful stat panels:

- `pi_thermal_scrape_success{hostname="malinka3"}`
- `pi_thermal_target_enabled{hostname="malinka3",target_hostname="malinka3"}`

### Notes

- Raspberry Pi thermal zones vary by kernel and model, so the `type` label may differ.
- The sidecar writes metrics every 30 seconds.
- No alerting rules are added yet. -->
