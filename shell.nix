{ pkgs ? import <nixpkgs> { } }: with pkgs;
mkShell {
  buildInputs = [
    figlet
    glibc
    zlib
    openssl.dev
    dmd
    dtools
    dub
    ldc
  ];

  shellHook = ''
    figlet "Welcome  to Dlang Tour"
  '';
}
