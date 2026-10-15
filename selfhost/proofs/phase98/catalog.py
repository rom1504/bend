#!/usr/bin/env python3
"""Inventory accepted Phase98 contracts without counting repeated checks as laws."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def digest(text):return hashlib.sha256(text.encode()).hexdigest()


def normalized(text):
    return '\n'.join(line.rstrip()for line in text.splitlines()if line.strip()and not line.lstrip().startswith('#'))+'\n'


def role(name):
    public={'consuming_equal_specification','held_observation_complete','held_comparison_preserves',
            'tag_comparison_preserves','retained_id_preserves','retained_quantity_preserves'}
    support={'consuming_equal_invariant','held_walk_equal','tag_read_matches_projection','provider_membership_exact'}
    if name in public or name.endswith('_preserves_ordered_dispatch') or name.startswith('foreign_permission_'):return 'public'
    if name in support or re.fullmatch(r'p98_.*_stage[0-9]+_ordered',name):return 'support'
    raise AssertionError(('Unclassified accepted law',name))


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();assert not a.out.exists()
    families={};reports=[]
    for path in sorted((ROOT/'selfhost/build/phase98').glob('*/report.json')):
        report=json.loads(path.read_text())
        if not(report.get('complete')and report.get('independentlyChecked')):continue
        assert not report['opaqueDefinitions']
        found=set()
        for closure in report['sourceClosure']:
            snapshot=closure['snapshot'];assert pin(snapshot['file'])==snapshot
            text=Path(snapshot['file']).read_text()
            for law in re.finditer(r'(?m)^law ([\w.]+):',text):
                name=law.group(1)
                definition=re.search(r'(?m)^def '+re.escape(name)+r'\(',text[law.end():]);assert definition
                start=law.end()+definition.start()
                following=re.search(r'(?m)^(?:law|def|type) ',text[start+1:])
                end=start+1+following.start()if following else len(text)
                statement=normalized(text[law.start():start]);body=normalized(text[start:end])
                found.add(name)
                family=families.setdefault(name,dict(name=name,role=role(name),statements={},proofBodies={},instances=[]))
                statement_sha,body_sha=digest(statement),digest(body)
                family['statements'][statement_sha]=statement;family['proofBodies'][body_sha]=body
                family['instances'].append(dict(report=pin(path),source=snapshot,statementSha256=statement_sha,bodySha256=body_sha,
                    closureIdentity=digest(json.dumps(report['sourceClosure'],sort_keys=True))))
        assert found==set(report['lawNames'])
        reports.append(dict(report=pin(path),lawNames=report['lawNames'],
                            source=report['source'],definitions=len(report['definitions']),opaqueDefinitions=[],
                            targetSeconds=sum(row['process']['wallSeconds']for row in report['rows'].values())))
    public=sum(x['role']=='public'for x in families.values());support=len(families)-public
    prior=[]
    for relative,pubs,sups,scope in [
        ('phase96/algebra-all03',14,7,'Base operations and unpromoted Phase94 environment helper'),
        ('phase96/representation-check03',17,0,'Exact representation helper bodies'),
        ('phase97/ownership-proof02',4,3,'Explicit ownership protocol model; no production runtime bridge')]:
        path=ROOT/'selfhost/build'/relative/'report.json';r=json.loads(path.read_text())
        assert r['complete']and r['independentlyChecked']and len(r['lawNames'])==pubs+sups
        prior.append(dict(report=pin(path),public=pubs,support=sups,scope=scope,lawNames=r['lawNames']))
    previous_names={name for row in prior for name in row['lawNames']}
    assert len(previous_names)==45 and not(previous_names&set(families))
    result=dict(kind='phase98-deduplicated-accepted-law-catalog',complete=True,targetsRun=False,method=pin(__file__),
        phase98=dict(public=public,support=support,distinctNames=len(families),
                     distinctStatements=sum(len(x['statements'])for x in families.values()),
                     distinctProofBodies=sum(len(x['proofBodies'])for x in families.values())),
        baseline=dict(public=35,support=10,distinctNames=45,packages=prior),
        combined=dict(public=35+public,support=10+support,distinctNames=45+len(families)),
        acceptedInstances=reports,laws=[families[k]for k in sorted(families)],
        interpretation=['Counts distinct named contracts/lemmas, not summed repeated check counts.',
                        'Statement and proof-body hashes omit blank lines and full-line comments only; source snapshots retain exact bytes.',
                        'Identical statement text across candidate modules is one contract schema with separately authenticated implementation instances, not one universal theorem across all future implementations.',
                        'Carrier and no-carrier held variants share public Bool statement but have distinct proof bodies; carrier-only complete observation remains a historical accepted contract.',
                        'The equivalent codepoint refactor changes one support proof body. Tag variants reuse identical proof/reference bodies against distinct helper implementations.',
                        'Baseline is the established Phase96+97 catalog only; earlier proof pilots and finite production/projection cases are not added to universal law counts.',
                        'Formal acceptance does not promote any native optimization or prove C ownership.'])
    a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(phase98=result['phase98'],baseline=result['baseline']|{'packages':len(prior)},combined=result['combined'])))


if __name__=='__main__':main()
