#!/usr/bin/env python3
"""Derive the same controls for the retained higher-order observer, without running it."""
import hashlib,json,sys
from pathlib import Path
assert len(sys.argv)==2,'Usage: baseline-entry.py FRESH_OUTPUT.bend'
source=Path(__file__).with_name('controls.bend')
out=Path(sys.argv[1]).resolve()
text=source.read_text()
old='noa_recur(ctx, args, Nil{}, 100, 100, NO_KAppArgument{fn, NO_KFinish{}})'
new='noa_recur(ctx, args, Nil{}, 100, 100, +i => noa_apply(ctx, fn, noa_iv(i), noa_if(i), noa_in(i), noa_iu(i), +j => noa_finish(ctx, j)))'
assert text.count(old)==1
text=text.replace(old,new)
assert text.count('NO_KFinish{}')==2
text=text.replace('NO_KFinish{}','+i => noa_finish(ctx, i)')
assert 'NO_KAppArgument{' not in text and 'NO_KFinish{}' not in text
out.parent.mkdir(parents=True,exist_ok=True)
with out.open('x') as f:f.write(text)
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
receipt=dict(kind='phase88-observer-baseline-entry',source=pin(source),output=pin(out),method=pin(Path(__file__)),changedAdapters=3)
with Path(str(out)+'.json').open('x') as f:json.dump(receipt,f,indent=2)
print(json.dumps(receipt))
