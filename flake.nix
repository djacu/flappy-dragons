{
  description = "A devShell example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
      in
      with pkgs;
      {
        devShells.default = mkShell rec {
          buildInputs = [
            openssl
            pkg-config
            fontconfig
            rust-bin.stable.latest.default

            # Solves
            # thread 'main' panicked at /home/bakerdn/.cargo/registry/src/index.crates.io-6f17d22bba15001f/winit-0.27.5/src/platform_impl/linux/mod.rs:719:9:
            # Failed to initialize any backend! Wayland status: NoCompositorListening X11 status: LibraryOpenError(OpenError { kind: Library, detail: "opening library failed (libX11.so.6: cannot open shared object file: No such file or directory); opening library failed (libX11.so: cannot open shared object file: No such file or directory)" })
            # note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
            libxkbcommon
            libGL

            # WINIT_UNIX_BACKEND=wayland
            wayland

            # WINIT_UNIX_BACKEND=x11
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
            xorg.libX11
          ];

          LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
        };
      }
    );
}
