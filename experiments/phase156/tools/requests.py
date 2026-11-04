#!/usr/bin/env python3
"""Complete cold native request comparison, with exact independent QBE oracles."""
import argparse
import json
import statistics
import sys
import time
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import request
from common import fresh_output,pin,verify,require,run,same_bytes,write_json


def main():
    p=argparse.ArgumentParser()
    for name in ('manifest','inputs','controls','correction','out'):p.add_argument('--'+name,type=Path,required=True)
    p.add_argument('--oracles',type=Path)
    p.add_argument('--roles',default='old,publication,uses,both')
    p.add_argument('--cases',default='')
    p.add_argument('--rounds',type=int,default=1)
    p.add_argument('--seconds',type=float,default=240)
    a=p.parse_args();require(1<=a.rounds<=4,'Bounded rounds required')
    prep=json.loads(a.manifest.read_text());spec=json.loads(a.inputs.read_text())
    controls=json.loads(a.controls.read_text());correction=json.loads(a.correction.read_text())
    require(controls['complete'] and correction['complete'] and correction['passed'],'Complete semantic controls required')
    failed=[r['name'] for r in controls['rows'] if not r['passed']]
    require(failed==['publication-duplicate-definition'],'Only explicitly corrected parser expectation may remain')
    build=json.loads(Path(prep['buildReport']).read_text());checked=json.loads(Path(prep['apiReport']).read_text())
    require(build['complete'] and checked['complete'] and checked['checked'],'Checked native build required')
    require(build['request']['source']==prep['source']==checked['source'],'Source mismatch')
    binary=pin(prep['binary']);require(binary==build['binary'],'Binary changed')
    inputs=[pin(__file__),pin(a.manifest),pin(a.inputs),pin(a.controls),pin(a.correction),pin(prep['buildReport']),pin(prep['apiReport']),
        binary,prep['source'],*prep['inputs'],*build['inputs'],spec['base'],*[c['source'] for c in spec['cases']]]
    for x in inputs:verify(x)
    out=fresh_output(a.out,ROOT);start=time.monotonic()
    roles=a.roles.split(',');require('old' in roles and set(roles)<=set(['old','publication','uses','both']),'Explicit baseline and allowed roles')
    cases=[c for c in spec['cases'] if not a.cases or c['name'] in a.cases.split(',')]
    result=dict(kind='phase156-actual-native-requests',complete=False,inputs=inputs,roles=roles,rounds=a.rounds,cases=[],calls=[],
        scope='Whole fresh child compiler process: live Base preparation, source loading/checking, lowering, verification, complete QBE writing and teardown. Same executable roles; no object build or generated-program execution. Independent qualified-image oracle time is separate.')
    def save():write_json(out/'report.json',result)
    save();oracles={}
    if a.oracles:
        previous=json.loads(a.oracles.read_text());require(previous['complete'],'Complete previous oracle receipt required')
        inputs.append(pin(a.oracles))
        for row in previous['cases']:
            oracles[row['name']]=row['oracle'];verify(row['oracle']);inputs.append(row['oracle'])
    try:
        for case in cases:
            require(time.monotonic()-start<a.seconds,'Campaign budget reached')
            if case['name'] not in oracles:
                ns=argparse.Namespace(workspace=ROOT,assets=ROOT/'selfhost/manifests/assets-native.json',image_key=None,
                    image=ROOT/'selfhost/build/phase152/native-n2/program',image_receipt=ROOT/'selfhost/build/phase152/native-n2/report.json',
                    source=Path(case['source']['file']),host='native',stage='N2',target='qbe',mode='live',base_key='base',carrier_key='prepared-base',engine_key='bun',
                    out=out/('oracle-'+case['name']),seconds=min(90,a.seconds-(time.monotonic()-start)),expected=None,plan=False)
                oracle=request.execute(ns);require(oracle['complete'],'Qualified original oracle failed')
                oracles[case['name']]=oracle['product']
            entry=dict(name=case['name'],source=case['source'],oracle=oracles[case['name']],rows=[],summary={});result['cases'].append(entry);save()
            for rnd in range(a.rounds):
                order=roles[rnd%len(roles):]+roles[:rnd%len(roles)]
                for role in order:
                    remaining=a.seconds-(time.monotonic()-start);require(remaining>1,'Campaign budget reached')
                    folder=out/(case['name']+'-'+str(rnd)+'-'+role);folder.mkdir()
                    product=folder/'program.ssa'
                    cmd=[binary['file'],'--threads','1','--gpu','off','--','transfer',spec['base']['file'],case['source']['file'],role,str(product)]
                    process=run(cmd,cwd=ROOT,stdout=folder/'stdout',stderr=folder/'stderr',seconds=min(90,remaining))
                    row=dict(round=rnd,role=role,process=process,passed=False);entry['rows'].append(row);result['calls'].append(dict(case=case['name'],**row));save()
                    require(process['complete'] and process['exitCode']==0,'Compiler process failed')
                    require(process['stdout']['bytes']==0 and process['stderr']['bytes']==0,'Unexpected diagnostic output')
                    row['product']=pin(product);row['byteExact']=same_bytes(product,entry['oracle']['file'])
                    require(row['byteExact'],'Complete QBE differs from qualified original')
                    row['passed']=True;result['calls'][-1]=dict(case=case['name'],**row);save()
                    print(json.dumps(dict(case=case['name'],role=role,round=rnd,seconds=process['seconds'],byteExact=True)),flush=True)
            medians={role:statistics.median(r['process']['seconds'] for r in entry['rows'] if r['role']==role) for role in roles}
            entry['summary']=dict(medianSeconds=medians,ratios={role:value/medians['old'] for role,value in medians.items()});save()
        for x in inputs:verify(x)
        result['complete']=True
    except Exception as error:
        result['error']=repr(error);raise
    finally:
        result['elapsedSeconds']=time.monotonic()-start;save()


if __name__=='__main__':main()
