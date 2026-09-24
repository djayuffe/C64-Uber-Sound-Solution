# C64 - Uber Sound Solution

An ArpSID-driven, no-intro hard-acid C64/ACME demo with bitmap eyecandy and
three-SID-style music data.

## Build

```sh
make
```

Expected output:

```text
build/uber_sound_solution.prg
```

The default target runs the source, asset, branch-range, and syntax audits
before assembling the PRG. `./make.sh` remains available as an equivalent
portable build entry point.

## Final state

- starts at SLOT 4 TECHNOA
- no intro
- extra peak repeat SLOT 10..15
- all H_order entries use acid filter flag `$02`
- BERLIN fullbar patterns retained: 60
- pointer entries: 61
- asset_end: `$9f62`
- margin to `$a000`: 158 bytes


## Instrument/filter fix

- improved bass ADSR/PWM
- improved kick/hat/clap/big hit
- wider AcidLfo
- filter routes V1+V2+V3
- LP+BP acid filter retained

## Live VICE capture

![Running C64 Uber Sound Solution](assets/live-vice.png)
