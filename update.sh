#!/usr/bin/env bash

set -eu -o pipefail

cd node2nix

rm -f ./node-env.nix

node2nix \
    -i node-packages.json \
    -o node-packages.nix \
    -c default.nix \
    --pkg-name nodejs-14_x
