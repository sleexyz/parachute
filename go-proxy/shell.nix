{ pkgs ? import <nixpkgs> {}}:
let
  xcodewrapper = pkgs.xcodeenv.composeXcodeWrapper {
    version = "14.0.1";
    xcodeBaseDir = "/Applications/Xcode.app";
  };
in
pkgs.stdenv.mkDerivation {
  name = "go-proxy-shell";
  shellHook = ''
    export PATH=${xcodewrapper}/bin:$PATH
  '';
  nativeBuildInputs = with pkgs; [ 
    go_1_19
    entr
  ];
}
