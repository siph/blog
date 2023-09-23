{
  description = "Siph's Tech Blog";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    hugo-theme-gruvbox = {
     url = "github:luizdepra/hugo-coder";
     flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, hugo-theme-gruvbox }:
    flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          nativeBuildInputs = with pkgs; [ hugo ];
        in {
          packages = with pkgs; {
            default = stdenv.mkDerivation {
              pname = "siph-tech-blog";
              version = "6942069";
              src = ./.;
              inherit nativeBuildInputs;
              HUGO_MODULE_IMPORTS_PATH = "${hugo-theme-gruvbox}";
              HUGO_PUBLISHDIR = placeholder "out";
              buildPhase = ''
                hugo
              '';
            };
          };
          devShell = with pkgs;
            mkShell {
              inherit nativeBuildInputs;
              HUGO_MODULE_IMPORTS_PATH = "${hugo-theme-gruvbox}";
            };
        });
}

