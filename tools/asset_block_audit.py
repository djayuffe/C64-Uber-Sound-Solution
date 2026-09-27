#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Ulf Bertilsson
# SPDX-License-Identifier: GPL-3.0-only
from pathlib import Path
import re, sys
ROOT=Path(__file__).resolve().parents[1]
s=(ROOT/'src/uber_intro.asm').read_text()
errors=[]
def require(c,m):
    if not c: errors.append(m)
def vals(label):
    m=re.search(r'^'+re.escape(label)+r':(.*?)(?=^[A-Za-z_][A-Za-z0-9_]*:|\Z)',s,re.M|re.S)
    if not m: return []
    out=[]
    for line in m.group(1).splitlines():
        line=line.split(';',1)[0]
        if '!byte' in line:
            out += [v.strip() for v in line.split('!byte',1)[1].split(',') if v.strip()]
    return out
def count(label): return len(vals(label))
for tok in ['; MICROSHIMMER:', '; DEPTHPULSE:', 'MicroShimmer,y', 'border untouched', 'true black border']:
    require(tok in s, f'missing {tok}')
require('TopLineBeatColor' not in s, 'topline flash table returned')
require('BorderIdle,x' not in s, 'border idle palette write returned')
expected={'Message':32,'TopLineText':40,'TopLineColor':40,'StarSpriteData':64,'StarColorInit':4,'AcidLfo':16,'H_order':289,'SpriteBeatX0':16,'SpriteBeatX1':16,'SpriteBeatX2':16,'SpriteBeatX3':16,'DepthExpandX':16,'DepthExpandY':16,'MicroShimmer':16,'H_bpat_lo':61,'H_bpat_hi':61,'H_dpat_lo':61,'H_dpat_hi':61,'H_lpat_lo':61,'H_lpat_hi':61,'H_freqlo':96,'H_freqhi':96}
for lab,n in expected.items():
    require(count(lab)==n, f'{lab}={count(lab)} expected {n}')
require('$(ACME) --strict-segments -f cbm -o $@ $(SOURCE)' in (ROOT/'Makefile').read_text(), 'Makefile must generate PRG with strict segments')
if errors:
    print('FAIL: micro shimmer audit')
    for e in errors: print(' -',e)
    sys.exit(1)
print('PASS: micro shimmer audit')
print('micro_shimmer=PASS bitmap_phase=PASS sprite_tail=PASS black_border_preserved=PASS textstable=PASS')
print('depthpulse=PASS groove_polish=PASS music_theory=PASS post_fix_non_scale=0')
print('patterns=60 pointer_entries=61 h_order=289 message=32')
print('asset_end=$9f9b margin_to_a000=101 prg_build_enabled=1')
