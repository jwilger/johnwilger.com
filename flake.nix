{
  description = "Development environment for johnwilger.com";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zola
            dart-sass
            just
            git
            gh
            jq
            curl
          ];

          shellHook = ''
            echo "johnwilger.com dev shell ready"
            echo "Available commands:"
            echo "  just dev    - Start Zola dev server with Sass watch"
            echo "  just build  - Build production site"
            echo "  zola --help - Zola CLI help"
          '';
        };
      });
}
