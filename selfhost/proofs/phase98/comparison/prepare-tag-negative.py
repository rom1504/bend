#!/usr/bin/env python3
"""Snapshot the separately selected generic-tag/name fault; no target runs."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
SPEC=ROOT/'selfhost/tools/laws/phase98/challenge/tag-candidate04.json'
CHECKER=ROOT/'selfhost/tools/laws/phase98/check.py'


def pin(path):
    path=Path(path).resolve(); data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--proof-report',required=True,type=Path)
    p.add_argument('--out',required=True,type=Path)
    a=p.parse_args(); out=a.out.resolve()
    assert out.is_relative_to(ROOT) and not out.exists()
    proof=json.loads(a.proof_report.read_text()); spec=json.loads(SPEC.read_text())
    assert proof['complete'] and proof['independentlyChecked'] and not proof['opaqueDefinitions']
    assert 'tag_comparison_preserves' in proof['lawNames']
    source_pin=pin(ROOT/spec['source']['path'])
    assert source_pin['sha256']==spec['source']['sha256'] and source_pin['bytes']==spec['source']['bytes']
    frozen={}
    for row in proof['sourceClosure']:
        assert pin(row['snapshot']['file'])==row['snapshot']
        name=Path(row['origin']['file']).name; assert name not in frozen
        frozen[name]=Path(row['snapshot']['file']).read_bytes()
    body=frozen['candidate.bend'].decode()
    before,after=spec['before'],spec['after']; adaptation='identity'
    if before not in body:
        before='      p88_string_eq_go(tag, key, True{})'
        after='      p88_string_eq_go(name, key, True{})'
        adaptation='Transfer identical generic-field substitution tag->name to v4 private walker call; preserve key, True flag, all other branches and all proof/reference bytes.'
    assert body.count(before)==1
    out.mkdir(parents=True); folder=out/spec['id'];folder.mkdir()
    for name,data in frozen.items(): (folder/name).write_bytes(data)
    (folder/'candidate.bend').write_text(body.replace(before,after,1))
    jobs=[]; helper=spec['id']+'-helper'
    for name,entry,expected,purpose,requires in [
        (helper,'candidate.bend',0,'safe law-free helper admission',[]),
        (spec['id']+'-law','tag.bend',1,'unchanged law semantic rejection',[helper])]:
        target=out/'checks'/name
        jobs.append(dict(name=name,source=pin(folder/entry),expectedExit=expected,purpose=purpose,
                         requires=requires,independentKernel=False,evidence=str(target/'report.json'),
                         command=[sys.executable,'-B',str(CHECKER),'--source',str(folder/entry),'--out',str(target),'--source-only']))
    (out/'prepare-tag-negative.py').write_bytes(Path(__file__).read_bytes())
    plan=dict(schema='phase98-independent-formal-challenge-plan-v1',targetsRun=False,
              kind='late-candidate-specific-tag',acceptedProof=pin(a.proof_report),method=pin(__file__),checker=pin(CHECKER),
              independentSpec=pin(SPEC),cases=[dict(id=spec['id'],kind='bad',independentSpec=pin(SPEC),
              adaptation=adaptation,before=before,after=after,candidate=pin(folder/'candidate.bend'),
              frozenLawsUnchanged=True,contract=spec['expectedBehavior'])],jobs=jobs,
              files=[pin(path)for path in sorted(out.rglob('*.bend'))],
              interpretation=['Separate later candidate-specific selection. Never add to the original eight-bad/two-good score.',
                              'Admit the helper first; only expected/observed proof mismatch counts, never syntax or resource failure.',
                              'Negative laws are source-check rejection, not independent kernel rejection.'])
    (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
    print(json.dumps(dict(out=str(out),cases=1,jobs=2,targetsRun=False)))


if __name__=='__main__':main()
