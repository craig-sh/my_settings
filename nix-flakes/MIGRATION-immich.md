# Immich Migration Plan (Kubernetes → virtnix podman)

Target: bring up the immich pod (server, machine-learning, postgres with
VectorChord, valkey) on virtnix under the `craig` user. Photo library lives on
NFS at `/mnt/main-nfs/one/immich-hl` (reused from the existing k8s deployment).
Postgres and the ML model cache live in rootless podman volumes under craig.

## Prerequisites

- NixOS config deployed — the `immich`, `immich-ml`, `immichdb`, and
  `immichvalkey` user units exist under `craig` on virtnix (verify with
  `systemctl --user status immich` as `craig`)
- `kubectl` access to the source cluster
- SSH access to virtnix and to the NFS server (`trunas.localdomain` or wherever
  `/mnt/main-nfs` is exported from) with root on both
- Existing NFS mount `/mnt/main-nfs` on virtnix (`mount | grep main-nfs` to
  verify — should be `trunas.localdomain:/mnt/mainpool/kubernetes/`)
- The `immich.version` in `nixos/virtnix.nix` matches (or is a supported
  upgrade from) whatever version the k8s deployment is running. Version
  mismatch on startup will try to auto-migrate the DB — only do that
  deliberately.

---

## Target layout (on NFS)

```
/mnt/main-nfs/one/
└── immich-hl/    ← existing photo library from k8s (/data in container)
```

Inside the `immich` container: the library is mounted at `/data`. The postgres
data and valkey/ML caches live in rootless podman volumes
(`~/.local/share/containers/...` under craig).

## Inter-container addressing

All four containers share the pod network namespace. Each talks to the others
via `localhost:<internal-port>`:

| Target app                | Internal URL              | Host URL (127.0.0.1 only) |
|---------------------------|---------------------------|---------------------------|
| immich-server             | `http://localhost:2283`   | `http://127.0.0.1:8796`   |
| immich-machine-learning   | `http://localhost:3003`   | (not published)           |
| postgres                  | `localhost:5432`          | (not published)           |
| valkey                    | `localhost:6379`          | (not published)           |

---

## Steps

### 1. Extract the Immich DB password from k8s

```bash
# Adjust the secret/key names to match your cluster.
kubectl get secret -n default immich-db -o jsonpath='{.data.DB_PASSWORD}' \
  | base64 -d; echo
# Or if it's in a generic env secret:
# kubectl get secret -n default immich-env -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 -d; echo
```

Save this value — you're about to paste it into sops.

### 2. Add the DB password to sops

On the workstation where your `mysecrets` flake input lives:

```bash
cd /path/to/mysecrets
sops secrets/secrets.yaml
```

Add a top-level entry:

```yaml
immich-db-password: <the value from step 1>
```

Save, commit, push, and update the flake lock on the nix-flakes repo:

```bash
cd /path/to/nix-flakes
nix flake update mysecrets
git add flake.lock
git commit -m "Update mysecrets lock for immich-db-password"
```

### 3. Rebuild virtnix

```bash
sudo nixos-rebuild switch --flake .#virtnix
```

Verify the secret decrypted and the env template rendered:

```bash
sudo -iu craig stat -c '%U:%G %a' /run/secrets/immich-db-password
sudo -iu craig cat /run/secrets/rendered/immich.env
# Should print: DB_PASSWORD=...  POSTGRES_PASSWORD=...
```

The four user units (`immich`, `immich-ml`, `immichdb`, `immichvalkey`) will try
to start but the upload library mount path doesn't exist yet — expected. Let
them fail for now.

### 4. Chown the NFS library directory to craig

The library directory already exists from k8s at
`/mnt/main-nfs/one/immich-hl` (server path:
`/mnt/mainpool/kubernetes/one/immich-hl`) and is currently owned by `root`.
Immich runs with `user = "0:0"` inside the container, which maps (rootless
podman) to host `craig` — so the library must be writable by craig. Do this
on the **NFS server** (not the virtnix client; the client can't chown through
root_squash):

```bash
# First find craig's numeric uid/gid on virtnix so you can use numbers on the
# NFS server (which may not have a `craig` user defined):
ssh virtnix 'id craig'
# Example output: uid=1000(craig) gid=100(users) groups=...

# Then on the NFS server, as root:
ssh trunas 'sudo chown -R 1000:1000 /mnt/mainpool/kubernetes/one/immich-hl'
ssh trunas 'sudo chmod -R u+rwX,g+rX,o+rX /mnt/mainpool/kubernetes/one/immich-hl'
# Replace 1000:1000 with craig's actual uid:gid from the `id` output above.
```

Verify from virtnix:

```bash
stat -c '%u:%g %a' /mnt/main-nfs/one/immich-hl
# Should print: 1000:1000 755  (or whatever craig's numeric uid:gid is)
ls -la /mnt/main-nfs/one/immich-hl | head
# Files inside should also be owned by craig (the recursive chown handled them).
```

### 5. Stop the source deployment (k8s)

```bash
kubectl scale deployment immich-server           -n default --replicas=0
kubectl scale deployment immich-machine-learning -n default --replicas=0
# Leave postgres/redis (k8s side) running for the pg_dump step.
```

### 6. Dump postgres from k8s

Use `pg_dumpall` per Immich's official backup procedure — it preserves the
VectorChord schema and roles:

