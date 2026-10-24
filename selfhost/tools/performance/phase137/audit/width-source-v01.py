#!/usr/bin/env python3
"""Independent line-preserving audit of the four-bound candidate; no targets."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
PARENT = ROOT/'selfhost/build/phase134/verify-selected-source01/compiler.bend'
CHANGES = {
    'nol_fields': ('U32.is_le(left, 8)', 'U32.is_le(left, 16)'),
    'nol_ctor_fields': ('U32.is_le(da(ctr), 8)', 'U32.is_le(da(ctr), 16)'),
    'p131rg_width': ('U32.is_le(width,8)', 'U32.is_le(width,16)'),
    'p118b_project_borrow': ('U32.is_le(count,8)', 'U32.is_le(count,16)'),
}

def pin(p):
    p=Path(p).resolve(); data=p.read_bytes()
    return dict(file=str(p), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--source',type=Path,required=True)
    ap.add_argument('--controls',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    a=ap.parse_args(); out=a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'implementation/phase137/audit')
    parent=pin(PARENT)
    assert parent['sha256']=='a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57'
    before=PARENT.read_bytes().splitlines(keepends=True)
    after=a.source.read_bytes().splitlines(keepends=True)
    assert len(after)>len(before)
    owner=None; changed=[]
    for i,(old,new) in enumerate(zip(before,after),1):
        match=re.match(rb'(?:def|type|law) ([A-Za-z0-9_.]+)\b',old)
        if match: owner=match[1].decode()
        if old==new: continue
        assert owner in CHANGES, (i,owner)
        left,right=(x.encode() for x in CHANGES[owner])
        assert old.count(left)==1 and old.replace(left,right)==new, (i,owner)
        changed.append(dict(declaration=owner,parentLine=i,before=old.decode(),after=new.decode()))
    assert len(changed)==4 and {x['declaration'] for x in changed}==set(CHANGES)
    controls=a.controls.read_bytes()
    start=re.search(rb'^@unsafe\n',controls,re.M).start()
    assert b''.join(after[len(before):])==b'\n'+controls[start:]
    declarations=re.findall(rb'^(?:def|type|law) ([A-Za-z0-9_.]+)\b',controls,re.M)
    assert declarations and all(x.startswith(b'p137w_') for x in declarations)
    assert all(not re.search(rb'^(?:def|type|law) '+re.escape(n)+rb'\b',b''.join(before),re.M) for n in declarations)
    result=dict(kind='phase137-independent-four-line-width-audit',complete=True,targetsRun=False,
        inputs=[pin(__file__),parent,pin(a.source),pin(a.controls)],changes=changed,
        existingSourcePrefixOtherwiseByteExact=True,controlAppendixByteExact=True,
        scope='All parent bytes except four exact field-width constants are unchanged; added declarations are isolated controls. This is a source-delta audit, not a semantic proof, source-check result, emitted-reader admission or native qualification.')
    out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(complete=True,targetsRun=False,report=pin(out))))

if __name__=='__main__': main()
