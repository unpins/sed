# sed

Standalone build of [GNU sed](https://www.gnu.org/software/sed/), the stream editor.

[![CI](https://github.com/unpins/sed/actions/workflows/sed.yml/badge.svg)](https://github.com/unpins/sed/actions)
![Linux](https://img.shields.io/badge/Linux-%E2%9C%93-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-%E2%9C%93-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-%E2%9C%93-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

## Installation

Install with [unpin](https://github.com/unpins/unpin):

```bash
unpin sed
```

Or run without installing:

```bash
unpin run sed
```

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

## Man pages

`sed.1` is embedded in the binary — read it with `unpin man sed`.

## Manual download

The [Releases](https://github.com/unpins/sed/releases) page has standalone binaries for manual download.

## Build notes

- **Man page:** the static (musl) and cross builds skip help2man, so upstream installs a placeholder `sed.1`. We swap in the real help2man page from the native build host (arch-independent roff), keeping the embedded man identical on every target.
