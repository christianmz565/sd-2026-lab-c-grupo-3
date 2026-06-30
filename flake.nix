{
  description = "A multi-platform dev shell flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    UNSAReport.url = "github:UNSAReport/UNSAReport";
    cam.url = "github:christianmz565/commit-author-manager";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      UNSAReport,
      cam,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        fonts = with pkgs; [
          lato
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          LD_LIBRARY_PATH =
            with pkgs;
            lib.makeLibraryPath [
              stdenv.cc.cc
              zlib
              glib
              libxcb
              libglvnd
              mpi
            ];

          packages =
            with pkgs;
            [
              typst
              tinymist
              typstyle
              # javaPackages.compiler.openjdk11-bootstrap
              jdk21
              jdt-language-server
              maven
              gradle
              uv
              bun
              just
              mermaid-cli
              plantuml
              dig
              mpi
              pnpm
              nodejs
              nixd
              ruff
              biome
              openssl
            ]
            ++ fonts
            ++ [
              UNSAReport.packages.${system}.default
              cam.packages.${system}.default
            ];

          buildInputs = [ pkgs.bashInteractive ];

          shellHook = ''
            unset SOURCE_DATE_EPOCH
          '';

          env = {
            FONTCONFIG_FILE = pkgs.makeFontsConf {
              fontDirectories = fonts;
            };
          };
        };
      }
    );
}
