# ed for Windows-x86_64 via cosmocc: ed needs POSIX <regex.h> (absent in mingw), which
# cosmo's libc provides. ELF→ed.exe via the cosmo apelink hook.
# nixpkgs ed lists `runtimeShellPackage` in buildInputs (for the `!cmd`
# shell-out); in the cross that resolves to a cosmo `bash` that fails to
# build. ed doesn't need a target shell to compile, and on Windows the
# `!cmd` shell-out goes through cosmo's system() anyway — drop it.
{ lib, dropRed }:
pkgs:
dropRed ((lib.cosmoStaticCross pkgs).ed.overrideAttrs (o: {
  buildInputs = pkgs.lib.filter
    (d: !(pkgs.lib.hasInfix "bash" (d.name or ""))) (o.buildInputs or [ ]);
}))
