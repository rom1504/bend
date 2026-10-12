#!/usr/bin/env python3
"""Source-only four-arm B1/B2 Numeric plan; diagnostic images never become releases."""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
RAW=ROOT/'selfhost/build/phase70'
inputs={}
def pin(p,expected=None):
 p=Path(p).resolve(strict=True);b=p.read_bytes();v=dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
 if expected:
  assert v['sha256']==expected['sha256'],p
  assert 'bytes' not in expected or v['bytes']==expected['bytes'],p
 inputs[str(p)]=v;return v
def read(p):return json.loads(Path(pin(p)['file']).read_text())
def verified(p):return pin(p['file'],p)
def main():
 ap=argparse.ArgumentParser(description=__doc__)
 ap.add_argument('--out',type=Path,required=True)
 a=ap.parse_args();assert os.sched_getaffinity(0)=={0}
 out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
 basefile=RAW/'compiler02-compilation01/plan.json';base=read(basefile)
 for item in base['inputs']:verified(item)
 attempt=read(base['attempt']['file']);assert attempt['checked'] and attempt['config']['strictExact']
 occfile=RAW/'occurrence-ablation-images01/derivation.json';readyfile=RAW/'observer-ready-ablation-images01/derivation.json'
 occ,ready=read(occfile),read(readyfile)
 for report in [occ,ready]:
  assert report['complete'] and report['dataOnly'] and not report['targetExecuted'] and not report['shippingCandidate'];verified(report['producer'])
 assert ready['occurrenceDerivation']['sha256']==pin(occfile)['sha256']
 arms=['current','occurrence-off','ordinary-skip','both'];variants={}
 for stage in ['b1','b2']:
  variants[(stage,'current')]=verified(base['roles'][stage]['api'])
 for row in occ['rows']:
  assert row['role'] in ['b1','b2'] and row['unchangedOutsideFunction'] and row['reverseRecoveryExact']
  original,output=verified(row['original']),verified(row['output']);verified(row['patch']);verified(row['previous'])
  assert original==variants[(row['role'],'current')]
  before=Path(original['file']).read_text();after=Path(output['file']).read_text()
  assert before.count(row['exactBefore'])==1 and after==before.replace(row['exactBefore'],row['exactAfter'],1)
  variants[(row['role'],'occurrence-off')]=output
 for row in ready['rows']:
  assert row['arm'] in ['ordinary-skip','both'] and row['reverseOriginalVerified'] and row['commutesWithOccurrenceAblation']
  assert verified(row['original'])==variants[(row['role'],'current')]
  assert verified(row['occurrenceOff'])==variants[(row['role'],'occurrence-off')]
  output=verified(row['output']);verified(row['patch']);edit=row['observerEdit']
  parent=variants[(row['role'],'occurrence-off' if row['arm']=='both' else 'current')]
  before=Path(parent['file']).read_text();after=Path(output['file']).read_text()
  assert before.count(edit['exactBefore'])==1 and after==before.replace(edit['exactBefore'],edit['exactAfter'],1)
  variants[(row['role'],row['arm'])]=output
 assert set(variants)=={(stage,arm) for stage in ['b1','b2'] for arm in arms}
 for p in [__file__,HERE/'analyze-factorial.py',HERE/'compilation/worker.mjs',HERE/'compilation/run.py']:pin(p)
 out.mkdir(parents=True);roles={};copies=[];snapshot=Path(attempt['snapshot']['root'])
 original_files={item['original']['file']:item['original'] for item in base['copies'] if '/b1/project/' in item['copy']['file']}
 assert len(original_files)==56
 for (stage,arm),api in variants.items():
  name=stage+'-'+arm;project=out/name/'project'
  for original in original_files.values():
   source=Path(verified(original)['file']);target=project/source.relative_to(snapshot)
   target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(source.read_bytes());copy_pin=pin(target);assert copy_pin['sha256']==original['sha256'];copies.append(dict(original=original,copy=copy_pin))
  roles[name]=dict(api=api,node=base['roles'][stage]['node'],base=base['roles'][stage]['base'],project=str(project),
   driver=pin(project/'tools/typed-driver.mjs'),runtime=pin(project/'src/runtime.mjs'),preparation=str(out/'runs'/('prepare-'+name)/'report.json'),
   stage=stage,arm=arm,diagnosticOnly=True,shippingCandidate=False,parentApi=base['roles'][stage]['api'])
 cases={'numeric':copy.deepcopy(base['cases']['numeric'])};oracle=verified(cases['numeric']['expected']['b1'])
 assert oracle==verified(cases['numeric']['expected']['b2'])
 cases['numeric']['expected']={role:oracle for role in roles}
 jobs=[dict(name='prepare-'+role,role=role,action='prepare',profile=False) for role in roles]
 for round_ in range(4):
  stages=['b1','b2'] if round_%2==0 else ['b2','b1']
  for stage in stages:
   shift=(round_+(2 if stage=='b2' else 0))%4;order=arms[shift:]+arms[:shift]
   for position,arm in enumerate(order):
    role=stage+'-'+arm;jobs.append(dict(name=f'clean-{round_}-numeric-{role}',role=role,action='request',case='numeric',profile=False,round=round_,stage=stage,arm=arm,position=position))
 for stage in ['b1','b2']:
  for arm in arms:assert sorted(j['position'] for j in jobs if j.get('stage')==stage and j.get('arm')==arm)==list(range(4))
 plan=dict(kind='phase68-native-compilation-plan',version=5,status='prepared-unexecuted',diagnosticOnly=True,shippingCandidate=False,
  producer=pin(__file__),parentPlan=pin(basefile),attempt=base['attempt'],imagePins=base['imagePins'],oracleAttempt=base['oracleAttempt'],oracleApi=base['oracleApi'],
  occurrenceDerivation=pin(occfile),ordinaryDerivation=pin(readyfile),copies=copies,roles=roles,cases=cases,jobs=jobs,
  cpu=3,nodeArgs=base['nodeArgs'],seconds=90,rssMiB=2048,availableMiB=4096,inputs=list(inputs.values()),
  scope='Diagnostic generated-image factorial only: four arms current02/occurrence-off/ordinary-skip/both, B1/B2, four complete position rotations perstage and alternating stage order. Eight fresh private Base caches then32 clean Numeric requests. Every request must emit the exact independently native-validated compiler02 C; any difference aborts and no changed-C timing is accepted. Existing worker/guard/oracle unchanged, no Clang/native repetition for byte-identical C. Imports and preparation excluded from request medians. No shipping candidate, checked-source provenance or full-corpus speed claim is granted to edited images.')
 with (out/'plan.json').open('x') as f:f.write(json.dumps(plan,indent=2)+'\n')
 print(json.dumps(dict(plan=pin(out/'plan.json'),preparations=8,cleanRequests=32,targetsExecuted=False)))
if __name__=='__main__':main()
