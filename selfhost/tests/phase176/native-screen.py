#!/usr/bin/env python3
"""Isolated fresh-process screen of exact prebuilt native workloads."""
import argparse
import json
import os
from pathlib import Path
import statistics
import sys
import time

ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,fresh_output,write_json,run
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--baseline',type=Path,required=True)
p.add_argument('--candidate',type=Path,required=True)
p.add_argument('--expected',type=Path,required=True)
p.add_argument('--rounds',type=int,default=6)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();require(2<=a.rounds<=12,'2–12 rounds required')
receipts={k:json.loads(getattr(a,k).read_text()) for k in ['baseline','candidate']}
inputs=[pin(__file__),pin(a.baseline),pin(a.candidate),pin(a.expected)]
for r in receipts.values():
    require(r['complete'] and not r['changedInputs'],'Complete unchanged image required')
    inputs.extend([r['binary'],r['runtime'],r['request']['source']])
require(receipts['baseline']['runtime']==receipts['candidate']['runtime'] and receipts['baseline']['toolchain']==receipts['candidate']['toolchain'],'Same runtime/toolchain required')
for x in inputs:verify(x)
out=fresh_output(a.out,ROOT);expected=a.expected.read_bytes()
env={k:v for k,v in os.environ.items()if not k.startswith('BEND_') and k not in ['LD_PRELOAD','LD_AUDIT','NODE_OPTIONS']}
report=dict(kind='phase176-native-workload-screen',complete=False,inputs=inputs,rows=[],scope='Whole fresh process includes construction, traversal, full-field digest and destruction. Isolated CPU affinity comes from outer guard. Hash is supplementary; independent complete-value controls are separate.')
start=time.monotonic()
try:
    for cycle in range(a.rounds):
        for role in (['baseline','candidate'] if cycle%2==0 else ['candidate','baseline']):
            file=out/(str(cycle)+'-'+role)
            row=run([receipts[role]['binary']['file'],'--threads','1','--gpu','off'],cwd=ROOT,stdout=file.with_suffix('.stdout'),stderr=file.with_suffix('.stderr'),seconds=10,env=env)
            row.update(role=role,cycle=cycle,outputExact=file.with_suffix('.stdout').read_bytes()==expected and file.with_suffix('.stderr').stat().st_size==0)
            report['rows'].append(row);write_json(out/'report.json',report)
            require(row['complete'] and row['outputExact'],'Native output mismatch')
    for x in inputs:verify(x)
    report['medians']={k:statistics.median(r['seconds'] for r in report['rows']if r['role']==k)for k in receipts}
    report['ratio']=report['medians']['candidate']/report['medians']['baseline']
    report['complete']=True
except Exception as error:report['error']=repr(error)
report['seconds']=time.monotonic()-start;write_json(out/'report.json',report)
print(json.dumps({k:report.get(k)for k in ['complete','seconds','medians','ratio','error']}))
if not report['complete']:raise SystemExit(1)
