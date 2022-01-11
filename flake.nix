{
  description = "A prisma test project";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      forAllSystems = genAttrs [ "x86_64-linux" "i686-linux" "aarch64-linux" ];

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
          packages = import ./default.nix { pkgs = pkgs; };
        in {
          prisma-language-server = packages.prisma-language-server;
        });
    };
}
