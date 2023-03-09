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
          buildInputs = with pkgs; [
            jekyll
            bundler
          ];
        in {
          devShell = with pkgs;
            mkShell {
              inherit buildInputs;
            };
        });
}

