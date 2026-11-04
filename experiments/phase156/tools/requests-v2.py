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
    p.add_argument('--child-seconds',type=float,default=90)
    a=p.parse_args();require(1<=a.rounds<=4,'Bounded rounds required')
    prep=json.loads(a.manifest.read_text());spec=json.loads(a.inputs.read_text())
    controls=json.loads(a.controls.read_text());correction=json.loads(a.correction.read_text())
    require(controls['complete'] and correction['complete'] and correction['passed'],'Complete semantic controls required')
    failed=[r['name'] for r in controls['rows'] if not r['passed']]
    require(failed==['publication-duplicate-definition'],'Only explicitly corrected parser expectation may remain')
    require(correction['correctsOnly']==dict(report=pin(a.controls),row=failed[0]),'Correction must bind the exact failed row and receipt')
    require(correction['source']==controls['source'] and all(r['passed'] for r in correction['rows']),'Corrected source/rows differ')
    for identity in controls['inputs']+correction['inputs']: verify(identity)
    controlled={r['file']:r for r in controls['inputs']}
    for identity in prep['inputs']:
        if identity['file'].endswith(('/phase156/publication.bend','/phase156/uses.bend')):
            require(controlled.get(identity['file'])==identity,'Candidate module differs from semantic controls')
    require(0<a.child_seconds<=300,'Child limit must be at most300s')
    build=json.loads(Path(prep['buildReport']).read_text());checked=json.loads(Path(prep['apiReport']).read_text())
    require(build['complete'] and checked['complete'] and checked['checked'],'Checked native build required')
    require(build['request']['source']==prep['source']==checked['source'],'Source mismatch')
    binary=pin(prep['binary']);require(binary==build['binary'],'Binary changed')
    inputs=[pin(__file__),pin(a.manifest),pin(a.inputs),pin(a.controls),pin(a.correction),pin(prep['buildReport']),pin(prep['apiReport']),
        binary,prep['source'],*prep['inputs'],*build['inputs'],spec['base'],*[c['source'] for c in spec['cases']]]
    for x in inputs:verify(x)
    out=fresh_output(a.out,ROOT);start=time.monotonic()
    roles=a.roles.split(',');require('old' in roles and len(set(roles))==len(roles) and set(roles)<=set(['old','publication','uses','both']),'Explicit unique baseline and allowed roles')
    cases=[c for c in spec['cases'] if not a.cases or c['name'] in a.cases.split(',')]
    require(cases and (not a.cases or set(a.cases.split(','))=={c['name'] for c in cases}),'Unknown or empty case selection')
    result=dict(kind='phase156-actual-native-requests',complete=False,inputs=inputs,roles=roles,rounds=a.rounds,cases=[],calls=[],
        scope='Whole fresh child compiler process: live Base preparation, source loading/checking, lowering, verification, complete QBE writing and teardown. Same executable roles; no object build or generated-program execution. Independent qualified-image oracle time is separate.')
    def save():write_json(out/'report.json',result)
    save();oracles={};oracle_receipts={}
    qualified_image=pin(ROOT/'selfhost/build/phase152/native-n2/program')
    def accept_oracle(name,receipt_path,expected_product=None):
        receipt_identity=pin(receipt_path);record=json.loads(Path(receipt_path).read_text())
        case=next(c for c in cases if c['name']==name)
        require(record['complete'] and record['request']['target']=='qbe','Complete original QBE receipt required')
        require(record['request']['source']==case['source'] and record['request']['base']==spec['base'],'Oracle source/Base differ')
        require(record['request']['image']==qualified_image,'Oracle producer differs from qualified152N2')
        product=record.get('product',record.get('retainedIR'))
        require(isinstance(product,dict),'Exact retained oracle bytes required');verify(product)
        if expected_product is not None: require(product==expected_product,'Oracle product differs from nested receipt')
        inputs.extend([receipt_identity,product,qualified_image]);oracles[name]=product;oracle_receipts[name]=receipt_identity
    if a.oracles:
        previous=json.loads(a.oracles.read_text());require(previous['complete'],'Complete previous oracle receipt required')
        inputs.append(pin(a.oracles))
        for row in previous['cases']:
            if row['name'] not in {c['name'] for c in cases}:continue
            require(row['source']==next(c['source'] for c in cases if c['name']==row['name']),'Reused case source differs')
            nested=row.get('oracleReceipt',{}).get('file',str(Path(row['oracle']['file']).parent/'report.json'))
            accept_oracle(row['name'],nested,row['oracle'])
    try:
        for case in cases:
            require(time.monotonic()-start<a.seconds,'Campaign budget reached')
            if case.get('oracleReceipt'):
                verify(case['oracleReceipt']);accept_oracle(case['name'],case['oracleReceipt']['file'])
            if case['name'] not in oracles:
                ns=argparse.Namespace(workspace=ROOT,assets=ROOT/'selfhost/manifests/assets-native.json',image_key=None,
                    image=ROOT/'selfhost/build/phase152/native-n2/program',image_receipt=ROOT/'selfhost/build/phase152/native-n2/report.json',
                    source=Path(case['source']['file']),host='native',stage='N2',target='qbe',mode='live',base_key='base',carrier_key='prepared-base',engine_key='bun',
                    out=out/('oracle-'+case['name']),seconds=min(a.child_seconds,a.seconds-(time.monotonic()-start)),expected=None,plan=False)
                oracle=request.execute(ns);require(oracle['complete'],'Qualified original oracle failed')
                accept_oracle(case['name'],ns.out/'report.json',oracle['product'])
            entry=dict(name=case['name'],source=case['source'],oracle=oracles[case['name']],oracleReceipt=oracle_receipts[case['name']],rows=[],summary={});result['cases'].append(entry);save()
            for rnd in range(a.rounds):
                order=roles[rnd%len(roles):]+roles[:rnd%len(roles)]
                for role in order:
                    remaining=a.seconds-(time.monotonic()-start);require(remaining>1,'Campaign budget reached')
                    folder=out/(case['name']+'-'+str(rnd)+'-'+role);folder.mkdir()
                    product=folder/'program.ssa'
                    cmd=[binary['file'],'--threads','1','--gpu','off','--','transfer',spec['base']['file'],case['source']['file'],role,str(product)]
                    process=run(cmd,cwd=ROOT,stdout=folder/'stdout',stderr=folder/'stderr',seconds=min(a.child_seconds,remaining))
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
