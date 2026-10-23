"""Expose selected literal constructors as an exact experimental source patch.

This is not part of the compiler: no arbitrary Bend program is optimized by
this host tool. It writes a reviewed source overlay and a full replacement
inventory for the one pinned compiler implementation.
"""
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode=True

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('inventory',HERE/'literal-atoms.py')
I=importlib.util.module_from_spec(spec);spec.loader.exec_module(I)
S=I.S

def pin(p):
    p=p.resolve();b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

def main():
    inventory=HERE/'literal-atoms-inventory.json';inv=json.loads(inventory.read_text())
    source=Path(inv['source']['file']);assert pin(source)==inv['source']
    base=source.read_text();before=S.blocks(base)
    fast=ROOT/'selfhost/build/phase131/combined-fast-source02/compiler.bend'
    fast_manifest=fast.with_name('manifest.json');fm=json.loads(fast_manifest.read_text())
    assert pin(fast)==fm['source'];current=S.blocks(fast.read_text())
    atom='@unsafe\ndef atom(\n  +tag: String,\n) -> KTerm:\n  kt(tag, "", 0, 0, Nil{})'
    kt='@unsafe\ndef kt(\n  +tag: String,\n  +name: String,\n  +id: U32,\n  +quant: U32,\n  +kids: List<&2, KTerm>,\n) -> KTerm:\n  KTerm{tag, name, id, quant, kids, Nil{}, 0, 0}'
    assert S.norm(before['atom'])==S.norm(atom) and S.norm(before['kt'])==S.norm(kt)
    names={row['owner'] for row in inv['rows'] if not row['protected']}
    expected=inv['unprotectedCount'];count=0;modules=[];rows=[]
    # Every target body is unchanged by the FAST algorithm candidate. Keep the
    # original source order and don't alter unrelated laws or declarations.
    for name,body in before.items():
        if name not in names:continue
        assert S.norm(body)==S.norm(current[name])
        calls=I.calls(body);assert calls
        changes=[];patched=body
        for call in reversed(calls):
            replacement='KTerm{'+call['literal']+', "", 0, 0, Nil{}, Nil{}, 0, 0}'
            patched=patched[:call['begin']]+replacement+patched[call['end']:]
            changes.append(dict(**call,replacement=replacement))
        assert not I.calls(patched)
        count+=len(calls);modules.append(patched)
        rows.append(dict(name=name,count=len(calls),beforeSha256=hashlib.sha256(body.encode()).hexdigest(),
            afterSha256=hashlib.sha256(patched.encode()).hexdigest(),replacements=list(reversed(changes))))
    assert count==expected==421 and len(rows)==286
    # compose() independently enforces exact override inventory and protected
    # verifier-body identity. It also checks complete declaration preservation.
    overlay=''.join(modules)
    _,added,protected=S.compose(fast.read_text(),[overlay],names,set())
    assert added==[]
    out=ROOT/'selfhost/build/phase131/literal-atoms-overlay01';assert not out.exists();out.mkdir()
    (out/'overlay.bend').write_text(overlay)
    (out/'atom-original.bend').write_text(before['atom'])
    (out/'kt-original.bend').write_text(before['kt'])
    manifest=dict(complete=True,targetsRun=False,checked=False,source=inv['source'],fastSource=pin(fast),
        overlay=pin(out/'overlay.bend'),originalAtom=pin(out/'atom-original.bend'),originalKt=pin(out/'kt-original.bend'),
        inputs=[pin(Path(__file__)),pin(HERE/'literal-atoms.py'),pin(inventory),pin(HERE.parent/'prepare.py'),pin(fast_manifest)],
        replacements=count,overrides=sorted(names),protectedUnchanged=protected,
        sourceByteGrowth=len(overlay.encode())-sum(len(before[n].encode()) for n in names),
        declarationCountChange=0,rows=rows,
        scope='Exact single compiler source patch:421 literal atom calls become the identical8-field immutable KTerm constructor tree. Four protected verifier calls remain unchanged. All target declarations are exact FAST originals apart from recorded replacements. Existing static preparation/runtime gate remains authoritative; no runtime performance or ownership claim from source equality alone.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps({k:manifest[k] for k in ['overlay','replacements','sourceByteGrowth','declarationCountChange']}))

if __name__=='__main__':main()
