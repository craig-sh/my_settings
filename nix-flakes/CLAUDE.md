# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive Nix configuration repository managing multiple Linux machines using Nix Flakes. It includes system configurations and Home Manager user configurations.

## Common Commands

### Code Checks
```bash
statix check <path>       # Run linter (one path at a time, e.g. statix check home-manager/)
nix fmt -- <files>        # Formatter (pass files after --, e.g. nix fmt -- file1.nix file2.nix)
```

### Important Notes
- **New files must be `git add`ed** before building — Nix flakes cannot see untracked files.
- Use `nix build -o <name>` to write to a named symlink instead of the default `result`. This avoids clobbering and allows parallel builds.
- Home Manager builds can also use `nix build` directly: `nix build .#homeConfigurations.<user>@<machine>.activationPackage -o <name>`

### Tests

When making changes check the results of the tool `dix` using the steps below to make sure changes are whats expected.
In the below steps `<machine>` is one of hypernix, carbonnix, virtnix, beelink.
In the below steps `<user>` can be craig or conrun.

1. Stash all changes and build the before state (these can run in parallel):
```bash
nix build .#nixosConfigurations.<machine>.config.system.build.toplevel -o .test_os_before_<machine>
nix build .#homeConfigurations.<user>@<machine>.activationPackage -o .test_hm_before_<user>_<machine>
```
2. Apply changes (unstash, `git add` any new files)
3. Build the after state (these can run in parallel):
```bash
nix build .#nixosConfigurations.<machine>.config.system.build.toplevel -o .test_os_after_<machine>
nix build .#homeConfigurations.<user>@<machine>.activationPackage -o .test_hm_after_<user>_<machine>
```
4. Use `dix` to compare before vs after builds to make sure there are no unexpected changes:
```bash
dix .test_os_before_<machine> .test_os_after_<machine>
dix .test_hm_before_<user>_<machine> .test_hm_after_<user>_<machine>
```
5. Clean up test symlinks:
```bash
rm -f .test_os_before_* .test_os_after_* .test_hm_before_* .test_hm_after_*
```

## Architecture

### Core Structure
- **flake.nix**: Main configuration defining all system outputs
- **justfile**: Just commands for common operations
- **home-manager/**: Home manager confirguarions
- **nixos/**: OS level configuration

