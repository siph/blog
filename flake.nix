{
  description = "Blog";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
          gems = pkgs.bundlerEnv {
            name = "gems";
            ruby = pkgs.ruby;
            gemfile = ./Gemfile;
            lockfile = ./Gemfile.lock;
            gemset = ./gemset.nix;
          };
          buildInputs = with pkgs; [
            jekyll
            bundler
            bundix
            gems
          ];
        in {
          devShell = with pkgs;
            mkShell {
              inherit buildInputs;
            };
        });
}

