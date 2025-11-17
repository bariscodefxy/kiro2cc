{
  description = "A development shell for Go projects using Nix Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # Use a stable channel branch
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      pkgs = forAllSystems (system:
        import nixpkgs {
          inherit system;
          config = { };
        });

    in {
      devShells = forAllSystems (system: {
        default = pkgs.${system}.mkShell {
          packages = with pkgs.${system}; [
            go
          ];

          shellHook = ''
            # Set Go-specific environment variables
            echo "Entering Go Development Shell"
            export GOCACHE=$PWD/.gocache
            export GOMODCACHE=$PWD/.gomodcache
            
            # Ensure the current directory's bin is on the path for compiled tools
            export PATH=$PWD/bin:$PATH
          '';

          buildInputs = with pkgs.${system}; [
          ];
        };
      });

      checks = forAllSystems (system: {
        flake-lock = nixpkgs.lib.checkFlakeLock self.inputs;
      });
    };
}
