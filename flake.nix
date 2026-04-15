{
  description = "HydrideCeiler - HyperCeiler fork for Android 14";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        let
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            buildToolsVersions = [ "34.0.0" ];
            platformVersions = [ "34" ];
            abiVersions = [
              "arm64-v8a"
              "x86_64"
            ];
            includeNDK = false;
            includeEmulator = false;
          };

          androidSdk = androidComposition.androidsdk;
        in
        {
          devShells.default = pkgs.mkShell {
            name = "hydrideceiler-dev";

            packages = with pkgs; [
              jdk17
              gradle
              git
              curl
              unzip
              which
            ];

            ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
            ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
            JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";

            shellHook = ''
              echo "🌨  SnowCeiler14 devshell"
              echo "ANDROID_HOME = $ANDROID_HOME"
              echo "JAVA_HOME    = $JAVA_HOME"

              if [ -f ./gradlew ]; then
                chmod +x ./gradlew
                echo "gradlew 已就绪"
              fi
            '';
          };
        };
    };
}
