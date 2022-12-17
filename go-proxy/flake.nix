{
  description = "slowdown-dev-shell";
  # inputs.nixpkgs.url = "github:stephank/nixpkgs/feat/swift-darwin"; # Swift works here
  inputs.nixpkgs.url = "github:nixos/nixpkgs/22.11";
  outputs =
    { self , nixpkgs , }:
    let
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      xcodewrapper = pkgs.xcodeenv.composeXcodeWrapper {
        version = "14.2";
        xcodeBaseDir = "/Applications/Xcode.app";
      };
    in
    {
      devShells.aarch64-darwin.default = pkgs.mkShell {
        name = "slowdown-dev-shell";
        nativeBuildInputs = with pkgs; [
          go_1_19
          protobuf3_20
          entr
          flatbuffers
          graphviz # for pprof
          llvmPackages_11.clang
          buildifier
          bazel_5
        ];
        shellHook = ''
          export PATH=${xcodewrapper}/bin:$PATH
          
          export GOPATH=$(pwd)/.gopath
          export PATH=$PATH:$GOPATH/bin
          export PATH=$PATH:$(pwd)/.external/swift-protobuf/.build/release
          export CGO_ENABLED=1
        '';
      };
    };
}

