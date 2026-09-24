# INSTRUMENT + FILTER FIX REPORT

## Improvements

### Bass

- Punchier bass ADSR.
- Stronger sustain with short release.
- Wider acid/sub PWM movement using `MusicStep` and `EffectPhase`.

### Drums

- Kick uses lower pitch and pulse body for harder thump.
- Hat uses brighter noise pitch.
- Clap/snare is brighter and more distinct.
- Big hit is tighter and more forceful.
- Drum ADSR tightened.

### Filter

- Wider `AcidLfo` table.
- Acid filter routes V1+V2+V3.
- LP+BP mode retained.
- Stronger step-sweep phase: `MusicStep * 2 + EffectPhase`.
- Fallback path also keeps filter/LFO active.

## Final state

```text
bass=improved
drums=improved
filter=wider_lfo route_v1_v2_v3
music_theory=PASS
post_fix_non_scale=0
hard_acid=1
no_intro=1
extended_peak=1
patterns=60
pointer_entries=61
h_order=289
message=39
asset_end=$9f5a
margin_to_a000=166
PRG build enabled
```

## Audit

```text
PASS: instrument/filter audit
bass=improved drums=improved filter=wider_lfo route_v1_v2_v3=PASS
music_theory=PASS post_fix_non_scale=0 hard_acid=1 no_intro=1 extended_peak=1
patterns=60 pointer_entries=61 h_order=289 message=39
asset_end=$9f5a margin_to_a000=166 prg_build_enabled=1
```
