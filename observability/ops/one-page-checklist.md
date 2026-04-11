# Observability Lab - One-page ops checklist

## Daily Health Check

- Grafana health: curl -s http://localhost:3000/api/health
- Prometheus ready: curl -s http://localhost:9090/-/ready
- Loki ready: curl -s http://localhost:3100/ready
- Alertmanager ready: curl -s http://localhost:9093/-/ready
- Prometheus targets: http://localhost:9090/targets

## Restart Safely Check

- `docker compose restart`
- Confirm Grafana dashboard "Infra / Lab Proof" exists 
- Confirm Prometheus targets are UP 

## Persistence Verification

- Named volumes exist: `docker volume ls | grep observability`
- Grafana state persists after restart (dashboards, datasources)   

## Backup (Baseline) 

- Back up Grafana volume before upgrades 
- Back up Prometheus data if you depend on retention 
- Back up Loki data if logs are needed for investigations   

## Upgrade Workflow (Safe) 

- Pull image updates: docker compose pull 
- Apply: docker compose up -d 
- Validate health endpoints + dashboard load 
- If failure: roll back image tag and restore latest backup
