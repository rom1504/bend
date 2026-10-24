"""Replay the measured Phase137 query composition onto the complete compiler.

Source packaging only: no compiler execution, changed verification, machine
build, or promotion. Every selected observer comes from the frozen v02 fixture.
"""
import argparse
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('p137q',HERE/'prepare-v01.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)
C=P.C
ORIGINALS=['lookup','f_find','nc_ctor_owned']
HELPERS=['p137q_name_eq','p137q_key_eq','p137q_is_cache','p137q_is_adt','p137q_is_ctr']

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase137')
    parent_path=ROOT/'selfhost/build/phase137/retain-source02/manifest.json'
    parent=json.loads(parent_path.read_text());src=Path(parent['source']['file'])
    assert parent['complete'] and C.pin(src)==parent['source']
    assert parent['source']['sha256']=='2bdb9bdff5a7eb04b017f9767cfd0ce359fc41bb620ba09c77afe142959be30d'
    fixture=HERE/'queries-fused-v02.bend';fm_path=HERE/'manifest-v02.json';fm=json.loads(fm_path.read_text())
    assert fm['complete'] and any(c['source']==C.pin(fixture)for c in fm['cases'])
    fb=C.blocks(fixture.read_text());before=src.read_text();old=C.blocks(before)
    # Copy only definition bodies. Existing laws/signatures remain in the parent.
    module='\n'.join(fb[n].rstrip()+'\n'for n in ORIGINALS+HELPERS)
    policy=ROOT/'selfhost/tools/performance/phase137/wide/controls-policy-v01.bend'
    expected=old['p131rg_controls'].replace('"region-wide-refused",Bool.not(p131rg_width(9))','"region-width-seventeen-refused",Bool.not(p131rg_width(17))')
    assert C.norm(expected)==C.norm(C.blocks(policy.read_text())['p131rg_controls'])
    text,added,protected=C.compose(before,[module,policy.read_text()],set(ORIGINALS+['p131rg_controls']),set())
    after=C.blocks(text)
    assert added==sorted(HELPERS)
    assert all(C.norm(after[n])==C.norm(fb[n])for n in ORIGINALS+HELPERS)
    assert all(C.norm(after[n])==C.norm(old[n])for n in old if n not in ORIGINALS+['p131rg_controls'])
    assert all(old[n]==after[n]for n in protected)
    assert 'p137q_kind_eq' not in after and 'p137q_checks' not in after
    for n in ['p113i_eligible','nol_fields','nol_ctor_fields','p131rg_width','p118b_project_borrow']:
        assert C.norm(old[n])==C.norm(after[n]),n
    selection_path=ROOT/'implementation/phase134/final/candidate.json';selected=json.loads(selection_path.read_text())
    assert selected['complete'] and selected['nativeQualified'] and C.pin(selected['source']['file'])==selected['source']
    qualified=C.blocks(Path(selected['source']['file']).read_text())
    wm_path=ROOT/'selfhost/build/phase137/wide-source01/manifest.json';wm=json.loads(wm_path.read_text())
    proofs=wm['unchangedProofDeclarations']
    assert all(qualified[n]==after[n]for n in proofs)
    changed=sorted(n for n in qualified if C.norm(qualified[n])!=C.norm(after[n]))
    assert changed==sorted(ORIGINALS+['nol_fields','nol_ctor_fields','p131rg_width','p118b_project_borrow','p113i_eligible','p131rg_controls'])
    out.mkdir(parents=True)
    (out/'compiler.bend').write_text(text)
    (out/'prepare.py').write_bytes(Path(__file__).read_bytes())
    (out/'module0.bend').write_text(module)
    (out/'module1.bend').write_bytes(policy.read_bytes())
    ledger=[]
    for name in changed:
        ledger.append(dict(declaration=name,qualifiedSha256=P.hashlib.sha256(C.norm(qualified[name]).encode()).hexdigest(),
            candidateSha256=P.hashlib.sha256(C.norm(after[name]).encode()).hexdigest(),
            category='source query composition'if name in ORIGINALS else 'width control update'if name=='p131rg_controls'else 'inline profitability'if name=='p113i_eligible'else 'bounded borrow admission'))
    report=dict(kind='phase137-integrated-query-observer-source',complete=True,checked=False,targetsRun=False,nativeQualified=False,selected=False,
        source=C.pin(out/'compiler.bend'),parent=parent['source'],parentManifest=C.pin(parent_path),qualified=selected['source'],qualifiedSelection=C.pin(selection_path),
        sourceManifest=C.pin(parent_path),runtime=selected['runtime'],checkedParent=selected['checkedApi'],
        overrides=ORIGINALS+['p131rg_controls'],added=added,allChangesFromQualified=ledger,
        protectedDeclarations=protected,unchangedProofDeclarations=proofs,
        controlEntries=[dict(name='p137w_controls',count=17),dict(name='p137qi_controls',count=20),dict(name='p131rg_controls',count=13)],
        exactFixtureDefinitions=ORIGINALS+HELPERS,excludedFixtureDefinitions=['p137q_kind_eq','p137q_checks','main'],
        physicalLines=len(text.splitlines()),parentLines=len(before.splitlines()),qualifiedLines=len(Path(selected['source']['file']).read_text().splitlines()),
        inputs=[C.pin(__file__),C.pin(HERE/'prepare-v01.py'),C.pin(C.__file__),C.pin(parent_path),parent['source'],C.pin(fixture),C.pin(fm_path),C.pin(policy),C.pin(wm_path),C.pin(selection_path),selected['source'],selected['runtime']],
        scope='Exactly three actual query declaration rewrites and five scalar helpers from frozen v02, on frozen width16+early-inline-retention producer. Only historical width-nine refusal control updates to seventeen. Production verifier/proofs/runtime/native entry preserved. Kernel timing is not a full-compiler speed result; checked API and native qualification remain required.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,source=report['source'],changed=len(changed),added=added,proofs=len(proofs))))
if __name__=='__main__':main()
