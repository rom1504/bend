#!/usr/bin/env python3
"""Post-hoc two-case confirmation with exact retained products and frozen counts."""
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
SOURCE_PLAN=RAW/'programs-plan04/plan.json'
ACQUIRE=RAW/'programs-plan04-acquire/report.json'
JOINED=RAW/'programs-last-resume01/report.json'
CHOICES=[('complete-generic-row32',['baseline','codegen']),('raytrace',['candidate','fast'])]
SELF=Path(__file__).resolve()


def prepare(out):
    M.fresh(out);plan,acq,joined=map(read,[SOURCE_PLAN,ACQUIRE,JOINED])
    require(plan['complete'] and acq['complete'] and joined['complete'] and len(joined['rows'])==720,'Completed original campaign required')
    require(acq['plan']==pin(SOURCE_PLAN) and joined['originalPlan']==pin(SOURCE_PLAN) and joined['acquisition']==pin(ACQUIRE),'Campaign lineage differs')
    require(pin(HERE/'runtime-v04.py') in plan['inputs'],'Original method differs')
    counts=read(M.COUNTS);inputs=[pin(p) for p in [SELF,SOURCE_PLAN,ACQUIRE,JOINED,M.ORACLE,M.COUNTS,HERE/'runtime-v04.py']];cases=[]
    for name,roles in CHOICES:
        case=next(x['case'] for x in plan['cases'] if x['case']['name']==name)
        built=next(x for x in acq['rows'] if x['name']==name);require(built['source']==case['source'],'Source differs')
        case=dict(case,repetitions=counts['cases'][name]['repetitions']*4,warmups=counts['cases'][name]['warmups'])
        require(built['products'][roles[0]]['runtime']==built['products'][roles[1]]['runtime'],'Pair runtime differs')
        inputs.extend([case['source'],case['expectedStdoutEvidence']]);require(verify(case['expectedStdoutEvidence']).read_bytes()==case['expectedStdout'].encode(),'Oracle differs')
        for role in roles:
            p=built['products'][role]
            inputs.extend(p[k] for k in ['binary','qbe','object','runtime','emission','build'])
            original=[r for r in joined['rows'] if r['name']==name and r['role']==role]
            require(len(original)==4 and {r['round'] for r in original}=={0,1,2,3},'Four original observations required')
            command=[p['binary']['file'],'--threads','1','--gpu','off','--',str(case['repetitions']),str(case['warmups']),*map(str,case['runtimeArgs'])]
            for row in original:
                require(row['binary']==p['binary'] and row['correct'] and row['job']['command']==command,'Original binary/counts differ')
                job=row['job'];require(O.observation(verify(job['stdout']).read_bytes(),verify(job['stderr']).read_bytes(),job['exitCode'],case,job['seconds'])==row['elapsedMs'],'Original observation differs')
                inputs.extend([job['stdout'],job['stderr']])
        cases.append(dict(case=case,roles=roles,products={r:built['products'][r] for r in roles}))
    unique={p['file']:p for p in inputs}
    for p in unique.values():verify(p)
    out.mkdir();rp=dict(kind='phase144-flagged-runtime-recheck-plan',complete=True,targetsRun=False,inputs=list(unique.values()),cases=cases,pairs=8,scope='Post-hoc flagged-only recheck. Same binaries, counts and outputs; eight alternating pairs. Separate from frozen720-observation score; no source acquisition/build.')
    save(out/'plan.json',rp);dest=RAW/'programs-recheck01'
    cmd=[sys.executable,'-B',str(M.GUARD),'--out',str(dest)+'-guard','--seconds','40','--rss-mib','2048','--available-mib','16384','--file-mib','128','--cpu','3','--',sys.executable,'-B',str(SELF),'run','--plan',str(out/'plan.json'),'--out',str(dest)]
    save(out/'jobs.json',dict(complete=True,targetsRun=False,command=cmd));print(json.dumps(dict(prepared=True,jobs=str(out/'jobs.json'))))


def run(plan_path,out):
    M.fresh(out);require(os.sched_getaffinity(0)=={3},'Root CPU3 guard required')
    require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS']),'Diagnostic environment refused')
    plan=read(plan_path);require(plan['complete'] and plan['pairs']==8 and pin(SELF) in plan['inputs'],'Frozen method differs')
    for p in plan['inputs']:verify(p)
    out.mkdir();start=time.monotonic();result=dict(kind='phase144-flagged-runtime-recheck',complete=False,plan=pin(plan_path),inputs=plan['inputs'],rows=[],scope=plan['scope'])
    def persist():result['seconds']=time.monotonic()-start;save(out/'report.json',result)
    persist()
    try:
        for entry in plan['cases']:
            c,roles=entry['case'],entry['roles']
            for pair in range(8):
                for role in (roles if pair%2==0 else list(reversed(roles))):
                    binary=entry['products'][role]['binary'];cmd=[binary['file'],'--threads','1','--gpu','off','--',str(c['repetitions']),str(c['warmups']),*map(str,c['runtimeArgs'])]
                    t=time.monotonic();r=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=10);wall=time.monotonic()-t;stem=f"{c['name']}-{role}-{pair}"
                    so=out/(stem+'.stdout');se=out/(stem+'.stderr');so.write_bytes(r.stdout);se.write_bytes(r.stderr)
                    elapsed=O.observation(r.stdout,r.stderr,r.returncode,c,wall)
                    result['rows'].append(dict(name=c['name'],role=role,pair=pair,binary=binary,command=cmd,seconds=wall,elapsedMs=elapsed,exitCode=r.returncode,stdout=pin(so),stderr=pin(se),correct=True))
                persist()
        summary=[]
        for entry in plan['cases']:
            name=entry['case']['name'];left,right=entry['roles'];med={role:statistics.median(r['elapsedMs'] for r in result['rows'] if r['name']==name and r['role']==role) for role in [left,right]};ratios=[]
            for pair in range(8):
                v={r['role']:r['elapsedMs'] for r in result['rows'] if r['name']==name and r['pair']==pair};require(v[left]>0 and v[right]>0,'Nonpositive interval');ratios.append(v[right]/v[left])
            summary.append(dict(name=name,numerator=right,denominator=left,mediansMs=med,ratioOfMedians=med[right]/med[left],pairedRatios=ratios,slowerPairs=sum(x>1 for x in ratios),equalPairs=sum(x==1 for x in ratios),scope='Eight post-hoc alternating pairs; descriptive, not a confidence interval or replacement for original score.'))
        for p in plan['inputs']:verify(p)
        result.update(complete=True,summary=summary)
    except BaseException as e:result['error']=repr(e);raise
    finally:persist()
    print(json.dumps(dict(complete=True,seconds=result['seconds'],summary=result['summary'])))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('action',choices=['prepare','run']);p.add_argument('--out',type=Path,required=True);p.add_argument('--plan',type=Path);a=p.parse_args()
    if a.action=='prepare':prepare(a.out.resolve())
    else:require(a.plan is not None,'Plan required');run(a.plan.resolve(),a.out.resolve())
