#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Ulf Bertilsson
# SPDX-License-Identifier: GPL-3.0-only
from pathlib import Path
import re, sys, subprocess
ROOT=Path(__file__).resolve().parents[1]
s=(ROOT/'src/uber_intro.asm').read_text()
errors=[]
def err(m): errors.append(m)
for token in [
    'jmp ScrollerDraw_DrawLoop ; long-safe bottom3 sine',
    'bne EffectTick_Active',
    'jmp EffectTick_Idle          ; long-safe: active block is too large for BEQ',
    'ScrollerDraw_DrawLoop:',
    'ScrollerDraw_DrawLoop_done:',
    'TopLine_DrawLoop:',
]:
    if token not in s: err(f'missing {token}')
m=re.search(r'^Message:(.*?)(?=^MessageEnd:)',s,re.M|re.S)
msg_len=0
if m:
    for line in m.group(1).splitlines():
        line=line.split(';',1)[0]
        if '!byte' in line:
            msg_len += len([v for v in line.split('!byte',1)[1].split(',') if v.strip()])
else: err('missing Message')
if msg_len>255: err(f'message_len {msg_len}>255')
byte = subprocess.run(['python3','tools/branch_byte_audit.py'],cwd=ROOT,capture_output=True,text=True)
if byte.returncode != 0:
    err(byte.stdout.strip() + byte.stderr.strip())
if errors:
    print('FAIL: branch range sanity')
    for e in errors: print(' -',e)
    sys.exit(1)
print('PASS: branch range sanity')
print(f'long_scroller_loop=PASS effecttick_longsafe=PASS message_len={msg_len} bottom3_sine=PASS relative_branch_risks=0')
