{ pkgs ? import <nixpkgs> {}}:
let
  xcodewrapper = pkgs.xcodeenv.composeXcodeWrapper {
    version = "14.0.1";
    xcodeBaseDir = "/Applications/Xcode.app";
  };
in
pkgs.stdenv.mkDerivation {
  name = "go-proxy-shell";
  nativeBuildInputs = with pkgs; [ 
    go_1_19
    entr
    graphviz # for pprof
  ];
  shellHook = ''
    export PATH=${xcodewrapper}/bin:$PATH
    
    export GOPATH=$(pwd)/.gopath
    export PATH=$PATH:$GOPATH/bin
    export CGO_ENABLED=1
  '';
}
