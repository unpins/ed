{
  description = "GNU ed as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # GNU ed, the POSIX line editor. Single binary. Upstream also installs `red`
  # (restricted ed) as a /bin/sh wrapper script — drop it (single-binary
  # policy, same as gzip's z* scripts). Native from pkgsStatic.ed.
  outputs = { self, unpins-lib }:
    let
      lib = unpins-lib.lib;
      dropRed = drv: drv.overrideAttrs (o: {
        # Run ed's testsuite on native runners; auto-skips on crosses the build
        # host can't execute (Windows here = cosmo). Passes clean under static-musl.
        doCheck = drv.stdenv.buildPlatform.canExecute drv.stdenv.hostPlatform;
        postInstall = (o.postInstall or "") + ''
          rm -f "$out/bin/red" "$out/share/man/man1/red.1"*
        '';
      });
    in
    lib.mkStandaloneFlake {
      inherit self;
      name = "ed";
      smoke = [ "--version" ];
      smokePattern = "GNU ed";

      # Fold `ed` into the mega through the unpin-llvm engine: native Linux
      # compiles via our static LLVM toolchain and emits a bitcode multicall
      # module (one program, no deps beyond libc). The Windows cosmo path is
      # untouched (engine is Linux-only).
      engine = "unpin-llvm";
      multicall = {
        programs = [{ name = "ed"; }];
      };

      build = pkgs: dropRed pkgs.pkgsStatic.ed;
      windowsBuild = import ./cosmo.nix { inherit lib dropRed; };
    };
}
