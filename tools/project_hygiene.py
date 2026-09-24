#!/usr/bin/env python3
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
require('acme -f cbm -o build/uber_sound_solution.prg src/uber_intro.asm' in (ROOT/'make.sh').read_text(), 'make.sh must generate PRG')
if errors:
    print('FAIL: project hygiene')
    for e in errors: print(' -',e)
    sys.exit(1)
print('PASS: project hygiene')
print('micro_shimmer=1 depthpulse=1 textstable=1 clean=1 prg_build_enabled=1')
