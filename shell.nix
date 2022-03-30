{ pkgs ? import <nixpkgs> { } }: with pkgs;
mkShell {
  buildInputs = [
    figlet
    glibc.static
    zlib.static
    (openssl.override { static = true; }).dev
    dmd
    dtools
    dub
    ldc
  ];

  shellHook = ''
    figlet "Welcome  to Dlang Tour"
  '';
}
