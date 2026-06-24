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
        inferLinkInputs = true;
        # Also fold into the Windows (mingw PE32+) mega — validated end-to-end
        # (the grep+sed mega runs sed on a real Windows host). See grep's note.
        windows = true;
        # And into the darwin (Mach-O) mega via the engine, same as grep/bc.
        darwin = true;
        programs = [{ name = "sed"; }];
      };

      # pkgsStatic (glibc→musl) and the cross arches can't run the just-built
      # binary, so sed's Makefile skips help2man and installs GNU's "OOPS, we
      # were unable to create a proper manual page" placeholder sed.1. Swap in
      # the real page from the build host (help2man ran there). Notes:
      #   - `buildPackages.gnused` is splicing-aware → the native host build;
      #     `pkgs.gnused` would be the cross stub on i686/ppc64le/riscv64. The
      #     page is arch-independent roff, so the host's is correct everywhere.
      #   - Overwrite uncompressed: at postInstall the page is still plain
      #     `sed.1`; nixpkgs' compressManPages gzips it later in fixupPhase.
      build = pkgs: pkgs.pkgsStatic.gnused.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          zcat ${pkgs.buildPackages.gnused}/share/man/man1/sed.1.gz > $out/share/man/man1/sed.1
        '';
      });

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
