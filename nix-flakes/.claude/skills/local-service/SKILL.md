---
name: Create local-service
description: Configure  podman quadlets to run a self hosted service using [[https://seiarotg.github.io/quadlet-nix/]] on nix
---

When creating a local-service

1. Determine which host (beelink or virtnix) that the service will run on and under which user it will run
2. Search the project page for configuration examples of running as rootless podman. Failing that search rootless docker, and then finally just docker.
3. Look at files in `home-manager/programs/local_services/` for examples of how local services are defined
4. Look at the key `local.services` in  nixos/virtnix.nix and nixos/beelink.nix for examples on how services are configured
5. Ask the user if any nfs directories will be mounted to use for data instead of pure podman volumes.
6. Suggest backup options to the user and expain why certain volumes may or may not need to be backed up. *Note*  Nfs directories do not need to be backed up
7. Ask the user if they will be migrating this service from kubernetes. If this is the case present a migration plan to copy over data. See example-migration-plan.md for an example plan for tandoor.nix