```bash
pg_pod=$(kubectl get pods -n default -l app=immich-postgres -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n default "$pg_pod" -- \
  pg_dumpall --clean --if-exists --username=postgres \
  | gzip > /tmp/immich-dump.sql.gz
ls -lh /tmp/immich-dump.sql.gz
```

Spot-check the dump is non-empty and contains the immich DB:

```bash
zcat /tmp/immich-dump.sql.gz | head -50
zcat /tmp/immich-dump.sql.gz | grep -c 'CREATE DATABASE immich'
# Should print 1.
```

### 7. Confirm the library is in place

The library is already at `/mnt/main-nfs/one/immich-hl` (same NFS subpath the
k8s deployment was using) and chowned to craig in step 4 — no copy needed.
Quick sanity check that the expected Immich subdirs are present:

```bash
ls /mnt/main-nfs/one/immich-hl/
# Expect to see some of: upload/ library/ thumbs/ encoded-video/ profile/
# (exact set depends on the Immich version that wrote the data)
```

If the k8s deployment mounted a **different** subpath than `immich-hl`,
either update `libraryPath` in `home-manager/programs/local_services/immich.nix`
to match, or rename the NFS directory on the server before continuing.

### 8. Scale down postgres in k8s, start the podman stack

```bash
kubectl scale deployment immich-postgres -n default --replicas=0
kubectl scale deployment immich-redis    -n default --replicas=0

sudo -u craig bash -c '
  systemctl --user restart immichdb immichvalkey immich-ml immich
'
systemctl --user --user list-units '*.service' \
  | grep -E 'immichpod|immich'
```

Expected: `immichpod-pod.service` active, 4 container services active,
`podman ps` shows 4 containers on `immichpod`.

Let the server finish its initial migrations — it'll create an empty `immich`
database on first start. Watch the logs:

```bash
sudo -u craig journalctl --user -u immich -f
# Wait until you see the server listening on 0.0.0.0:2283.
```

### 9. Restore the postgres dump

Stop the server and ML containers so they don't fight the restore, then pipe
the dump into the fresh postgres:

```bash
sudo -u craig systemctl --user stop immich immich-ml

sudo -iu craig bash -c '
  zcat /tmp/immich-dump.sql.gz \
    | podman exec -i immichdb psql --dbname=postgres --username=postgres
'

sudo -u craig systemctl --user start immich-ml immich
sudo -u craig journalctl --user -u immich -f
```

If the restore logs show errors about existing users/roles, that's expected
from `--clean --if-exists` running against a fresh DB and can be ignored. Look
for the server log line indicating a successful start against the restored DB.

### 10. Smoke test

1. Browse to `https://immich.localdomain:9443` (Caddy proxies to
   `127.0.0.1:8796`). Log in with your existing credentials — they come from
   the restored DB.
2. Open a recent asset — thumbnail should render, original should stream from
   `/mnt/main-nfs/one/immich-hl/...`.
3. Trigger *Machine Learning → Run job* for Smart Search or Facial Recognition
   on a small album; the ML container should process without error.
4. Upload a new photo; confirm it lands in `/mnt/main-nfs/one/immich-hl/upload/...`
   on the host.

### 11. Cutover: disable k8s and add redirect ingress

Leave the k8s deployments scaled to 0 (or delete them) and add an ingress
redirect so existing bookmarks land on the virtnix Caddy hostname:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: immich-redirect-dummy
  namespace: default
spec:
  ports:
  - port: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: immich-redirect
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/permanent-redirect: "https://immich.localdomain:9443"
    nginx.ingress.kubernetes.io/permanent-redirect-code: "308"
spec:
  ingressClassName: nginx
  rules:
  - host: "immich.localdomain"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: immich-redirect-dummy
            port:
              number: 80
  tls:
  - secretName: nginx-tls-secret
    hosts:
      - '*.localdomain'
```

### 12. Clean up

```bash
rm -f /tmp/immich-dump.sql.gz
# If you used rsync from an old NFS path and confirmed the new one works:
# ssh trunas 'sudo rm -rf /mnt/mainpool/kubernetes/<old-path>'
```

---

## Rollback

If something is badly broken and you want the k8s deployment back:

```bash
git checkout prod -- home-manager/programs/local_services/immich.nix \
                     nixos/virtnix.nix \
                     nixos/hosts/virt/base-configuration.nix
sudo nixos-rebuild switch --flake .#virtnix

kubectl scale deployment immich-server           -n default --replicas=1
kubectl scale deployment immich-machine-learning -n default --replicas=1
kubectl scale deployment immich-postgres         -n default --replicas=1
kubectl scale deployment immich-redis            -n default --replicas=1
```

The k8s postgres PVC still has the pre-dump state (the dump is a copy, not a
move) so k8s immich will come back at its pre-cutover state. The podman
`immich-db` volume is left intact — remove it only once you're confident in
the cutover: `sudo -u craig podman volume rm immich-db immich-valkey
immich-ml-cache`.

The sops `immich-db-password` secret is harmless when unused — leaving it in
`base-configuration.nix` is fine even if immich is rolled back.

---

## After cutover

- Delete this file (`MIGRATION-immich.md`).
- Delete the old k8s immich resources from the `default` namespace (the chart
  was installed there, not in its own namespace):

  ```bash
  # If you installed with helm, uninstall the release:
  helm list -n default | grep immich
  helm uninstall <release-name> -n default

  # Or delete resources individually by label/name as needed.
  ```
