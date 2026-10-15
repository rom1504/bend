#!/usr/bin/env python3
"""Prepare independently chosen permission faults against unchanged laws."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
SPEC=ROOT/'selfhost/tools/laws/phase98/challenge/permission-candidate01.json'
CHECKER=ROOT/'selfhost/tools/laws/phase98/check.py'


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--proof-report',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT)and not out.exists()
    proof=json.loads(a.proof_report.read_text());spec=json.loads(SPEC.read_text())
    assert proof['complete']and proof['independentlyChecked']and not proof['opaqueDefinitions']
    assert 'foreign_permission_exact'in proof['lawNames']and pin(spec['source']['file'])==spec['source']
    frozen={}
    for row in proof['sourceClosure']:
        assert pin(row['snapshot']['file'])==row['snapshot']
        name=Path(row['origin']['file']).name;assert name not in frozen
        frozen[name]=Path(row['snapshot']['file']).read_bytes()
    body=frozen['candidate.bend'].decode();assert 'law 'not in body and '@unsafe'not in body
    out.mkdir(parents=True);jobs=[];cases=[]
    for case in spec['cases']:
        assert body.count(case['before'])==1
        folder=out/case['id'];folder.mkdir()
        for name,data in frozen.items():(folder/name).write_bytes(data)
        (folder/'candidate.bend').write_text(body.replace(case['before'],case['after'],1))
        helper=case['id']+'-helper'
        for name,entry,expected,purpose,requires in [
            (helper,'candidate.bend',0,'safe law-free helper admission',[]),
            (case['id']+'-law','laws.bend',1,'unchanged law semantic rejection',[helper])]:
            target=out/'checks'/name
            jobs.append(dict(name=name,source=pin(folder/entry),expectedExit=expected,purpose=purpose,
                             requires=requires,independentKernel=False,evidence=str(target/'report.json'),
                             command=[sys.executable,'-B',str(CHECKER),'--source',str(folder/entry),'--out',str(target),'--source-only']))
        cases.append(dict(id=case['id'],kind='bad',independentSpec=pin(SPEC),before=case['before'],after=case['after'],
                          adaptation='identity',candidate=pin(folder/'candidate.bend'),frozenLawsUnchanged=True,
                          contract=case['rationale'],witness=case['witness'],expected=case['expected'],mutant=case['mutant']))
    (out/'prepare-negatives.py').write_bytes(Path(__file__).read_bytes())
    plan=dict(schema='phase98-independent-formal-challenge-plan-v1',targetsRun=False,kind='late-permission',
              acceptedProof=pin(a.proof_report),method=pin(__file__),checker=pin(CHECKER),independentSpec=pin(SPEC),
              frozenSourceClosure=proof['sourceClosure'],cases=cases,jobs=jobs,
              files=[pin(path)for path in sorted(out.rglob('*.bend'))],
              interpretation=['Separately selected after positive acceptance, before reading this package laws/reference. Not part of original eight-bad/two-good catalog.',
                              'Only normal expected/observed mismatch after standalone helper admission counts as semantic rejection; never syntax or resource failures.',
                              'These source-check rejections do not assert independent kernel rejection or native ownership safety.'])
    (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
    print(json.dumps(dict(out=str(out),cases=len(cases),jobs=len(jobs),targetsRun=False)))


if __name__=='__main__':main()
