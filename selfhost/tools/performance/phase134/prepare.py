#!/usr/bin/env python3
"""Freeze exact Bend overlays on qualified Phase131; no compiler semantics here."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
METHOD = ROOT/'selfhost/tools/performance/phase131/prepare.py'
spec = importlib.util.spec_from_file_location('p134_composer', METHOD)
C = importlib.util.module_from_spec(spec); spec.loader.exec_module(C)
SELECTED = ROOT/'implementation/phase131/final/candidate.json'
ENTRY_ADAPTERS = {'p111_emit_admitted', 'p111_native_request'}

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--module',type=Path,action='append',required=True)
    ap.add_argument('--overrides',nargs='*',required=True)
    ap.add_argument('--entry-adapters',nargs='*',default=[])
    a=ap.parse_args(); out=a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase134'):
        raise ValueError('Fresh Phase134 source destination required')
    selected=json.loads(SELECTED.read_text())
    assert selected['nativeQualified'] and selected['source']['sha256']=='1bc5930edcf80cda6c3572645df3c846fa631a83c2b936f20c83b05e0a6728f9'
    for key in ('source','sourceManifest','checkedApi','runtime','runtimeReport'):
        assert C.pin(selected[key]['file'])==selected[key], key
    modules=[p.resolve() for p in a.module]
    assert len(set(modules))==len(modules)
    adapters=set(a.entry_adapters)
    assert adapters <= ENTRY_ADAPTERS and adapters <= set(a.overrides)
    # Only these explicitly audited routing/collection adapters may differ.
    # Every original structured/direct/array verifier remains protected.
    C.ENTRY_GATES -= adapters
    before=Path(selected['source']['file']).read_text()
    result,added,protected=C.compose(before,[p.read_text() for p in modules],set(a.overrides),set())
    old,new=C.blocks(before),C.blocks(result)
    proofs=selected['proofScope']['exactDeclarations']
    assert all(C.norm(old[n])==C.norm(new[n]) for n in proofs)
    out.mkdir(parents=True)
    (out/'compiler.bend').write_text(result)
    (out/'prepare.py').write_bytes(Path(__file__).read_bytes())
    for i,p in enumerate(modules): (out/f'module{i}.bend').write_bytes(p.read_bytes())
    report=dict(kind='phase134-exact-source-overlay',complete=True,checked=False,targetsRun=False,
        source=C.pin(out/'compiler.bend'),parent=selected['source'],parentSelection=C.pin(SELECTED),
        sourceManifest=selected['sourceManifest'],overrides=a.overrides,added=added,
        entryAdapters=sorted(adapters),protectedDeclarations=protected,unchangedProofDeclarations=proofs,
        changedDeclarations=sorted(n for n in old if C.norm(old[n])!=C.norm(new[n])),
        adapterBodies={n:dict(before=old[n],after=new[n]) for n in sorted(adapters)},
        inputs=[C.pin(__file__),C.pin(METHOD),C.pin(SELECTED),selected['source'],selected['sourceManifest'],
                selected['checkedApi'],selected['runtime'],selected['runtimeReport'],*[C.pin(p) for p in modules]],
        physicalLines=len(result.splitlines()),parentLines=len(before.splitlines()),
        scope='Exact declared source composition only. Entry adapters are separately listed, not claimed unchanged. Original verifiers and connected proof declarations remain unchanged; source checking and native qualification are separate.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report['source']))

if __name__=='__main__': main()
