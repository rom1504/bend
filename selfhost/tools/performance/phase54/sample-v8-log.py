#!/usr/bin/env python3
"""Retain every tenth V8 tick and all mapping events for bounded diagnostics."""
import hashlib,json,sys
from pathlib import Path
src,out,receipt=map(Path,sys.argv[1:]);ticks=kept=0
assert not out.exists() and not receipt.exists()
with src.open('rb') as inp,out.open('xb') as dst:
    for line in inp:
        if line.startswith(b'tick,'):
            take=ticks%10==0;ticks+=1
            if not take:continue
            kept+=1
        dst.write(line)
def ident(p):
    h=hashlib.sha256()
    with p.open('rb') as f:
        for chunk in iter(lambda:f.read(1024*1024),b''):h.update(chunk)
    return {'file':str(p.resolve()),'sha256':h.hexdigest(),'bytes':p.stat().st_size}
receipt.write_text(json.dumps({'producer':ident(Path(__file__)),'source':ident(src),'sample':ident(out),'ticks':ticks,'kept':kept,'stride':10,'firstIndex':0,'scope':'Deterministic subsampled diagnostic, not unbiased attribution or timing.'},indent=2)+'\n')
