#!/usr/bin/env python3
"""Counterbalanced checker observations bound to independently audited fixed oracles."""
import argparse, json, os, statistics, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin, verify, run, write_json, fresh_output, require
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--acquisition',type=Path,action='append',required=True)
p.add_argument('--suite',choices=['controls','checker','full'],required=True)
p.add_argument('--rounds',type=int,default=1)
p.add_argument('--seconds',type=float,default=30)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args(); require(1 <= a.rounds <= 4,'Rounds must be in1..4'); out=fresh_output(a.out,ROOT)
base=ROOT/'selfhost/.bootstrap/upstream-phase66/bend2/base.bend'
cases={'controls':['selfhost/tests/phase165/shared-cells-4.bend','selfhost/tests/phase165/copy-before-unfold-4.bend',
                  'tests/check/beta_ann_lambda.bend','tests/check/typed_let_mismatch.bend','selfhost/tests/phase162/unsafe-type-error.bend'],
       'checker':['selfhost/build/phase156/inputs01/checker.bend'],
       'full':['selfhost/build/phase152/composite01/compiler.bend']}[a.suite]
inputs=[pin(__file__),pin(ROOT/'selfhost/tools/build/common.py'),pin(base)]+[pin(ROOT/x) for x in cases]
# Bind the completed independent audit and every source/output/acquisition pin
# it checked. Future roles cannot establish their own easier expected verdict.
audit_path=ROOT/'experiments/phase165/memo-observation-audit.json'
audit=json.loads(audit_path.read_text());require(audit['complete'] and not audit['targetsRun'],'Independent audit incomplete')
inputs.append(pin(audit_path))
for item in audit['inputs']: verify(item); inputs.append(item)
baseline_path=ROOT/f'selfhost/build/phase165/memo-{a.suite}01/report.json'
require(pin(baseline_path) in audit['inputs'],'Baseline receipt absent from audited pins')
baseline=json.loads(baseline_path.read_text());require(baseline['complete'] and baseline['suite']==a.suite,'Wrong audited suite')
for path in [base]+[ROOT/x for x in cases]:
    require(pin(path) in baseline['inputs'],'Source/Base differs from independently audited workload')
for case in cases:
    require(any(x['suite']==a.suite and x['case']==case and x['role']=='original02' for x in audit['checks']),
            'Case lacks independent semantic gate')
oracles={case:baseline['oracles'][case] for case in cases}
original_command=next(x['process']['command'] for x in baseline['rows'] if x['role']=='original02')
original_binary=pin(original_command[0]);require(original_binary in baseline['inputs'],'Original image not in audited baseline')
roles=[]
for path in a.acquisition:
    receipt=json.loads(path.read_text());require(receipt['complete'] and receipt['kind']=='phase165-source-variant-acquisition','Acquisition incomplete/wrong kind')
    for item in receipt['inputs']: verify(item); inputs.append(item)
    binary=verify(receipt['binary']);inputs.extend([pin(path),pin(binary)])
    roles.append((path.parent.name,binary))
require(len(roles)>=2 and len(set(n for n,b in roles))==len(roles),'Distinct original and candidate roles required')
original=json.loads(a.acquisition[0].read_text())
require(original['original'] and original.get('exactOriginalC'),'First role must have exact original C')
for item in [original['expectedC'],original['emission']['stdout'],original['reusedExactMachineAcquisition']]:
    verify(item); inputs.append(item)
require(all(original['expectedC'][k]==original['emission']['stdout'][k] for k in ('bytes','sha256')),'Original C identity differs')
seed=json.loads(Path(original['reusedExactMachineAcquisition']['file']).read_text())
require(seed['complete'] and original['binary']==seed['binary']==original_binary,'Original is not the independently audited seed image')
env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ('LD_PRELOAD','LD_AUDIT')}
env.update(BEND_RC='0',BEND_NO_FREE='1',BEND_AUTO_PAR='0')
r=dict(kind='phase165-checker-comparison-v2',complete=False,inputs=inputs,rows=[],suite=a.suite,
       environment={k:v for k,v in env.items() if k.startswith('BEND_')}, independentAudit=pin(audit_path), auditedBaseline=pin(baseline_path),
       policy='Exact exit, stdout and stderr; a timeout or changed verdict is not a valid slowdown. CPU3 outer guard, one worker, GPU off.')
write_json(out/'report.json',r)
failed=False
for round_ in range(a.rounds):
    for ci,case in enumerate(cases):
        order=roles if round_%2==0 else list(reversed(roles))
        for name,binary in order:
            prefix=out/f'{round_}-{ci}-{name}'
            process=run([binary,'--threads','1','--gpu','off','--','--check-only',base,ROOT/case],cwd=ROOT,
                        stdout=Path(str(prefix)+'.stdout'),stderr=Path(str(prefix)+'.stderr'),seconds=a.seconds,env=env)
            signature={'exitCode':process.get('exitCode'),**{k:{f:process[k][f] for f in ('bytes','sha256')} for k in ('stdout','stderr')}}
            finished=not process.get('timedOut',False) and process.get('exitCode') in [0,1] and 'error' not in process
            match=finished and signature==oracles.get(case)
            row=dict(role=name,round=round_,case=case,process=process,exactOracle=match)
            r['rows'].append(row);r['oracles']=oracles
            write_json(out/'report.json',r)
            print(json.dumps({'role':name,'round':round_,'case':case,'seconds':process['seconds'],'exit':process.get('exitCode'),'exact':match}),flush=True)
            if not match:
                failed=True; break
        if failed: break
    if failed: break
r['complete']=not failed
r['medians']={case:{name:statistics.median(x['process']['seconds'] for x in r['rows'] if x['case']==case and x['role']==name) for name,_ in roles if any(x['case']==case and x['role']==name for x in r['rows'])} for case in cases}
for x in inputs:verify(x)
write_json(out/'report.json',r)
sys.exit(0 if r['complete'] else 1)
