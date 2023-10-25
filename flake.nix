{
  description = "A flake for building Anne Pro 2 QMK firmware";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      # There is no network access inside the build sandbox, so must use buildRustPackage
      # https://discourse.nixos.org/t/help-to-build-a-rust-based-package-with-strange-download-failure-error/30806

      # https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/rust.section.md

      packages.${system}.default = pkgs.rustPlatform.buildRustPackage rec {
        pname = "annepro2-tools";
        version = "1.0";

        src = ./.;

        cargoLock = {
          lockFile = ./Cargo.lock;
        };

        nativeBuildInputs = with pkgs; [
          gcc
          pkg-config
        ];

        buildInputs = with pkgs; [
          libusb1
        ];

        postInstall = ''
          echo <<EOF
            Steps:
            1. Run "sleep 15; ./result/bin/annepro2_tools <path-to-firmware>"
            2. Unplug keyboard -> Plug in keyboard while holding ESC -> Wait 5 seconds -> Release ESC
            3. (Should see "Flash complete") Re-plug keyboard
          EOF
        '';
      };
    };
}
