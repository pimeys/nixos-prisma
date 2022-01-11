{ pkgs ? import <nixpkgs> {} }:

let
  node2nix = import ./node2nix/default.nix { pkgs = pkgs; };
in {
  prisma-language-server = node2nix."@prisma/language-server";
}
