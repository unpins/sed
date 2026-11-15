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

      # nixpkgs sets PERL=missing whenever host != build (always, for musl and
      # mingw), so the Makefile skips help2man and installs GNU's "OOPS"
      # placeholder page. Swap in the build host's real one (buildPackages =
      # the native build; the roff is arch-independent), in both recipes.
      # Still uncompressed here — compressManPages gzips it in fixupPhase.
      build = pkgs: let
        sp = pkgs.pkgsStatic.gnused.stdenv;
        native = sp.buildPlatform.canExecute sp.hostPlatform;
      in pkgs.pkgsStatic.gnused.overrideAttrs (old: {
        # GNU sed's whole suite, the Perl tests included, on native runners
        # (0 failures under static-musl); PERL=missing would skip those, so
        # it goes where the suite runs.
        doCheck = native;
        env = if native then removeAttrs (old.env or { }) [ "PERL" ] else old.env or { };
        postInstall = (old.postInstall or "") + ''
          zcat ${pkgs.buildPackages.gnused}/share/man/man1/sed.1.gz > $out/share/man/man1/sed.1
        '';
      });

      windowsBuild = pkgs:
        let cross = unpins-lib.lib.mingwStaticCross pkgs; in
        cross.gnused.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            zcat ${pkgs.buildPackages.gnused}/share/man/man1/sed.1.gz > $out/share/man/man1/sed.1
          '';
        });
    };
}
