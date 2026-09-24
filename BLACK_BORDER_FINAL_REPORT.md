# BLACK BORDER FINAL REPORT

Continued from final groove polish.

## Improvements

- Border `$d020` is explicitly locked to black in top IRQ.
- Border `$d020` is explicitly locked to black in split IRQ.
- Beat flash no longer writes `BeatColors` to `$d020`.
- Idle path reasserts black border.
- Groove/music/filter fixes are preserved.

## Final state

```text
black_border=PASS
no_d020_beat_flash=PASS
idle_border_lock=PASS
bottom_border_lock=PASS
groove_polish=PASS
instrument_filter=PASS
music_theory=PASS
post_fix_non_scale=0
patterns=60
pointer_entries=61
h_order=289
message=38
asset_end=$9f59
margin_to_a000=167
PRG build enabled
```
