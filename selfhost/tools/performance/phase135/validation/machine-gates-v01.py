#!/usr/bin/env python3
"""Adapt the frozen Phase132 small compiler/ordinary gates; no new compiler.

Prepare only after the three B images and producer-status join are complete.
Execution delegates to the existing bounded ordered-gate runner under root guard.
"""
import argparse
import importlib.util
import json
import math
import os
from pathlib import Path
import re
import subprocess
import sys

sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
METHOD=ROOT/'selfhost/tools/performance/phase130/native-request.py'
spec=importlib.util.spec_from_file_location('native',METHOD);N=importlib.util.module_from_spec(spec);spec.loader.exec_module(N)
pin,verify,require=N.pin,N.verify,N.require
RUNNER=ROOT/'selfhost/tools/performance/phase132/incremental/run-gates.py'
BUILDER=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'


def read(path):return json.loads(Path(path).read_text())


def write(path,data):
    path.parent.mkdir(parents=True,exist_ok=True);path.write_text(json.dumps(data,indent=2)+'\n')


def prepare(a):
    out=a.out.absolute();require(out==out.resolve() and not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase135'),'Fresh real Phase135 plan directory required')
    require(re.fullmatch('[a-z0-9-]+',out.name) is not None,'Simple artifact prefix required')
    old_path=ROOT/'selfhost/build/phase132/object-output-gates01/plan.json';old=read(old_path)
    old_run_path=ROOT/'selfhost/build/phase132/object-output-gates01-executed/report.json';old_run=read(old_run_path)
    require(old['complete'] and old_run['complete'] and old_run['planSha256']==pin(old_path)['sha256'] and len(old_run['jobs'])==15,'Frozen Phase132 semantic evidence missing')
    for job,command in zip(old_run['jobs'],old['commands']):
        require(job['name']==command['name'] and job['command']==command['argv'] and job['returncode']==0,'Historical semantic gate mismatch')
    edited_path=ROOT/'selfhost/build/phase130/p132-edited-full01/report.json';edited=read(edited_path)
    require(edited['complete'],'Independent full B oracle required')
    roles={role:read(getattr(a,role))for role in ['monolithic','cold','warm']}
    for role,build in roles.items():require(build['complete'],'Incomplete '+role+' build');verify(build['binary'])
    mono=roles['monolithic'];require(mono['kind']=='phase123-branch-aligned-qbe-build' and edited['product']in mono['inputs'],'Monolithic B must build exact independent full B QBE')
    cold,warm=roles['cold'],roles['warm']
    for role in ['cold','warm']:
        build=roles[role]
        require(build['kind']=='phase135-framed-machine-build' and build['source']==edited['source'] and build['payloadDigest']=={k:edited['product'][k]for k in ['bytes','sha256']},'Wrong framed B product')
        require(build['expectedPayloadExact'],'Framed B lacks independent complete-QBE check')
    require(cold['context']==warm['context'] and cold['cold'] and not warm['cold'] and cold['cache']!=warm['cache'] and cold['reusedUnits']==0,'Independent cold/current warm comparison required')
    runtime=warm['context']['runtime'];require(runtime in mono['inputs'],'Runtime differs between compiler images')
    comparison=read(a.comparison)
    require(comparison['complete'] and comparison['allocatedSectionsExact'] and comparison['headersExact'] and comparison['cached']==warm['binary'] and comparison['fresh']==cold['binary'],'Exact current machine comparison required')
    require(pin(a.warm)in comparison['inputs'] and pin(a.cold)in comparison['inputs'],'Machine comparison not bound to current reports')
    joined=read(a.producer_join)
    require(joined['complete'] and joined['producerExitCode']==0 and joined['producer']==warm['context']['producer'],'Successful exact framed producer required')
    require(edited['source']in joined['sources'] and pin(a.warm)in joined['machineReports'],'Producer join does not bind current B and machine result')
    carrier_path=ROOT/'selfhost/build/phase130/base-carrier01/receipt.json';carrier,base,carrier_inputs=N.carrier_inputs(carrier_path)
    inputs=[pin(__file__),pin(METHOD),pin(N.METHOD),pin(BUILDER),pin(RUNNER),pin(sys.executable),pin(old_path),pin(old_run_path),*old['inputs'],pin(edited_path),edited['source'],edited['product'],pin(a.comparison),*comparison['inputs'],pin(a.producer_join),*joined['inputs'],*carrier_inputs]
    for role,build in roles.items():inputs.extend([pin(getattr(a,role)),build['binary'],*build['inputs']])
    commands=[];requests=[];ordinary=[]
    for round_index in range(2):
        cases=old['oracles'] if round_index==0 else list(reversed(old['oracles']))
        order=['monolithic','cold','warm'] if round_index==0 else ['warm','cold','monolithic']
        for case in cases:
            require(case['onlyMainFragmentChanged'],'Unexpected edited oracle policy')
            for role in order:
                label=f"r{round_index}-{role}-{case['name']}";destination=ROOT/f'selfhost/build/phase130/{out.name}-{label}'
                require(not destination.exists(),'Request output already exists')
                command=[sys.executable,'-B',str(METHOD),'--image',roles[role]['binary']['file'],'--source',case['source']['file'],'--carrier-receipt',str(carrier_path),'--out',str(destination),'--expected-qbe',case['after']['file'],'--seconds','30']
                commands.append(dict(name=label,argv=command));requests.append(dict(name=label,round=round_index,role=role,case=case['name'],source=case['source'],expectedQbe=case['after'],report=str(destination/'report.json')))
    # Every role already emits byte-identical QBE. Two independently built role
    # products execute each frozen ordinary oracle; warm transfers by identity.
    for case in old['oracles']:
        inputs.extend([case['source'],case['before'],case['after'],case['ordinaryStdout']])
        for role in ['monolithic','cold']:
            request=next(r for r in requests if r['round']==0 and r['case']==case['name'] and r['role']==role)
            product=Path(request['report']).parent/'program.ssa';label=f"ordinary-{role}-{case['name']}";destination=ROOT/f'selfhost/build/phase111/{out.name}-{label}'
            require(not destination.exists(),'Ordinary output already exists')
            command=[sys.executable,'-B',str(BUILDER),'--source',str(product),'--runtime',runtime['file'],'--out',str(destination),'--expected',case['ordinaryStdout']['file'],'--seconds','30']
            commands.append(dict(name=label,argv=command));ordinary.append(dict(name=label,role=role,case=case['name'],sourceRequest=request['report'],expectedStdout=case['ordinaryStdout'],report=str(destination/'report.json')))
    inputs=list({(x['file'],x['sha256']):x for x in inputs}.values())
    for row in inputs:verify(row)
    out.mkdir(parents=True)
    plan=dict(complete=True,preparedOnly=True,targetsRun=False,kind='phase135-small-machine-semantic-gates',inputs=inputs,
        roles={k:v['binary']for k,v in roles.items()},compilerSource=edited['source'],runtime=runtime,oracles=old['oracles'],
        machineComparison=pin(a.comparison),producerJoin=pin(a.producer_join),commands=commands,requests=requests,ordinary=ordinary,
        schedule='Two rounds, both case and role order reversed. Nine mandatory full-QBE gates plus nine timing repeats; then six ordinary outputs.',
        scope='Bounded experimental compiler qualification only. Request timing compares machine layout for the same edited compiler source. Exact program QBE under fixed downstream tool/runtime/flags preserves generated programs; no fresh program-runtime speed claim, broad conformance or self-host promotion.')
    write(out/'plan.json',plan);print(json.dumps(dict(complete=True,plan=pin(out/'plan.json'),commands=len(commands),targetsRun=False)))


def run(a):
    plan=read(a.plan);require(plan['complete'] and plan['kind']=='phase135-small-machine-semantic-gates' and pin(__file__)in plan['inputs'],'Frozen gate plan required')
    require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS']),'No ambient profiler')
    for row in plan['inputs']:verify(row)
    out=a.out.absolute();require(out==out.resolve() and out.is_relative_to(ROOT/'selfhost/build/phase135') and not out.exists(),'Fresh Phase135 execution directory required')
    result=subprocess.run([sys.executable,str(RUNNER),'--plan',str(a.plan.resolve()),'--out',str(out)],cwd=ROOT,check=False)
    report=dict(complete=False,plan=pin(a.plan),runner=pin(RUNNER),exitCode=result.returncode,scope=plan['scope'])
    try:
        require(result.returncode==0,'Bounded gate runner failed')
        executed=read(out/'report.json');require(executed['complete'] and len(executed['jobs'])==24 and executed['planSha256']==pin(a.plan)['sha256'],'Executed schedule incomplete')
        timing=[];ordinary=[]
        for row in plan['requests']:
            observed=read(row['report']);require(observed['complete'] and observed['image']==plan['roles'][row['role']] and observed['source']==row['source'] and observed['byteExact'],'Current request identity/output mismatch')
            timing.append({**row,'receipt':pin(row['report']),'nativeSeconds':observed['nativeSeconds'],'cpuSeconds':observed['cpuSeconds'],'peakRssKiB':observed['peakRssKiB'],'product':observed['product']})
        for row in plan['ordinary']:
            observed=read(row['report']);require(observed['complete'] and observed['outputExact'] and row['expectedStdout']in observed['inputs'] and plan['runtime']in observed['inputs'],'Ordinary program gate mismatch')
            ordinary.append({**row,'receipt':pin(row['report']),'binary':observed['binary']})
        report.update(requests=timing,ordinary=ordinary,comparisons=[])
        for case in plan['oracles']:
            for role in ['cold','warm']:
                ratios=[]
                for r in range(2):
                    rows={x['role']:x for x in timing if x['round']==r and x['case']==case['name']}
                    ratios.append(rows[role]['nativeSeconds']/rows['monolithic']['nativeSeconds'])
                report['comparisons'].append(dict(case=case['name'],role=role,pairedRatios=ratios,geomean=math.exp(sum(map(math.log,ratios))/len(ratios))))
        for row in plan['inputs']:verify(row)
        report['complete']=True
    except BaseException as error:report['error']=repr(error)
    write(out/'summary.json',report);print(json.dumps({k:report.get(k)for k in ['complete','comparisons','error']}));return 0if report['complete']else 1


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__);g=ap.add_mutually_exclusive_group(required=True);g.add_argument('--prepare',action='store_true');g.add_argument('--run',action='store_true')
    ap.add_argument('--plan',type=Path);ap.add_argument('--out',type=Path,required=True)
    for name in ['monolithic','cold','warm','comparison','producer-join']:ap.add_argument('--'+name,type=Path)
    a=ap.parse_args()
    if a.prepare:require(all(getattr(a,k)for k in ['monolithic','cold','warm','comparison','producer_join']),'All current machine receipts required');prepare(a)
    else:require(a.plan is not None,'Frozen plan required');sys.exit(run(a))
