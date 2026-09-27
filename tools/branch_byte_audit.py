#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Ulf Bertilsson
# SPDX-License-Identifier: GPL-3.0-only
from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
s = (ROOT/'src/uber_intro.asm').read_text()
lines = s.splitlines()
errors=[]

def err(m): errors.append(m)

labels={}
for i,line in enumerate(lines,1):
    m=re.match(r'^\s*([A-Za-z_][A-Za-z0-9_]*):', line)
    if m:
        labels.setdefault(m.group(1), []).append(i)

# Crude but useful 6502 instruction byte estimator for branch span checks.
def instr_size(line):
    line=line.split(';',1)[0].strip()
    if not line or line.startswith('!') or line.endswith(':') or '=' in line:
        return 0
    parts=line.split(None,1)
    if not parts: return 0
    op=parts[0].lower()
    arg=parts[1].strip() if len(parts)>1 else ''
    implied={'rts','rti','sei','cli','clc','sec','tax','txa','tay','tya','tsx','txs','inx','iny','dex','dey','pha','pla','php','plp','asl','lsr','rol','ror'}
    branches={'bne','beq','bcc','bcs','bmi','bpl','bvc','bvs'}
    if op in branches: return 2
    if op in implied: return 1
    if op in {'jmp','jsr'}: return 3
    if arg.startswith('#'): return 2
    if arg.startswith('('): return 2 if ',y' in arg.lower() or ',x' in arg.lower() else 3
    # ZP symbols in this source.
    zp_names={'zpSrcLo','zpSrcHi','zpDstLo','zpDstHi','zpCntLo','zpCntHi','zpMsgIdx','zpPhase','zpScrollDiv','MusicSub','MusicStep','MusicOrderLo','MusicOrderHi','MusicDrum','MusicLead','SongFlags','StarFrame','BeatFlash','zpChar','zpRow','zpCol','EffectPhase'}
    if arg in zp_names or re.fullmatch(r'\$[0-9a-fA-F]{1,2}', arg): return 2
    if any(arg.startswith(z+',') for z in zp_names): return 2
    return 3

# Estimate byte offset per source line.
offsets={}
pc=0
for i,line in enumerate(lines,1):
    offsets[i]=pc
    # !byte count
    stripped=line.split(';',1)[0]
    if '!byte' in stripped:
        pc += len([v for v in stripped.split('!byte',1)[1].split(',') if v.strip()])
    else:
        pc += instr_size(line)

branch_ops={'bne','beq','bcc','bcs','bmi','bpl','bvc','bvs'}
for i,line in enumerate(lines,1):
    m=re.match(r'^\s*(bne|beq|bcc|bcs|bmi|bpl|bvc|bvs)\s+([A-Za-z_][A-Za-z0-9_]*)', line, re.I)
    if not m: continue
    target=m.group(2)
    if target not in labels: continue
    # Branch displacement is target_pc - (branch_pc + 2)
    target_line=labels[target][0]
    disp=offsets[target_line] - (offsets[i] + 2)
    if disp < -128 or disp > 127:
        err(f'branch byte span out of range line {i}: {line.strip()} -> {target} disp={disp}')

# Regression guard: EffectTick must use long-safe active/idle pattern.
for token in [
    'bne EffectTick_Active',
    'jmp EffectTick_Idle          ; long-safe: active block is too large for BEQ',
    'EffectTick_Active:',
]:
    if token not in s:
        err(f'missing long-safe EffectTick token: {token}')

if errors:
    print('FAIL: branch byte audit')
    for e in errors:
        print(' -', e)
    sys.exit(1)
print('PASS: branch byte audit')
print('relative_branch_byte_spans=PASS effecttick_longsafe=PASS')
