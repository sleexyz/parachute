{
  description = "slowdown-dev-shell";
  # inputs.nixpkgs.url = "github:stephank/nixpkgs/feat/swift-darwin"; # Swift works here
  # inputs.nixpkgs.url = "github:nixos/nixpkgs/22.11";
  outputs =
    { self , nixpkgs , }:
    let
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      xcodewrapper = pkgs.xcodeenv.composeXcodeWrapper {
        version = "14.3.1";
        xcodeBaseDir = "/Applications/Xcode.app";
      };
    in
    {
      devShells.aarch64-darwin.default = pkgs.mkShell {
        name = "slowdown-dev-shell";
        # 
        nativeBuildInputs = with pkgs; [
          google-cloud-sdk
          nodejs
          go_1_19
          protobuf3_20
          entr
          flatbuffers
          graphviz # for pprof
          buildifier
          bazel_5
        ];
        shellHook = ''
          export LD=/usr/bin/clang # https://stackoverflow.com/questions/65146106/xcodebuild-using-ld-rather-than-clang-for-linking
          export PATH=${xcodewrapper}/bin:$PATH

          export GOPATH=$(pwd)/.gopath
          export PATH=$PATH:$GOPATH/bin
          export CGO_ENABLED=1
          export CLOUDSDK_ACTIVE_CONFIG_NAME=slowdown
        '';
      };
    };
}

