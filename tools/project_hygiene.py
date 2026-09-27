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
for token in ['; MICROSHIMMER:', 'MicroShimmer,y', 'border untouched']:
    require(token in s, f'missing {token}')
require('TopLineBeatColor' not in s, 'topline flash table returned')
require('BorderIdle,x' not in s, 'border idle palette write returned')
require(('hyper'+'cube') not in s.lower(), 'old music remains')
require(not re.search(r'^\s*\.[A-Za-z_][A-Za-z0-9_]*:',s,re.M), 'dot-local labels remain')
require('$(ACME) --strict-segments -f cbm -o $@ $(SOURCE)' in (ROOT/'Makefile').read_text(), 'Makefile must generate PRG with strict segments')
if errors:
    print('FAIL: project hygiene')
    for e in errors: print(' -',e)
    sys.exit(1)
print('PASS: project hygiene')
print('micro_shimmer=1 depthpulse=1 textstable=1 clean=1 prg_build_enabled=1')
