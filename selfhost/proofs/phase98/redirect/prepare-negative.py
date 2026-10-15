#!/usr/bin/env python3
"""Late targeted early-stop fault; helper admission then unchanged-law rejection."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
CHECKER=ROOT/'selfhost/tools/laws/phase98/check.py'


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--proof-report',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT)and not out.exists()
    proof=json.loads(a.proof_report.read_text())
    assert proof['complete']and proof['independentlyChecked']and not proof['opaqueDefinitions']
    frozen={}
    for row in proof['sourceClosure']:
        assert pin(row['snapshot']['file'])==row['snapshot']
        name=Path(row['origin']['file']).name;assert name not in frozen
        frozen[name]=Path(row['snapshot']['file']).read_bytes()
    body=frozen['candidate.bend'].decode()
    before='no_scalar_redirect(rest, owner, roots)'
    after='nt_choose(List<&2, NF_Worker>, p88_string_eq(name, owner), u => rest, u => no_scalar_redirect(rest, owner, roots))'
    binder='case Con{+worker, rest}:';shared='case Con{+worker, +rest}:'
    assert body.count(before)==1 and body.count(binder)==1
    mutant=body.replace(binder,shared,1).replace(before,after,1)
    out.mkdir(parents=True);case_id='redirect-late01-stop-after-first-hit';folder=out/case_id;folder.mkdir()
    for name,data in frozen.items():(folder/name).write_bytes(data)
    (folder/'candidate.bend').write_text(mutant)
    spec=dict(id=case_id,kind='bad',before=before,after=after,
              affineAnnotation=dict(before=binder,after=shared),
              witness='Two equal complete NF_Worker values with name="owner", empty params/deps, NC_Code{NC_Empty{},Nil{},0,"",Nil{}}, arbitrary KLiteral shape; owner="owner", roots=Nil{}.',
              expected='Original and accepted candidate prepend the redirect and adapter dependency to both workers.',
              mutant='Only the first matching worker changes; the second matching worker is returned untouched.',
              selection='Late candidate-specific fault authored by the proof author after positive proof acceptance at root request. Not independently selected and not part of the original eight-bad/two-good catalog.',
              domain='Valid typed helper list; no assertion that duplicate worker names arise from every checked compiler route.')
    (out/'challenge.json').write_text(json.dumps(spec,indent=2)+'\n');jobs=[];helper=case_id+'-helper'
    for name,entry,expected,purpose,requires in [
        (helper,'candidate.bend',0,'safe law-free helper admission',[]),
        (case_id+'-law','proof.bend',1,'unchanged law semantic rejection',[helper])]:
        target=out/'checks'/name
        jobs.append(dict(name=name,source=pin(folder/entry),expectedExit=expected,purpose=purpose,
                         requires=requires,independentKernel=False,evidence=str(target/'report.json'),
                         command=[sys.executable,'-B',str(CHECKER),'--source',str(folder/entry),'--out',str(target),'--source-only']))
    (out/'prepare-negative.py').write_bytes(Path(__file__).read_bytes())
    plan=dict(schema='phase98-independent-formal-challenge-plan-v1',targetsRun=False,kind='late-targeted-redirect',
              acceptedProof=pin(a.proof_report),method=pin(__file__),checker=pin(CHECKER),
              cases=[dict(**spec,independentSpec=pin(out/'challenge.json'),adaptation='identity; explicit +rest is required by the two branch captures',
                          candidate=pin(folder/'candidate.bend'),frozenLawsUnchanged=True,contract=spec['expected'])],
              jobs=jobs,files=[pin(path)for path in sorted(out.rglob('*.bend'))],
              interpretation=[spec['selection'],'Admit the helper first; credit only normal semantic expected/observed law mismatch, not syntax, affinity or resource failure.',
                              'Historical runner schema name is reused; this plan explicitly does not claim independent selection.'])
    (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
    print(json.dumps(dict(out=str(out),cases=1,jobs=2,targetsRun=False)))


if __name__=='__main__':main()
