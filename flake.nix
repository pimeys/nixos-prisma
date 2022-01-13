{
  description = "A prisma test project";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);

      forAllSystems = genAttrs [
        "x86_64-linux"
        "x86_64-darwin"
        "i686-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      pkgsFor = pkgs: sys:
        import pkgs {
          system = sys;
          config = { allowUnfree = true; };
        };

    in rec {
      devShell = forAllSystems (system:
        let
          pkgs = (pkgsFor inputs.nixpkgs system);
        in
          pkgs.mkShell {
            nativeBuildInputs = [ pkgs.bashInteractive ];
            buildInputs = with pkgs; [
              nodePackages.node2nix
            ];
          }
      );

      overlay = final: prev: {
        prismaPackages = import ./default.nix {
          pkgs = prev;
        };
      };

      packages = forAllSystems (system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };
          node2nix = pkgs.nodePackages.node2nix;
        in import ./default.nix {
          inherit pkgs;
        } // {
          updatePackages = pkgs.writeShellScriptBin "updatePackages" ''
            set -eu -o pipefail
            rm -f ./node-env.nix
            ${node2nix}/bin/node2nix -i node-packages.json -o node-packages.nix -c default.nix --pkg-name nodejs-14_x
          '';
        });
    };
}
