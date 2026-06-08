{
  description = "A multi-platform dev shell flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    lab-report.url = "github:christianmz565/lab-report/dev";
    cam.url = "github:christianmz565/commit-author-manager";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      lab-report,
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
              plantuml
              dig
              mpi
              nixd
            ]
            ++ fonts
            ++ [
              lab-report.packages.${system}.default
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
