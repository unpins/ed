# ed

[GNU ed](https://www.gnu.org/software/ed/) — the standard POSIX line editor. A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/ed/actions/workflows/ed.yml/badge.svg)](https://github.com/unpins/ed/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install ed`.

## Usage

Run with [unpin](https://github.com/unpins/unpin):

```bash
printf 'a\nhello\n.\nw greeting.txt\nq\n' | unpin ed
unpin ed somefile.txt
```

To install onto your PATH:

```bash
unpin install ed
```

`unpin install ed` creates `ed`. `unpin info ed` describes it.

## Build locally

```bash
nix build github:unpins/ed
./result/bin/ed --version
```

Or run directly:

```bash
nix run github:unpins/ed -- --version
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/ed/releases) page has standalone binaries for manual download.

## Build notes

- **Platforms:** Linux (x86_64, i686, ppc64le, riscv64, aarch64, armv7l), macOS (x86_64, aarch64), Windows (x86_64).
- **`red` dropped:** upstream also installs `red` (restricted ed) as a `/bin/sh` wrapper — dropped here under the single-binary policy.
- **Windows:** built via [Cosmopolitan](https://github.com/jart/cosmopolitan) (`cosmocc`, apelinked to a PE32+ `.exe`), not mingw — ed needs POSIX `<regex.h>`, which mingw lacks and cosmo's libc provides. Note that `ed` is a Unix line editor: feed it `\n`-terminated commands (a Windows `\r\n` script makes it report `?` on each command, exactly as native `ed` does).
- **Man pages:** embedded; read with `unpin man ed`.
