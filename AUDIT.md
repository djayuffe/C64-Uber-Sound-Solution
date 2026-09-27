# Audit record

## Scope

The release source is `src/uber_intro.asm`. It assembles the live PRG from the
four binary files in `assets/`; those are the only display assets referenced by
the source. `source_music/berlin_golden_heart_hotel_music.txt` is retained as
the human-readable composition reference, not as a build input.

## Results

- ACME assembles the source with `--strict-segments`.
- The source's own asset-size guard keeps code below the bitmap area at `$2000`
  and the asset block below `$a000`.
- The entry path starts at `SYS 4096`, installs an NMI `RTI` stub, and uses a
  two-stage VIC raster IRQ for the bitmap top and text/scroller bottom areas.
- Static checks cover source-table sizes, duplicate labels, branch ranges, and
  expected asset layout. A representative live VICE frame is retained at
  `assets/live-vice.png`.

## Cleanup

The repository previously held an identical second assembly source, identical
converted copies of each build asset, three byte-identical validators, and a
superseded chain of generated status, report, JSON, and checksum files. These
were removed because no active source, build target, or documentation depended
on them. Git history preserves the original records.

## Remaining constraints

The runtime is tuned for PAL C64 timing and a MOS 8580-style SID sound. It has
not been validated for NTSC timing or alternate SID revisions.
