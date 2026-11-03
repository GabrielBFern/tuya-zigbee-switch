{
  description = "Development shell (replaces the apt-based setup script)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            gnumake
            python3
            yq               # python yq, same as Debian's `yq` package
            unzip
            wget
            cacert           # TLS certs so wget works inside the shell
            gcc-arm-embedded # provides arm-none-eabi-gcc
          ];

          shellHook = ''
            export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            echo "Dev shell ready. Run 'make setup' once to download the SDK and toolchain."
          '';
        };
      });
    };
}
