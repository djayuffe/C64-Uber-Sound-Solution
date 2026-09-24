# FINAL GROOVE POLISH REPORT

Continued from instrument/filter fix.

## Improvements

- Kick now also punches `$d416` filter cutoff.
- Big hit adds a high cutoff pop before the main filter LFO resumes.
- Bass PWM now mixes `MusicStep` and `EffectPhase` for more groove movement.
- Lead PWM uses counter-motion against bass (`EffectPhase + MusicStep`, then `MusicStep EOR EffectPhase`).
- AcidLfo table smoothed/widened for more continuous acid sweep.

## Final state

```text
kick_filter_punch=PASS
big_hit_filter_pop=PASS
bass_pwm=PASS
lead_pwm_countermotion=PASS
music_theory=PASS
post_fix_non_scale=0
hard_acid=1
no_intro=1
extended_peak=1
patterns=60
pointer_entries=61
h_order=289
message=37
asset_end=$9f58
margin_to_a000=168
PRG build enabled
```
