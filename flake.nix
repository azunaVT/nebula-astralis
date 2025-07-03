{
    description = "Template flake using flake-parts and crane";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-parts.url = "github:hercules-ci/flake-parts";
        flake-parts.inputs.nixpkgs.follows = "nixpkgs";

        crane.url = "github:ipetkov/crane";
        crane.inputs.nixpkgs.follows = "nixpkgs";

        treefmt-nix.url = "github:numtide/treefmt-nix";

        systems-default = { url = "github:nix-systems/default"; flake = false; };
        advisory-db = {
            url = "github:rustsec/advisory-db";
            flake = false;
        };
    };

    outputs = { self, nixpkgs, flake-parts, systems-default, advisory-db, ... } @ inputs: 
        flake-parts.lib.mkFlake {inherit inputs;} {
            imports = [
                inputs.treefmt-nix.flakeModule
            ];
            systems = import systems-default;

            perSystem = {
                system,
                ...
            }:
                let
                    pkgs = import nixpkgs {
                        localSystem = "${system}";
                    };
                    craneLib = (inputs.crane.mkLib pkgs);

                    my-crate-package = pkgs.callPackage ./nix/. { inherit pkgs craneLib advisory-db ;};
                    my-crate = my-crate-package.my-crate;
                    my-checks = my-crate-package.checks;

                    devshell = import ./shell.nix { inherit pkgs my-crate; };
                in {
                    packages = {
                        default = my-crate;
                    };

                    checks = {
                        # Build the crate as part of `nix flake check` for convenience
                        #inherit my-checks;
                    };

                    treefmt.config = {
                        projectRootFile = "flake.nix";
                        programs = {
                            nixpkgs-fmt.enable = false;
                        };
                    };

                    devShells = {
                        default = pkgs.mkShell {
                            buildInputs = [

                            ];
                        };
                    };
                };
        };
}