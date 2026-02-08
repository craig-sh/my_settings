# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive Nix configuration repository managing multiple Linux machines using Nix Flakes. It includes system configurations and Home Manager user configurations.

## Common Commands

### Code Checks
```bash
statix     # Run linter
nix fmt    # Formatter
```
### Tests

When making changes check the results of the tool `dix` using the steps below to make sure changes are whats expected
In the below steps `<machine>` is one of hypernix,carbonix,virtnix,beelink.
In the below steps `<user>` can be craig or conrun.

1. Stash all changes and run the below to save the before state
```
nix build .#nixosConfigurations.<machine>.config.system.build.toplevel
rm .test_change_before_<machine>; mv result .test_change_before_<machine>
home-manager build --flake .#<user>@<machine>
rm .test_hmchange_before_<user>_<machine>; mv result .test_hm_change_before_<user>_<machine>;
```
2. Apply changes
3. Run similar commands to get the new states
```
nix build .#nixosConfigurations.<machine>.config.system.build.toplevel
rm .test_change_after_<machine>; mv result .test_change_after_<machine>
home-manager build --flake .#<user>@<machine>
rm .test_hmchange_after_<user>_<machine>; mv result .test_hm_change_after_<user>_<machine>;
```
4. Use `dix` to compare builds to make sure there are no unexpected changes
```
dix .test_change_before_<machine> .test_change_before_<machine>
dix .test_hmchange_after_<user>_<machine> .test_hmchange_after_<user>_<machine>
```

## Architecture

### Core Structure
- **flake.nix**: Main configuration defining all system outputs
- **justfile**: Just commands for common operations
- **home-manager/**: Home manager confirguarions
- **nixos/**: OS level configuration

