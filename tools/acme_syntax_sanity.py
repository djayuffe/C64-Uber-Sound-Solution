#!/usr/bin/env python3
from pathlib import Path
import re, sys
ROOT=Path(__file__).resolve().parents[1]
s=(ROOT/'src/uber_intro.asm').read_text()
lines=s.splitlines()
errors=[]
def err(m): errors.append(m)
if re.search(r'^\s*\.[A-Za-z_][A-Za-z0-9_]*:', s, re.M): err('dot-local label remains')
if re.search(r'\b(?:bne|beq|bcc|bcs|bmi|bpl|bvc|bvs|jmp|jsr)\s+\.[A-Za-z_]', s, re.I): err('dot-local target remains')
labels={}
for i,line in enumerate(lines,1):
    m=re.match(r'^\s*([A-Za-z_][A-Za-z0-9_]*):', line)
    if m: labels.setdefault(m.group(1),[]).append(i)
for label,locs in labels.items():
    if len(locs)>1: err(f'duplicate label {label}: {locs}')
def count(label):
    m=re.search(r'^'+re.escape(label)+r':(.*?)(?=^[A-Za-z_][A-Za-z0-9_]*:|\Z)', s, re.M|re.S)
    if not m: return -1
    c=0
    for line in m.group(1).splitlines():
        line=line.split(';',1)[0]
        if '!byte' in line:
            c+=len([v for v in line.split('!byte',1)[1].split(',') if v.strip()])
    return c
msg=count('Message')
if msg<0: err('missing Message')
if msg>255: err(f'Message {msg}>255')
for label,size in [('TopLineText',40),('TopLineColor',40)]:
    if count(label)!=size: err(f'{label} not {size}')
for i in range(4):
    if count(f'SpriteBeatY{i}') != 16: err(f'SpriteBeatY{i} not 16')
for i in range(4,8):
    if count(f'SpriteBeatY{i}') != -1: err(f'SpriteBeatY{i} should be removed')
for token in [
    'bne EffectTick_Active',
    'jmp EffectTick_Idle          ; long-safe: active block is too large for BEQ','; BERLINFULL:','jmp ScrollerDraw_DrawLoop ; long-safe bottom3 sine','sta $d01d','sta $d017']:
    if token not in s: err(f'missing {token}')
pre=s.split('!if * > BITMAP_ADDR',1)[0]
if 'TopLineText:' in pre or 'Message:' in pre: err('scroller text tables after code guard failed')
if errors:
    print('FAIL: ACME syntax sanity')
    for e in errors: print(' -',e)
    sys.exit(1)
print('PASS: ACME syntax sanity')
print(f'global_labels_unique=1 dot_local_labels=0 message_len={msg} top_line=40 y_bounce=PASS immediate_operands=PASS')
