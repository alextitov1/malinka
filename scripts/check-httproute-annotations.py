#!/usr/bin/env python3
"""Every HTTPRoute must declare whether the dashboard lists it.

Homepage discovers services from HTTPRoutes carrying gethomepage.dev/enabled.
A route without the annotation is invisible on k.4esnok.su - which is the exact
thing the dashboard exists to prevent. So the annotation is mandatory, and
"false" is a valid, deliberate answer.

Usage:
    scripts/check-httproute-annotations.py            lint manifests in git
    scripts/check-httproute-annotations.py --cluster  lint what is running
"""
import json
import re
import subprocess
import sys
from pathlib import Path

ANNOTATION = "gethomepage.dev/enabled"
HINT = (
    '\nAdd %s ("true" alongside name/group/icon, or "false" to opt out).'
    % ANNOTATION
)


def lint_files() -> int:
    missing = []
    for path in sorted(Path("k8s").rglob("*.y*ml")):
        # Helm values files template their routes; --cluster covers those.
        if path.name.endswith("values.yaml"):
            continue
        text = path.read_text()
        if "kind: HTTPRoute" not in text:
            continue
        for doc in re.split(r"^---\s*$", text, flags=re.M):
            if not re.search(r"^kind:\s*HTTPRoute\s*$", doc, flags=re.M):
                continue
            name = re.search(r"^\s+name:\s*(\S+)", doc, flags=re.M)
            if ANNOTATION not in doc:
                missing.append(
                    "%s: HTTPRoute %s" % (path, name.group(1) if name else "<unnamed>")
                )
    return report(missing)


def lint_cluster() -> int:
    out = subprocess.run(
        ["kubectl", "get", "httproutes.gateway.networking.k8s.io", "-A", "-o", "json"],
        capture_output=True,
        text=True,
    )
    if out.returncode != 0:
        print(out.stderr.strip(), file=sys.stderr)
        return 2
    missing = [
        "%s/%s" % (i["metadata"]["namespace"], i["metadata"]["name"])
        for i in json.loads(out.stdout)["items"]
        if ANNOTATION not in (i["metadata"].get("annotations") or {})
    ]
    return report(missing)


def report(missing: list) -> int:
    for m in missing:
        print("MISSING  %s" % m)
    if missing:
        print(HINT)
        return 1
    print("All HTTPRoutes declare %s." % ANNOTATION)
    return 0


if __name__ == "__main__":
    sys.exit(lint_cluster() if "--cluster" in sys.argv[1:] else lint_files())
