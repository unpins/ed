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
      # Windows via cosmocc: ed needs POSIX <regex.h> (absent in mingw), which
      # cosmo's libc provides. ELF→ed.exe via the cosmo apelink hook.
      # nixpkgs ed lists `runtimeShellPackage` in buildInputs (for the `!cmd`
      # shell-out); in the cross that resolves to a cosmo `bash` that fails to
      # build. ed doesn't need a target shell to compile, and on Windows the
      # `!cmd` shell-out goes through cosmo's system() anyway — drop it.
      windowsBuild = pkgs:
        dropRed ((lib.cosmoStaticCross pkgs).ed.overrideAttrs (o: {
          buildInputs = pkgs.lib.filter
            (d: !(pkgs.lib.hasInfix "bash" (d.name or ""))) (o.buildInputs or [ ]);
        }));
    };
}
