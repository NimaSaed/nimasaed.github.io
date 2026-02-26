{
  description = "nmsd.xyz — MkDocs site";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system}; in
        {
          # use nix develop to drop into the shell
          default = pkgs.mkShell {
            packages = [
              (pkgs.python3.withPackages (ps: with ps; [
                mkdocs-material
                pymdown-extensions
              ]))
            ];
            shellHook = ''
              echo "MkDocs dev environment ready. Run: mkdocs serve"
            '';
          };
        });

      apps = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          buildSite = pkgs.writeShellScriptBin "build-site" ''
            set -e
            ${pkgs.python3.withPackages (ps: with ps; [
              mkdocs-material
              pymdown-extensions
            ])}/bin/mkdocs build --strict
          '';
        in
        {
          build = { type = "app"; program = "${buildSite}/bin/build-site"; };
          default = { type = "app"; program = "${buildSite}/bin/build-site"; };
        });
    };
}
