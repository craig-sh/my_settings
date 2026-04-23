# k3s removal — remaining items

k3s was removed from `virtnix` (see `nixos/virtnix.nix` — `./hosts/virt/k3s-controller.nix` is no longer imported). The items below are k3s-named but still in active use by the post-k3s podman setup, and removing/renaming them requires work outside this flake. Capturing here so they can be cleaned up later.

---

## 1. Unused `k3s-controller.nix` file

- **Path:** `nixos/hosts/virt/k3s-controller.nix`
- **Status:** no longer imported anywhere, but still on disk.
- **Action:** `git rm nixos/hosts/virt/k3s-controller.nix` once you're confident you won't want to re-import it for reference.

## 2. `k3s-server-token` sops secret

- **Path:** `nixos/hosts/virt/base-configuration.nix` (sops.secrets)
- **Status:** virtnix no longer consumes this, but **virtnix2** still does — it runs `./hosts/virt/k3s-agent.nix`, which reads `config.sops.secrets.k3s-server-token.path` for the k3s join token.
- **Blocker:** `base-configuration.nix` is shared between virtnix and virtnix2. Removing the secret definition would break virtnix2.
- **Action (if virtnix2 is also retired):** drop the `k3s-server-token` secret from `base-configuration.nix`, delete `nixos/hosts/virt/k3s-agent.nix`, remove `nixos/virtnix2.nix`, drop the `k3s-server-token` key from the `mysecrets` sops file.

## 3. `/mnt/k8sconfig` disk label and mount

- **Paths using it:**
  - `nixos/hosts/virt/hardware-configuration.nix:38` — `fileSystems."/mnt/k8sconfig"` with `device = "/dev/disk/by-label/k8sconfig"`
  - `nixos/virtnix.nix:36-40` — tmpfiles rules for `/mnt/k8sconfig/podman/{conrun,craig,podMedia}`
  - `nixos/virtnix.nix:161,172` — rootless podman `graphRoot` for conrun and podMedia
  - `nixos/hosts/virt/backup.nix:4-5` — `local.backup.tmpDir` and `local.backup.workDir`
- **Status:** the disk itself is in active use for podman graphroots and restic staging. The *label* is the k3s-era leftover.
- **Blocker:** renaming requires changing the filesystem label on the running disk (e.g. `e2label /dev/sdX newlabel` or `tune2fs`, or `xfs_admin -L`), then updating all the paths above in one commit. Needs a maintenance window since the mount is active.
- **Suggested name:** `/mnt/podman-state` or `/mnt/containers`.

## 4. NFS export path `trunas.localdomain:/mnt/mainpool/kubernetes/`

- **Path using it:** `nixos/hosts/virt/hardware-configuration.nix:44` — mounted at `/mnt/main-nfs` on virtnix.
- **Status:** the export is serving all podman-mounted NFS data (media, immich library, etc). Client-side path is `/mnt/main-nfs` which is already neutral; only the server-side export name is k8s-era.
- **Blocker:** requires renaming the ZFS dataset / directory on trunas (TrueNAS), updating the NFS export, then changing the `device = ...` line here. All immich/media/etc containers would need their mounts remounted.
- **Suggested name:** `/mnt/mainpool/podman-data` or similar.

---

## Cleaned up in this pass (for reference)

- Dead `#services.k3s.*` commented block in `base-configuration.nix`.
- Stale `# for k8s nfs` comments (kept `rpcbind` and `nfs-utils` since they're still needed for the regular NFS client).
- `k3s-controller.nix` no longer imported from `virtnix.nix`.
- `local.caddy.httpsPort = 9443` override removed (caddy now uses the default 443).
- `networking.firewall.enable = false` removed (was set by `k3s-controller.nix`; firewall now defaults to on with per-service ports declared in `local.services`).
