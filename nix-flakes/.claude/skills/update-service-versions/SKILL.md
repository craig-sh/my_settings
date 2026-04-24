---
name: Update local-service versions
description: Check upstream releases for local-services container images, summarize changes since the pinned version, and update the version pins in the Nix config.
---

Use this skill to bump the container image versions for services defined under `home-manager/programs/local_services/` and configured via `local.services.<name>` in `nixos/virtnix.nix` or `nixos/hosts/beelink/configuration.nix` (referenced from `nixos/beelink.nix`).

## Steps

### 1. Pick the target services

If the user did not name a specific service, list the services defined in both hosts (`virtnix.nix` and `beelink.nix`) with their current version, then ask which to update. Accept "all" as a valid answer.

### 2. Find the current version and where it lives

For each target service, locate the pinned version. There are three patterns — handle all of them:

- **Host-config version**: `local.services.<name>.version = "..."` in `nixos/virtnix.nix` or `nixos/hosts/beelink/configuration.nix`. The `.nix` file in `home-manager/programs/local_services/` reads it via `osConfig.local.services.<name>.version`. Examples: `immich`, `syncthing`.
- **Top-of-file `let` binding**: `version = "..."` at the top of the service's `.nix` file, interpolated into the `image` string. Examples: `actualbudget`, `forgejo`, `ghostfolio`, `paperless`, `sparkyfitness`, `tandoor`.
- **Inline image tag**: the version is hardcoded directly in an `image = "registry/org/name:TAG"` line with no variable. Examples: `frigate`, `donetick`, and sidecar images (`postgres`, `redis`, `valkey`, `nginx`).

Record the exact file path and line for each version pin you intend to touch.

### 3. Identify the upstream source

Map each image to its upstream release feed. Common registries used here:

- `ghcr.io/<org>/<repo>` → GitHub releases at `github.com/<org>/<repo>`
- `docker.io/<org>/<repo>` → usually GitHub (search the Docker Hub overview if unsure)
- `codeberg.org/<org>/<repo>` → Codeberg releases API

Known mappings in this repo:

| Service | Image | Upstream |
|---|---|---|
| immich | `ghcr.io/immich-app/immich-server` | github.com/immich-app/immich |
| syncthing | `docker.io/syncthing/syncthing` | github.com/syncthing/syncthing |
| actualbudget | `docker.io/actualbudget/actual-server` | github.com/actualbudget/actual-server |
| paperless | `ghcr.io/paperless-ngx/paperless-ngx` | github.com/paperless-ngx/paperless-ngx |
| forgejo | `codeberg.org/forgejo/forgejo` | codeberg.org/forgejo/forgejo |
| ghostfolio | `docker.io/ghostfolio/ghostfolio` | github.com/ghostfolio/ghostfolio |
| tandoor | `docker.io/vabene1111/recipes` | github.com/TandoorRecipes/recipes |
| sparkyfitness | `docker.io/codewithcj/sparkyfitness` | github.com/CodeWithCJ/SparkyFitness |
| frigate | `ghcr.io/blakeblackshear/frigate` | github.com/blakeblackshear/frigate |
| donetick | `docker.io/donetick/donetick` | github.com/donetick/donetick |

For sidecar images (`postgres`, `redis`, `valkey`, `nginx`, etc.) only bump them if the user explicitly asks — they are usually pinned to a major tag on purpose.

### 4. Fetch latest version and summarize changes

Do NOT use the `gh` CLI — it is not installed. Use WebFetch against the public releases API:

- GitHub: `https://api.github.com/repos/<org>/<repo>/releases`
- Codeberg: `https://codeberg.org/api/v1/repos/<org>/<repo>/releases`

For each service being updated, produce a short summary covering:

- Current pinned version → latest available version
- A condensed changelog spanning all intermediate releases (group by release; highlight breaking changes, migration steps, security fixes, and anything that touches data stored in volumes or databases)
- Any upstream-called-out notes about required config changes, new env vars, or schema migrations

Keep the summary tight — bullet points per intermediate release, not the full release notes. Call out breaking changes loudly.

### 5. Confirm with the user

Present the summary and the exact set of file edits you would make, then ask for confirmation. If the upstream flags a breaking change (schema migration, required env var, data format change), call that out explicitly and wait for an acknowledgement before editing.

### 6. Apply the edits

Update only the version pin — do not touch unrelated config. Preserve the existing version-string style (e.g. keep the leading `v` if the current pin has one like `v2.5.6`; drop it if the current pin is bare like `2.4`). Match what's already there.

Remind the user that any newly touched files must be `git add`ed before building (see `CLAUDE.md`). Do not run a build to verify — the user handles that separately.

### 7. Report

Summarize what was bumped, the old → new versions, any flagged breaking changes the user now owns, and any sidecar images that were intentionally left alone.

## Notes

- Never commit on the user's behalf unless they ask.
- If release notes mention a database migration, surface it — these services have backups configured via `local.services.<name>.backup`, and the user may want a fresh backup before rolling forward.
- If a service uses a host-config `version` attribute but no matching option is declared in `nixos/modules/local-services.nix`, assume it is a free-form attr passed through — do not add module plumbing unless something breaks downstream.
