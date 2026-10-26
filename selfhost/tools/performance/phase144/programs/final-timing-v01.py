#!/usr/bin/env python3
"""Explicit coordinator-approved ten-case final04 timing; no acquisition."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('screen',HERE/'runtime-v04.py');M=importlib.util.module_from_spec(s);s.loader.exec_module(M)
ROOT,RAW,O=M.ROOT,M.RAW,M.O
pin,verify,read,save,require=M.pin,M.verify,M.read,M.save,M.require
SELF=Path(__file__).resolve()
FINAL_PLAN=RAW/'programs-final04-plan01/plan.json'
FINAL=RAW/'programs-final04-acquire01/report.json'
OLD=RAW/'programs-plan04-acquire/report.json'
EXPECTED=['test-morning-program','test-evening-program','test-map-set-ops','complete-generic-row32','coverage-unicode-text-16','coverage-unicode-text-64','coverage-map-churn-32','coverage-map-churn-128','coverage-record-aggregation-64','coverage-record-aggregation-256']


def prepare(out):
    M.fresh(out);plan,final,old=map(read,[FINAL_PLAN,FINAL,OLD])
    require(final['complete'] and final['plan']==pin(FINAL_PLAN) and final['selectedForTiming']==EXPECTED and final['changedMachineCases']==EXPECTED,'Exact reviewed ten cases required')
    require(old['complete'] and final['freshCorrectnessExecutions']==45 and final['inheritedCases']==35,'Completed acquisition counts differ')
    inputs=[pin(p) for p in [SELF,FINAL_PLAN,FINAL,OLD,M.ORACLE,M.COUNTS,HERE/'runtime-v04.py']];counts=read(M.COUNTS);cases=[]
    for name in EXPECTED:
        c=next(e['case'] for e in plan['cases'] if e['case']['name']==name);new=next(r for r in final['rows'] if r['name']==name);prior=next(r for r in old['rows'] if r['name']==name)
        require(c['source']==new['source']==prior['source'] and new['smoke']['correct'],'Source/smoke differs')
        role='baseline' if name=='complete-generic-row32' else 'candidate';products={'reference':prior['products'][role],'final04':new['product']}
        require(products['final04']['runtime']==plan['runtime'] and (role=='baseline' or products['reference']['runtime']==plan['runtime']),'Runtime scope differs')
        require(M.same(prior['products']['baseline']['object'],new['product']['object']),'Reviewed restoration to original object differs')
        c=dict(c,repetitions=counts['cases'][name]['repetitions']*4,warmups=counts['cases'][name]['warmups']);inputs += [c['source'],c['expectedStdoutEvidence']]
        require(verify(c['expectedStdoutEvidence']).read_bytes()==c['expectedStdout'].encode(),'Frozen oracle differs')
        for product in products.values():inputs.extend(product[k] for k in ['binary','object','qbe','runtime','build','emission'])
        cases.append(dict(case=c,products=products,referenceRole=role,scope='Original143 atomic versus final04 serial total product' if role=='baseline' else 'Final03 serial versus final04 serial'))
    unique={p['file']:p for p in inputs}
    for p in unique.values():verify(p)
    out.mkdir();tp=dict(kind='phase144-final04-ten-case-timing-plan',complete=True,targetsRun=False,inputs=list(unique.values()),cases=cases,pairs=8,scope='Explicitly reviewed ten restored-object cases; eight balanced pairs, frozen counts/output oracle. Separate subset, not a new full-corpus aggregate.')
    save(out/'plan.json',tp);dest=RAW/'programs-final04-timing02'
    command=[sys.executable,'-B',str(M.GUARD),'--out',str(dest)+'-guard','--seconds','160','--rss-mib','2048','--available-mib','16384','--file-mib','128','--cpu','3','--',sys.executable,'-B',str(SELF),'run','--plan',str(out/'plan.json'),'--out',str(dest)]
    save(out/'jobs.json',dict(complete=True,targetsRun=False,command=command));print(json.dumps(dict(prepared=True,jobs=str(out/'jobs.json'))))


def run(plan_path,out):
    M.fresh(out);require(os.sched_getaffinity(0)=={3},'Root CPU3 guard required');plan=read(plan_path)
    require(plan['complete'] and plan['pairs']==8 and pin(SELF) in plan['inputs'] and [e['case']['name'] for e in plan['cases']]==EXPECTED,'Frozen plan/method/case order differs')
    require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS']),'Diagnostic environment refused')
    for p in plan['inputs']:verify(p)
    out.mkdir();start=time.monotonic();result=dict(kind='phase144-final04-ten-case-timing',complete=False,plan=pin(plan_path),inputs=plan['inputs'],rows=[],scope=plan['scope'])
    def persist():result['seconds']=time.monotonic()-start;save(out/'report.json',result)
    persist()
    try:
        for entry in plan['cases']:
            c=entry['case']
            for pair in range(8):
                for role in (['reference','final04'] if pair%2==0 else ['final04','reference']):
                    binary=entry['products'][role]['binary'];cmd=[binary['file'],'--threads','1','--gpu','off','--',str(c['repetitions']),str(c['warmups']),*map(str,c['runtimeArgs'])]
                    t=time.monotonic();r=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=10);wall=time.monotonic()-t;stem=f"{c['name']}-{role}-{pair}"
                    so=out/(stem+'.stdout');se=out/(stem+'.stderr');so.write_bytes(r.stdout);se.write_bytes(r.stderr)
                    elapsed=O.observation(r.stdout,r.stderr,r.returncode,c,wall)
                    result['rows'].append(dict(name=c['name'],role=role,pair=pair,binary=binary,command=cmd,seconds=wall,elapsedMs=elapsed,exitCode=r.returncode,stdout=pin(so),stderr=pin(se),correct=True))
            persist();print(c['name'],'complete',flush=True)
        summary=[]
        for entry in plan['cases']:
            name=entry['case']['name'];med={role:statistics.median(r['elapsedMs'] for r in result['rows'] if r['name']==name and r['role']==role) for role in ['reference','final04']};ratios=[]
            for pair in range(8):
                v={r['role']:r['elapsedMs'] for r in result['rows'] if r['name']==name and r['pair']==pair};require(v['reference']>0 and v['final04']>0,'Nonpositive interval');ratios.append(v['final04']/v['reference'])
            summary.append(dict(name=name,referenceRole=entry['referenceRole'],scope=entry['scope'],mediansMs=med,ratioOfMedians=med['final04']/med['reference'],pairedRatios=ratios,slowerPairs=sum(x>1 for x in ratios),equalPairs=sum(x==1 for x in ratios)))
        for p in plan['inputs']:verify(p)
        result.update(complete=True,summary=summary)
    except BaseException as e:result['error']=repr(e);raise
    finally:persist()
    print(json.dumps(dict(complete=True,seconds=result['seconds'],summary=result['summary'])))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('action',choices=['prepare','run']);p.add_argument('--out',type=Path,required=True);p.add_argument('--plan',type=Path);a=p.parse_args()
    if a.action=='prepare':prepare(a.out.resolve())
    else:require(a.plan is not None,'Plan required');run(a.plan.resolve(),a.out.resolve())
