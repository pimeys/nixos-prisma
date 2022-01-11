{ pkgs ? import <nixpkgs> {} }:

import ./node2nix {
  inherit pkgs;
}
