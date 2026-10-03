#!/usr/bin/env python3
"""Require three complete exact-preset batches covering full45; infer no admission."""
import argparse,hashlib,json
from pathlib import Path
BASE_API='9900abf49719575db7f7bbee32c6b16e10bcd554f9de22cde0799eb859cc6f0b'
PIN='018751270e800bc222a93dad7f257083ee53a5f7'
def ident(p):
 p=Path(p).resolve();return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(row):
 p=row.get('file',row.get('path'));assert p and ident(p)['sha256']==row['sha256'],p
 return ident(p)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('plan',type=Path);p.add_argument('out',type=Path);a=p.parse_args();assert not a.out.exists();plan=json.loads(a.plan.read_text());assert plan['kind']=='phase42-full45-serial-runtime-batches' and plan['complete'] and plan['bound'] and not plan['executed']
 for k in ['producer','parent','measurementBinding','attempt','api','nodeIdentity','baseline','candidate','catalog']:verify(plan[k])
 b=json.loads(Path(plan['measurementBinding']['file']).read_text());candidate=json.loads(Path(plan['candidate']['file']).read_text());baseline=json.loads(Path(plan['baseline']['file']).read_text())
 assert b['complete'] and b['attempt']['sha256']==plan['attempt']['sha256'] and b['api']==plan['api'] and b['node']==plan['nodeIdentity'];assert plan['expectedSamples']==669
 catalog=json.loads(Path(plan['catalog']['file']).read_text());points={x['id']:x['point'] for x in catalog['cases']}
 assert plan['selectedIds']==catalog['sets']['full']
 cases=[];receipts=[]
 for batch in plan['batches']:
  report_path=Path(batch['report']);r=json.loads(report_path.read_text());assert r['kind']=='bend-program-execution-report' and r['complete'] is True and r['pass'] is True and r['status']=='measured'
  q=r['plan'];assert q['budgetSeconds']==600 and q['selectedIds']==batch['ids'] and q['roles']==plan['roles'] and q['protocol']==plan['protocol'] and q['cpu']==3 and q['heapMiB']==1024 and q['rssMiB']==q['availableMiB']==2048 and q['node']==plan['node']
  assert q['variants']['candidate']['compiler']==candidate['roles']['candidate']['compiler'] and q['variants']['baseline']['compiler']==baseline['roles']['baseline']['compiler'] and q['variants']['typescript']['compiler']==baseline['roles']['typescript']['compiler']
  assert q['variants']['candidate']['compiler']['api']['sha256']==plan['api']['sha256'] and q['variants']['baseline']['compiler']['api']['sha256']==BASE_API and q['variants']['typescript']['compiler']['upstreamCommit']==PIN
  assert r['selectedCases']==15 and [c['id'] for c in r['cases']]==batch['ids'];count=0
  for row in r['cases']:
   assert row['point']==points[row['id']]
   rounds=3 if row['id']=='raytrace' else 5;assert row['rounds']==rounds and row['summary']['complete'] is True and row['summary']['balancedRounds']==list(range(rounds)) and len(row['samples'])==3*rounds
   assert [(x['round'],x['role']) for x in row['samples']]==[(n,role) for n in range(rounds) for role in plan['roles'][n%3:]+plan['roles'][:n%3]]
   assert {(x['round'],x['role']) for x in row['samples']}=={(n,role) for n in range(rounds) for role in plan['roles']}
   for sample in row['samples']:
    assert sample['complete'] is True and sample['process']['complete'] is True and sample['process']['returncode']==0 and not sample['process'].get('stoppedFor') and sample['result']['complete'] is True
   cases.append(dict(id=row['id'],point=row['point'],rounds=rounds,summary=row['summary'],report=ident(report_path)));count+=len(row['samples'])
  assert count==batch['samples'];receipts.append(ident(report_path))
  nodeInputs=[x for x in r['inputs'] if Path(x.get('file',x.get('path',''))).resolve()==Path(plan['nodeIdentity']['file']).resolve()]
  assert len(nodeInputs)==1 and nodeInputs[0]['sha256']==plan['nodeIdentity']['sha256']
  for row in r['inputs']:verify(row)
 assert [c['id'] for c in cases]==plan['selectedIds'] and len(cases)==len({c['id'] for c in cases})==45 and sum(3*c['rounds'] for c in cases)==669
 result=dict(kind='phase42-full45-serial-runtime-closure',complete=True,**{'pass':True},performanceAdmitted=False,attempt=plan['attempt'],api=plan['api'],producer=ident(__file__),plan=ident(a.plan),reports=receipts,protocol=plan['protocol'],executionPolicy=plan['executionPolicy'],selectedCases=45,samples=669,cases=cases)
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,selectedCases=45,samples=669,performanceAdmitted=False)))
if __name__=='__main__':main()
