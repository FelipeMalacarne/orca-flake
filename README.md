# orca-flake

Nix flake packaging the Linux AppImage of [Orca](https://www.onorca.dev/)
([stablyai/orca](https://github.com/stablyai/orca)), an agent development
environment for running coding agents in parallel worktrees.

A scheduled GitHub Action checks for new desktop releases every three hours,
prefetches the AppImages, builds the package and commits the new
`sources.json`.

## Usage

```nix
{
  inputs.orca = {
    url = "github:FelipeMalacarne/orca-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then use `inputs.orca.packages.${system}.default` (binary `orca-ide`) or
`inputs.orca.overlays.default`.

Run `./update.sh [vX.Y.Z]` to update locally.

Supported systems: `x86_64-linux`, `aarch64-linux`.
