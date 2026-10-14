#!/usr/bin/env python3
"""Record a clean pinned checkout before the Node build worker is launched."""
import hashlib,json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
up=ROOT/'selfhost/.bootstrap/upstream-phase66'
pin=json.loads((ROOT/'selfhost/src/compiler.json').read_text())['upstream']
revision=subprocess.check_output(['git','-C',str(up),'rev-parse','HEAD'],text=True).strip()
status=subprocess.check_output(['git','-C',str(up),'status','--porcelain','--untracked-files=no'],text=True)
assert revision==pin and not status
files=[up/'bend2'/f for f in ('bend.ts','comp.ts','base.bend')]+sorted((up/'bend2/effs').glob('*.c'))+sorted((up/'bend2/effs').glob('*.js'))
records=[dict(file=str(f),sha256=hashlib.sha256(f.read_bytes()).hexdigest(),bytes=f.stat().st_size) for f in files]
out=ROOT/'selfhost/build/phase86/upstream.json'
with out.open('x') as stream:json.dump(dict(revision=revision,status=status,inputs=records),stream,indent=2)
print(out)
