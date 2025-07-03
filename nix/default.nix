{
  pkgs,
  craneLib,
  advisory-db
}:
let  
  src = craneLib.cleanCargoSource ./.;
  
  commonArgs = {
    #inherit (craneLib.crateNameFromCargoToml { inherit src; }) pname version;
    inherit src;

    pname = "my-workspace";
    version = "0.1.0";

    doCheck = true;

    strictDeps = true;

    buildInputs = with pkgs; [
      
    ];

    nativeBuildInputs = with pkgs; [

    ];
    cargoVendorDir = null;
  };
in rec {
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;

  checks = {
    my-workspace-clippy = craneLib.cargoClippy {
      inherit cargoArtifacts src;
      cargoClippyExtraArgs = "--verbose --all-targets -- --deny warnings";
    };

    # Check formatting
    my-workspace-fmt = craneLib.cargoFmt {
      inherit src;
    };

    # Audit dependencies
    my-workspace-audit = craneLib.cargoAudit {
      inherit src advisory-db;
    };
  };

  my-crate = craneLib.buildPackage (commonArgs // {
    inherit cargoArtifacts;
  });
}
