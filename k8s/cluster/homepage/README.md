# homepage - the lab dashboard

Serves the default page of `https://k.4esnok.su`: a list of every service in
the cluster, with a link to each.

## How it works

Services are discovered from **HTTPRoute annotations**, not from a config file
in this directory. Homepage runs with `gateway: true` (see `configmap.yaml`)
and a ClusterRole that lets it read `httproutes` and `gateways` cluster-wide.
On load it lists every HTTPRoute carrying `gethomepage.dev/enabled: "true"` and
builds a tile from the rest of that route's annotations.

So there is no list to keep in sync - a service appears on the dashboard
because of the annotation on its own route, and disappears when that route
does.

Services live on subdomains (`qb.k.4esnok.su`, `grafana.k.4esnok.su`) rather
than path prefixes. The dashboard occupies `/` on the apex, and Gateway API
ranks match precedence by hostname before path - so an apex route on `/` would
otherwise shadow every hostname-less path route. Subdomains also avoid setting
`UrlBase` / `serve_from_sub_path` in each app.

## Install

```sh
kubectl apply -f k8s/cluster/homepage/
```

## Adding a service

Annotate its HTTPRoute. Nothing here needs editing:

```yaml
metadata:
  annotations:
    gethomepage.dev/enabled: "true"
    gethomepage.dev/name: Sonarr
    gethomepage.dev/description: TV
    gethomepage.dev/group: Media
    gethomepage.dev/icon: sonarr.png
    gethomepage.dev/pod-selector: app=sonarr   # optional: shows pod status
```

Groups are laid out in `configmap.yaml` under `settings.yaml: layout`. Icons
come from the dashboard-icons set; the bare name works (`sonarr.png`).

## The annotation gap, and the lint that closes it

Discovery is **opt-in**, so a route added without `gethomepage.dev/enabled`
never appears - the exact failure this dashboard exists to prevent. The
annotation is therefore mandatory in this repo:

```sh
scripts/check-httproute-annotations.py            # lint the manifests
scripts/check-httproute-annotations.py --cluster  # lint what is running
```

`"false"` is a valid answer - it just has to be a deliberate one. `--cluster`
mode also catches routes created by Helm charts, which the file mode cannot
see.

## Widgets

The `kubernetes` widget's cpu/memory figures come from metrics-server.
Per-service widgets (Sonarr queue, qBittorrent speeds) need API keys and are
deliberately not configured - they would put credentials in a ConfigMap. Add
them via a Secret mounted over `services.yaml` if you want them.
