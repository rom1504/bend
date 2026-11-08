#!/usr/bin/env python3
"""Time authenticated native frontend images; no compiler semantics here."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import statistics
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,fresh_output,write_json

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--baseline',type=Path,required=True)
p.add_argument('--candidate',type=Path)
p.add_argument('--binding',type=Path,required=True)
p.add_argument('--source',type=Path,action='append',required=True)
p.add_argument('--mode',choices=['parse','check','context','annotation','request'],required=True)
p.add_argument('--rounds',type=int,choices=[1,2,4],default=1)
p.add_argument('--seconds',type=float,default=120)
p.add_argument('--expected',type=Path)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=fresh_output(a.out,ROOT)
receipts={'baseline':json.loads(a.baseline.read_text())}
if a.candidate:receipts['candidate']=json.loads(a.candidate.read_text())
binding=json.loads(a.binding.read_text())
inputs=[pin(__file__),pin(a.baseline),pin(a.binding),binding['base'],binding['carrier']]+[pin(x)for x in a.source]
if a.candidate:inputs.append(pin(a.candidate))
for row in receipts.values():
    require(row['complete'] and row['kind'] in ('bend-native-build','phase181-native-assembly-build') and not row['changedInputs'],'Successful native image required')
    inputs.extend([row['binary'],row['runtime'],(row['request']['source'] if 'request' in row else row['source'])])
require(all(r['runtime']==receipts['baseline']['runtime'] and r['toolchain']==receipts['baseline']['toolchain']for r in receipts.values()),'Runtime/toolchain differ')
expected={}
if a.expected:
    prior=json.loads(a.expected.read_text());require(prior['complete'] and prior['mode']==a.mode,'Expected successful same-mode observation')
    inputs.append(pin(a.expected))
    for row in prior['runs']:
        require(row['outputExact'],'Previous output failed');verify(row['stdout']);expected[row['source']['sha256']]=Path(row['stdout']['file']).read_bytes()
for item in inputs:verify(item)
env={k:v for k,v in os.environ.items()if not k.startswith('BEND_')and k not in ['LD_PRELOAD','LD_AUDIT','NODE_OPTIONS']}
report=dict(kind='phase181-native-frontend-pair',complete=False,inputs=inputs,mode=a.mode,rounds=a.rounds,runs=[],scope='Whole fresh process includes reads, Base setup, frontend, digest and teardown. Frontend clock excludes structural digest. Digests are supplementary observations, not independent semantic equivalence or self-build timings.')
def save():write_json(out/'report.json',report)
start=time.monotonic();save()
try:
    for source in a.source:
        source=source.resolve();identity=pin(source)
        for cycle in range(a.rounds):
            roles=list(receipts)
            if cycle%2:roles.reverse()
            for role in roles:
                image=receipts[role]['binary'];verify(image)
                command=[image['file'],'--threads','1','--gpu','off','--','phase175-frontend',a.mode,str(source),binding['base']['file'],binding['carrier']['file'],binding['stamp']]
                begin=time.monotonic();result=subprocess.run(command,cwd=ROOT,env=env,capture_output=True,timeout=a.seconds);seconds=time.monotonic()-begin
                stem=f'{len(report["runs"]):03}-{role}'
                so=out/(stem+'.stdout');se=out/(stem+'.stderr');so.write_bytes(result.stdout);se.write_bytes(result.stderr)
                match=re.fullmatch(rb'phase175 base_ms=(\d+) frontend_ms=(\d+) observation_ms=(\d+)\n',result.stderr)
                okay=result.returncode==0 and match is not None and re.fullmatch(rb'phase175 frontend '+a.mode.encode()+rb' hash=\d+\n',result.stdout)is not None
                key=identity['sha256']
                if key not in expected:
                    require(role=='baseline','Baseline must establish supplementary output first');expected[key]=result.stdout
                okay=okay and expected[key]==result.stdout
                row=dict(role=role,cycle=cycle,source=identity,command=command,seconds=seconds,exitCode=result.returncode,stdout=pin(so),stderr=pin(se),outputExact=okay)
                if match:row.update(baseSeconds=int(match[1])/1000,frontendSeconds=int(match[2])/1000,observationSeconds=int(match[3])/1000)
                report['runs'].append(row);save();require(okay,'Native observation mismatch: '+stem)
    report['cases']=[]
    for source in a.source:
        identity=pin(source);rows=[r for r in report['runs']if r['source']==identity]
        summary={k:{field:statistics.median(r[field]for r in rows if r['role']==k)for field in ['seconds','frontendSeconds','baseSeconds','observationSeconds']}for k in receipts}
        case=dict(source=identity,medians=summary)
        if a.candidate:
            case['wholeProcessRatio']=summary['candidate']['seconds']/summary['baseline']['seconds']
            case['frontendRatio']=summary['candidate']['frontendSeconds']/max(.001,summary['baseline']['frontendSeconds'])
        report['cases'].append(case)
    for item in inputs:verify(item)
    report['complete']=True
except Exception as error:report['error']=repr(error)
finally:
    report['seconds']=time.monotonic()-start;save();print(json.dumps({k:report[k]for k in ['complete','seconds','cases','error']if k in report}))
if not report['complete']:raise SystemExit(1)
