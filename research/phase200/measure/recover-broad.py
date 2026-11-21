#!/usr/bin/env python3
"""Authenticate complete captured observations from an interrupted final report."""
import argparse,copy,importlib.util,json,sys
from pathlib import Path
from types import SimpleNamespace
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p200_screen_recovery',HERE/'screen.py');M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M);B=M.B
p=argparse.ArgumentParser();p.add_argument('--run',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args();run=a.run.resolve();out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
original_pin=B.pin(run/'timing/report.json');original=B.read(original_pin['file']);guard_pin=B.pin(run.with_name(run.name+'-guard')/'process.json');guard=B.read(guard_pin['file']);retention_pin=B.pin(run.with_name(run.name+'-guard')/'retention.json');retention=B.read(retention_pin['file'])
assert not original['complete'] and not guard['complete'] and guard['returncode']!=0 and guard['stoppedFor']=='disk-budget' and retention['closed']
manifest=B.read(run/'manifest.json');prep=B.read(run/'preparation.json');assert prep['complete'] and prep['manifest']==B.pin(run/'manifest.json')
for pin in original['inputs']:B.verify(pin)
for pin in prep['inputs']:B.verify(pin)
assert original['roles']==manifest['roles'] and list(original['roles'])==['c','baseline','candidate'] and original['rounds']==3 and original['targetMs']==140 and original['minimumAcceptedMs']==100
fixed={c['id']:c for c in manifest['cases']};assert len(fixed)==len(original['cases'])==45 and original['selectedCaseIds']==list(fixed)
roles=list(original['roles']);counts=dict(pilots=0,samples=0,preflights=0);minimum=None
for ci,case in enumerate(original['cases']):
 item=fixed[case['id']];assert case['point']==item['point'] and len(case['samples'])==9
 expected_order=[role for ri in range(3) for role in roles[(ci+ri)%3:]+roles[:(ci+ri)%3]];assert [r['role'] for r in case['samples']]==expected_order
 for index,row in enumerate(case['samples']):assert row['round']==index//3 and row['repetitions']==case['calibration'][row['role']]
 for stage in ('pilots','samples'):
  for row in case[stage]:
   proc=row['process'];role=row['role'];point=dict(case['point'],repetitions=row['repetitions']);product=item['products'][role]
   expected=[product['artifact']['file'],*B.native_runtime_arguments(product),str(row['repetitions']),str(point['warmups']),*map(str,point['runtimeArgs'])]
   assert row['correct'] and row['warmups']==point['warmups'] and proc['command']==expected and proc['exitCode']==0 and not proc['timedOut']
   elapsed=B.observation(M.checked_bytes(proc['stdout']),M.checked_bytes(proc['stderr']),proc['exitCode'],point,proc['seconds'])
   assert elapsed==row['elapsedMs'] and elapsed/row['repetitions']==row['metricMs']
   if stage=='samples' and point['ratioEligible']:
    assert elapsed>=100 and not row['lowResolution'];minimum=elapsed if minimum is None else min(minimum,elapsed)
   counts[stage]+=1
 for role,check in prep['cases'][case['id']]['oracles'].items():
  proc=check['process'];point=dict(case['point'],repetitions=int(case['point']['repetitions']>0),warmups=0);product=item['products'][role]
  expected=[product['artifact']['file'],*B.native_runtime_arguments(product),str(point['repetitions']),'0',*map(str,point['runtimeArgs'])]
  assert proc['command']==expected and proc['exitCode']==0 and not proc['timedOut']
  elapsed=B.observation(M.checked_bytes(proc['stdout']),M.checked_bytes(proc['stderr']),proc['exitCode'],point,proc['seconds']);assert elapsed==check['elapsedMs'];counts['preflights']+=1
assert counts['samples']==405 and counts['preflights']==135
recovered=copy.deepcopy(original)
for case in recovered['cases']:
 summary=B.summary(case['samples'],roles,'c',3,case['point']['ratioEligible']);assert summary['complete'] and (not summary['ratioEligible'] or summary['ratios'] is not None);summary['admitted']=True;case['summary']=summary
recovered['aggregate']=B.aggregate(recovered['cases'],roles,'c')
provenance=dict(originalReport=original_pin,guard=guard_pin,retention=retention_pin,guardSucceeded=False,method=B.pin(__file__),counts=counts,minimumEligibleTimedMs=minimum,scope='Offline reconstruction from already captured complete original streams. Original execution guard failed disk-budget; original receipt is untouched. No rerun, fabricated sample, successful-guard claim, or measured full harness duration.')
recovered.update(complete=True,changedInputs=[],reconstructedOffline=True,executionGuardSucceeded=False,recovery=provenance)
recovered['inputs']=B.unique_inputs([*original['inputs'],original_pin,guard_pin,retention_pin,B.pin(__file__)])
recovered['scope']=provenance['scope']+' '+original['scope'];B.save(out/'reconstructed-report.json',recovered,fresh=True)
s=M.S.S.summarize(SimpleNamespace(report=out/'reconstructed-report.json',references=run/'manifest.json',c_role='c',baseline_role='baseline',spread_limit=1.10,emission=[]))
assert s['subsets']['all']['caseCount']==45 and s['subsets']['all']['ratioEligibleCount']==44 and s['oracleRevalidated']['samples']==405
for case in s['cases']:assert all(case['artifacts'][role]==fixed[case['id']]['products'][role]['artifact'] for role in roles)
s.update(kind='phase200-recovered-observations-summary',completeObservedEvidence=True,executionGuardSucceeded=False,recovery=provenance,plan=prep['plan'],preparation=B.pin(run/'preparation.json'),source=manifest['roles']['candidate']['compilerSource'],runtime=manifest['roles']['candidate']['runtime'])
s['warnings'].insert(0,'Physical guard failed disk-budget after all405 timed observations were checkpointed; this is independent offline recovery, not a successful physical-run receipt.')
s['scope']=provenance['scope']+' '+s['scope'];assert B.pin(original_pin['file'])==original_pin
B.save(out/'summary.json',s,fresh=True);(out/'summary.md').write_text(M.S.markdown(s).replace('# Phase193 runtime summary','# Phase200 recovered observations',1));print(json.dumps(dict(summary=str(out/'summary.json'),counts=counts,minimumEligibleTimedMs=minimum,candidate=s['subsets']['all']['roles']['candidate'],warnings=s['warnings'])))
