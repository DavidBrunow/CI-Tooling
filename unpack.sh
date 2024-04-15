#! /bin/sh

rm -rf $(dirname "$0")/.git

# Move things out of the CI-Tooling repo here
cp $(dirname "$0")/Dangerfile.swift $(dirname "$0")/..