{
  description = "GNU sed as a single self-contained binary";

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

      engine = "unpin-llvm";
      multicall = {
        windows = true;
        programs = [{ name = "sed"; }];
      };

      # Cross/musl can't run the just-built sed, so its Makefile skips help2man
      # and installs GNU's "OOPS" placeholder page. Swap in the host's real one
      # (buildPackages = splicing-aware native build, not the cross stub; the
      # roff is arch-independent). Still uncompressed here — compressManPages
      # gzips it later in fixupPhase.
      build = pkgs: pkgs.pkgsStatic.gnused.overrideAttrs (old: {
        # Run GNU sed's test suite on native runners (0 failures under
        # static-musl); auto-skips on crosses the build host can't execute.
        doCheck = pkgs.pkgsStatic.gnused.stdenv.buildPlatform.canExecute
          pkgs.pkgsStatic.gnused.stdenv.hostPlatform;
        nativeCheckInputs = (old.nativeCheckInputs or [ ]) ++ [ pkgs.buildPackages.perl ];
        postInstall = (old.postInstall or "") + ''
          zcat ${pkgs.buildPackages.gnused}/share/man/man1/sed.1.gz > $out/share/man/man1/sed.1
        '';
      });

      # gnulib getrandom needs BCryptGenRandom but the cross configure probe
      # misses -lbcrypt; add it explicitly.
      windowsBuild = pkgs:
        let cross = unpins-lib.lib.mingwStaticCross pkgs; in
        cross.gnused.overrideAttrs (old: {
          NIX_LDFLAGS = (old.NIX_LDFLAGS or "") + " -lbcrypt";
        });
    };
}
