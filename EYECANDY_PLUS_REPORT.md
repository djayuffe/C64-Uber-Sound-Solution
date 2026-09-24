# EYECANDY PLUS REPORT

## Added eyecandy

- Beat-reactive horizontal sprite wobble: `SpriteBeatX0..3`.
- Sprite shimmer contrast on beat.
- Bitmap multicolor pulse preserved through `$d022/$d023`.
- Sprite color pulse on `$d027..$d02a`.
- Idle path restores stable sprite X positions.
- Black border and stable text are preserved.

## Final state

```text
sprite_x_wobble=PASS
sprite_shimmer=PASS
bitmap_pulse=PASS
black_border_preserved=PASS
textstable=PASS
groove_polish=PASS
music_theory=PASS
post_fix_non_scale=0
patterns=60
pointer_entries=61
h_order=289
message=33
asset_end=$9f6c
margin_to_a000=148
PRG build enabled
```
