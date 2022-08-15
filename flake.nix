{
  description = "A very basic flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    playdate-sdk = {
        url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-1.12.2.tar.gz";
        type = "tarball";
        flake = false;
    };
    arm-toolchain = {
        url = "https://developer.arm.com/-/media/Files/downloads/gnu/11.2-2022.02/binrel/gcc-arm-11.2-2022.02-x86_64-arm-none-eabi.tar.xz";
        type = "tarball";
        flake = false;
    };
    zig-overlay.url = "github:arqv/zig-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, playdate-sdk, arm-toolchain, zig-overlay }:
    flake-utils.lib.eachDefaultSystem( system:
      let
        pkgs = import nixpkgs { 
          inherit system; 
        };
      in rec {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            zig-overlay.packages."${system}".master.latest
          ];
          PLAYDATE_SDK_PATH = "${playdate-sdk}";
          ARM_TOOLCHAIN_PATH = "${arm-toolchain}";
        };
      }
    );
}
