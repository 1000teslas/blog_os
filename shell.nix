let
  sources = import ./nix/sources.nix;
  nixpkgs-mozilla = import sources.nixpkgs-mozilla;
  pkgs = import <nixpkgs> { overlays = [ nixpkgs-mozilla ]; };
  rust = (pkgs.rustChannelOf {
    date = "2020-12-17";
    channel = "nightly";
  }).rust.override { extensions = [ "rust-src" "llvm-tools-preview" ]; };
  bootimage = pkgs.rustPlatform.buildRustPackage rec {
    name = "bootimage-${version}";
    version = "0.10.1";
    src = builtins.fetchGit {
      url = "https://github.com/rust-osdev/bootimage";
      rev = "a7bf3b7773ef8445faddc14a5d710333b33be3b7";
    };
    cargoSha256 = "sha256:0865xk82y0i1gqqg6zizq9vc17siwr4rj8isfa09s907c37m43zn";
    meta = with pkgs.stdenv.lib; {
      description =
        "Tool to create bootable disk images from a Rust OS kernel.";
      homepage = "https://github.com/rust-osdev/bootimage";
      licenses = [ licenses.asl20 licenses.mit ];
    };
  };
in pkgs.mkShell {
  buildInputs = with pkgs; [ rust cargo-edit rustfmt bootimage qemu ];
}
