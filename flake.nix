{
  description = "Standalone build of GNU sed";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  outputs = { self, unpins-lib }:
    unpins-lib.lib.mkStandaloneFlake {
      inherit self;
      name = "sed";
      pkgsAttr = "gnused";
      smoke = [ "--version" ];
      smokePattern = "GNU sed";
      # sed's bundled gnulib has `getrandom.c` that calls `BCryptGenRandom`
      # on _WIN32 but configure's gl_LIBS_LIB_RANDOM probe doesn't pick up
      # `-lbcrypt` under cross. Add it explicitly to LIBS; everything else
      # cross-builds clean.
      windowsBuild = pkgs:
        let cross = unpins-lib.lib.mingwStaticCross pkgs; in
        cross.gnused.overrideAttrs (old: {
          NIX_LDFLAGS = (old.NIX_LDFLAGS or "") + " -lbcrypt";
        });
    };
}
