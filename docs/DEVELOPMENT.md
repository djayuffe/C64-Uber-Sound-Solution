# Development and release guide

Copyright (C) 2026 Ulf Bertilsson. SPDX-License-Identifier: GPL-3.0-only.

## Requirements

- ACME 0.97 or newer;
- Python 3 for the static source checks;
- VICE `x64sc` or `x64` to run the assembled PRG.

## Local verification

```sh
make clean
make
shasum -a 256 -c SHA256SUMS.txt
./vice_run.sh build/uber_sound_solution.prg
```

`make` first runs the focused static checks, then assembles with ACME
`--strict-segments`. `make.sh` is a portable wrapper around the same Makefile,
so both entry points stay consistent.

## Source and asset contract

- `src/uber_intro.asm` is the only release source.
- The source includes the four binary files in `assets/` at `$6000` and guards
  the asset end against `$a000`.
- The top raster IRQ configures bitmap presentation; the split IRQ configures
  the bottom text/sine-scroller area.
- Keep the BASIC `SYS 4096` stub, raster vectors, and `$01=$35` mapping intact
  unless the IRQ/vector design is deliberately redesigned.

## CI and releases

The build workflow runs on pull requests, `main`, version tags, and manual
dispatch. It installs ACME and ShellCheck, runs `make clean && make`, validates
the POSIX launcher scripts, checks the complete SHA-256 manifest, and stores
the PRG as an artifact. The release workflow repeats those checks when a GitHub
release is published.

For a new release, update `VERSION` and `CHANGELOG.md`, run the local commands
above, update `SHA256SUMS.txt`, tag `vX.Y.Z`, and publish the PRG plus checksum
manifest from that tag.
