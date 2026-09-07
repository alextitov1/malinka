# homepage - the lab dashboard

Serves the default page of `https://k.4esnok.su`, listing every service in the
cluster with a link to it. Services are discovered from **HTTPRoute
annotations**, not from a hand-maintained list.

## Prerequisite: wildcard DNS

Everything here moves apps from paths (`k.4esnok.su/qb`) to subdomains
(`qb.k.4esnok.su`). Today only the apex resolves:

```
k.4esnok.su.    A    10.100.2.200     # kong-gw-01-kong-proxy
```

These names are served by the **MikroTik at 192.168.88.1**, not publicly:
`4esnok.su` delegates to Cloudflare nameservers only so cert-manager can solve
the ACME DNS-01 challenge, and `1.1.1.1` returns nothing for `k.4esnok.su`.

Extend the existing apex entry to cover subdomains, **before applying anything
below**. One record does both - `match-subdomain=yes` extends the record's own
`name` rather than replacing it (RouterOS 7.x):

```
/ip dns static print detail where name~"4esnok"
/ip dns static set [find name="k.4esnok.su"] address=10.100.2.200 match-subdomain=yes
/ip dns cache flush
```

Verify: `dig @192.168.88.1 qb.k.4esnok.su +short`

The existing `wildcard-4esnok-su` Certificate already covers `*.k.4esnok.su`,
so no cert-manager change is needed.

Note this resolves only for clients using the MikroTik as their resolver. The
certificate is publicly trusted but the names are not publicly resolvable, so
these URLs do not work off-LAN, or on a device using DNS-over-HTTPS.

## Why subdomains

A route serving `/` on `k.4esnok.su` would otherwise shadow every path-based
route. Gateway API ranks precedence by hostname before path: "characters in a
matching non-wildcard hostname" outranks "characters in a matching path". A
route with `hostnames: [k.4esnok.su]` and `PathPrefix: /` therefore beats a
hostname-less route with `PathPrefix: /grafana` - the dashboard would swallow
Grafana. Subdomains sidestep this, and remove the need for `UrlBase` /
`serve_from_sub_path` juggling in each app.

## Install

```sh
kubectl apply -f k8s/cluster/homepage/
```

The kube-prometheus-stack values in
`k8s/cluster/observability/kube-prometheus-stack-values.yaml` have been moved to
subdomains too (`grafana.`, `prometheus.`, `alertmanager.`), along with the
matching `root_url` / `externalUrl` / `routePrefix` settings. That chart is not
installed yet - the `monitoring` namespace is empty - so nothing needs
re-running today; the values are correct for whenever it does go in.

## Adding a service to the dashboard

Annotate its HTTPRoute. No dashboard config to edit:

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

Discovery is **opt-in**. A route added without `gethomepage.dev/enabled` never
appears on the dashboard - which is the exact failure this dashboard exists to
prevent. So the annotation is mandatory in this repo, enforced by:

```sh
scripts/check-httproute-annotations.py            # lint the manifests
scripts/check-httproute-annotations.py --cluster  # lint what is running
```

`"false"` is a valid answer - it just has to be a deliberate one. The
`--cluster` mode is the one that catches routes created by Helm charts, which
the file mode cannot see.

## Widgets

`widgets.yaml` includes the `kubernetes` widget with cpu/memory. Those figures
come from metrics-server, which is already available here
(`v1beta1.metrics.k8s.io`, kube-system/metrics-server).

Per-service widgets (Sonarr queue, qBittorrent speeds) need API keys and are
deliberately not configured here - they would put credentials in a ConfigMap.
Add them via a Secret mounted over `services.yaml` if you want them.
