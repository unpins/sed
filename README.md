# sed

[GNU sed](https://www.gnu.org/software/sed/), the stream editor. A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/sed/actions/workflows/sed.yml/badge.svg)](https://github.com/unpins/sed/actions)
![Linux](https://img.shields.io/badge/Linux-%E2%9C%93-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-%E2%9C%93-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-%E2%9C%93-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install sed`.

## Usage

Run the `sed` program with [unpin](https://github.com/unpins/unpin):

```bash
unpin sed 's/foo/bar/g' file.txt
```

To install it onto your PATH:

```bash
unpin install sed
```

## Man pages

`sed.1` is embedded in the binary — read it with `unpin man sed`.

## Build locally

```bash
nix build github:unpins/sed
./result/bin/sed --version
```

Or run directly:

```bash
nix run github:unpins/sed -- 's/foo/bar/g' file.txt
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/sed/releases) page has standalone binaries for manual download.

## Build notes

- **Man page:** the static (musl) and cross builds skip help2man, so upstream installs a placeholder `sed.1`. We swap in the real help2man page from the native build host (arch-independent roff), keeping the embedded man identical on every target.
- **Windows:** a single `sed.exe` targeting the mingw-w64 runtime, linking `-lbcrypt` for gnulib's `getrandom`.
- **Tests:** GNU sed's test suite runs on native builds (0 failures under static-musl) and auto-skips on cross targets the build host can't execute.
