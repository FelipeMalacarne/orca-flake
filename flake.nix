{
  description = "Nix packaging for Orca, the agent development environment (stablyai/orca)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = builtins.attrNames (builtins.fromJSON (builtins.readFile ./sources.json)).assets;
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        orca-ide = pkgs.callPackage ./package.nix { };
        default = orca-ide;
      });

      overlays.default = final: _prev: {
        orca-ide = final.callPackage ./package.nix { };
      };

      checks = forAllSystems (pkgs: {
        inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) orca-ide;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
