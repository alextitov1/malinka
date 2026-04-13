
Grafana backup

```
cd ./observability
docker run --rm -v observability_grafana_data:/data -v $(pwd)/backups:/backup alpine sh -c "tar -czf /backup/grafana_data-$(date +%Y-%m-%d-%H-%M-%S).tar.gz -C /data ."
```

Grafana restore

```
cd ./observability
LATEST_BACKUP=$(ls -1 backups/grafana_data-*.tar.gz | tail -n 1)

docker run --rm -v observability_grafana_data:/data -v $(pwd):/work alpine sh -c "tar -xzf /work/$LATEST_BACKUP -C /data"
```

Run grafana-cli

```
docker exec -it grafana grafana cli --version
```


### Prometheus sanity queries

```
up
node_cpu_seconds_total
container_cpu_usage_seconds_total
probe_success
```