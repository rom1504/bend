"""Replay the reviewed literal exposure on a current, immutable composition.

Only the original reviewed declaration set is eligible. Current declaration
bodies, later algorithm changes, proof implementations and verifier gates are
preserved; no old whole-definition overlay is applied.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('audit',HERE/'audit-literal-atoms.py')
A=importlib.util.module_from_spec(spec);spec.loader.exec_module(A)
I=A.I;S=I.S
PROOFS={'p131a_add','p131a_low','p131a_high','P131UEntry','p131u_absent',
        'p131u_max_loop','p131u_max','p131u_min_loop','p131u_min','p131u_merge_loop','p131u_merge'}

def digest(s):return hashlib.sha256(s.encode()).hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    args=p.parse_args();manifest=args.manifest.resolve();current=json.loads(manifest.read_text())
    assert current['complete'];source=Path(current['source']['file']);assert I.pin(source)==current['source']
    for pin in current['inputs']:assert I.pin(Path(pin['file']))==pin
    old=source.read_text();before=S.blocks(old)
    inventory=HERE/'literal-atoms-inventory.json';inv=json.loads(inventory.read_text())
    selected=Path(inv['source']['file']);assert I.pin(selected)==inv['source'];original=S.blocks(selected.read_text())
    assert all(S.norm(before[n])==S.norm(original[n]) for n in ['atom','kt'])
    protected=set(current['protectedDeclarations']);assert len(protected)==91 and PROOFS<=set(before)
    names={x['owner'] for x in inv['rows'] if not x['protected']}-protected-PROOFS
    assert len(names)==286
    # All bare occurrences must be the sole global definition or a call. A
    # local binder/alias named atom would violate this exact-source precondition.
    atom_def=re.search(r'^def atom\(',old,re.M);assert atom_def
    for pos in A.identifiers(old,'atom'):
        if pos==atom_def.start()+4:continue
        close=I.whitespace(old,pos+4);assert close<len(old) and old[close]=='('
    hits=list(S.PAT.finditer(old));parts=[old[:hits[0].start()]];rows=[];changed=set()
    for index,hit in enumerate(hits):
        name=hit[1];body=old[hit.start():hits[index+1].start() if index+1<len(hits) else len(old)]
        if name not in names or body.lstrip().startswith('law '):parts.append(body);continue
        calls=I.calls(body);patched=body;replacements=[]
        for call in reversed(calls):
            replacement='{KTerm{'+call['literal']+', "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}'
            assert patched[call['begin']:call['end']]==call['call']
            patched=patched[:call['begin']]+replacement+patched[call['end']:]
            replacements.append(dict(**call,replacement=replacement))
        parts.append(patched)
        if calls:
            changed.add(name);rows.append(dict(name=name,count=len(calls),beforeSha256=digest(body),
                afterSha256=digest(patched),replacements=list(reversed(replacements))))
    result=''.join(parts);after=S.blocks(result)
    assert set(after)==set(before)
    for name in before:
        if name not in changed:assert after[name]==before[name]
    assert all(after[n]==before[n] for n in protected|PROOFS)
    out=args.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131');out.mkdir()
    (out/'compiler.bend').write_text(result)
    (out/'method.py').write_bytes(Path(__file__).read_bytes())
    report=dict(current)
    report.update(checked=False,targetsRun=False,source=I.pin(out/'compiler.bend'),directParent=current['source'],
        directParentManifest=I.pin(manifest),overrides=sorted(set(current['overrides'])|(changed&set(original))),
        inputs=[*current['inputs'],I.pin(manifest),current['source'],I.pin(Path(__file__)),I.pin(HERE/'literal-atoms.py'),
                I.pin(HERE/'audit-literal-atoms.py'),I.pin(inventory)],
        physicalLines=len(result.splitlines()),
        literalExposure=dict(reviewedOriginalCalls=421,actualReplacements=sum(r['count'] for r in rows),
            changedDeclarations=len(changed),sourceByteGrowth=len(result.encode())-len(old.encode()),
            declarationCountChange=0,proofDeclarationsUnchanged=sorted(PROOFS),
            exactCurrentFactoryBodies=True,unshadowedAtomName=True,rows=rows),
        scope='Current composition plus exact literal constructor exposure; no old declaration bodies replayed. Only reviewed original declaration set eligible. All91verifier and11proof declarations remain byte-identical to directparent. Existing final static-data verification/runtime contract remains authoritative. No new optimizer pass or native qualification.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(source=report['source'],exposure={k:v for k,v in report['literalExposure'].items() if k!='rows'})))

if __name__=='__main__':main()
