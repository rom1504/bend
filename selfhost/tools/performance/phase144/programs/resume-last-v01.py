#!/usr/bin/env python3
"""Resume only the interrupted final frozen case; preserve and recheck evidence."""
import argparse
import importlib.util
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p144_program_screen',HERE/'runtime-v04.py')
M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
ROOT,RAW,O=M.ROOT,M.RAW,M.O
pin,verify,read,save,require=M.pin,M.verify,M.read,M.save,M.require
PLAN=RAW/'programs-plan04/plan.json'
ACQUIRE=RAW/'programs-plan04-acquire/report.json'
PARTIAL=RAW/'programs-plan04-measure/report.json'
GUARD=RAW/'programs-plan04-measure-guard/process.json'
SELF=Path(__file__).resolve()


def admission():
    plan,acq,partial,guard=map(read,[PLAN,ACQUIRE,PARTIAL,GUARD])
    require(plan['complete'] and plan['rounds']==4 and plan['roleOrder']==M.ROLES,'Original balanced plan differs')
    require(pin(HERE/'runtime-v04.py') in plan['inputs'],'Original method identity differs')
    require(acq['complete'] and acq['plan']==pin(PLAN),'Complete acquisition missing')
    require(not partial['complete'] and partial['plan']==pin(PLAN) and partial['acquisition']==pin(ACQUIRE),'Partial report lineage differs')
    require(not guard['complete'] and guard['stoppedFor']=='deadline' and guard['returncode']==-9,'Expected deadline receipt missing')
    require(guard['command'][-6:]==[str(HERE/'runtime-v04.py'),'measure','--plan',str(PLAN),'--out',str(PARTIAL.parent)],'Guard command differs')
    require(len(acq['rows'])==45 and len(partial['rows'])==len(partial['jobs'])==707,'Expected45 acquisitions/707 completed observations')
    require(partial['inputs']==plan['inputs']+[pin(ACQUIRE)],'Partial observation inputs differ')
    for p in plan['inputs']:verify(p)
    counts=read(M.COUNTS); expected=[];inputs=[pin(p) for p in [SELF,PLAN,ACQUIRE,PARTIAL,GUARD]]+plan['inputs']
    cases=[]
    for entry,built in zip(plan['cases'],acq['rows']):
        c=entry['case'];require(built['name']==c['name'] and built['source']==c['source'],'Acquired source order differs')
        c=dict(c,repetitions=counts['cases'][c['name']]['repetitions']*4,warmups=counts['cases'][c['name']]['warmups']);cases.append(c)
        for role in M.ROLES:
            product=built['products'][role]
            for key in ['binary','qbe','object','runtime','emission','build']:
                verify(product[key]);inputs.append(product[key])
            require(product['runtime']==plan['runtimes']['old' if role in ['baseline','codegen'] else 'selected'],'Product runtime role differs')
        for rnd in range(4):
            for role in M.ROLES[rnd:]+M.ROLES[:rnd]:expected.append((c,built,role,rnd))
    for row,job,(c,built,role,rnd) in zip(partial['rows'],partial['jobs'],expected):
        binary=built['products'][role]['binary']
        command=[binary['file'],'--threads','1','--gpu','off','--',str(c['repetitions']),str(c['warmups']),*map(str,c['runtimeArgs'])]
        require(row['name']==c['name'] and row['role']==role and row['round']==rnd and row['binary']==binary and row['correct'] is True,'Partial observation order/identity differs')
        require(row['job']==job and job['command']==command and job['label']==f"{c['name']}-{role}-{rnd}",'Partial command differs')
        stdout=verify(job['stdout']).read_bytes();stderr=verify(job['stderr']).read_bytes();inputs += [job['stdout'],job['stderr']]
        require(O.observation(stdout,stderr,job['exitCode'],c,job['seconds'])==row['elapsedMs'],'Retained complete output differs')
    require(all(r['name']==cases[-1]['name'] for r in partial['rows'][704:]),'Discarded prefix is not solely incomplete final case')
    return plan,acq,partial,cases,inputs


def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('action',choices=['prepare','run']);ap.add_argument('--out',type=Path,required=True);ap.add_argument('--resume-plan',type=Path)
    a=ap.parse_args();out=a.out.resolve();M.fresh(out)
    if a.action=='prepare':
        plan,acq,partial,cases,inputs=admission();unique={p['file']:p for p in inputs};out.mkdir()
        rp=dict(kind='phase144-last-case-resume-plan',complete=True,targetsRun=False,inputs=list(unique.values()),originalPlan=pin(PLAN),acquisition=pin(ACQUIRE),partial=pin(PARTIAL),deadline=pin(GUARD),retainedRows=704,excludedPartialRows=3,rerunRows=16,lastCase=cases[-1]['name'],reason='Discard only the incomplete last case, irrespective of its timings; rerun all16 fixed role/round observations.')
        save(out/'plan.json',rp);dest=out.parent/'programs-last-resume01'
        command=[sys.executable,'-B',str(M.GUARD),'--out',str(dest)+'-guard','--seconds','120','--rss-mib','2048','--available-mib','16384','--file-mib','128','--cpu','3','--',sys.executable,'-B',str(SELF),'run','--resume-plan',str(out/'plan.json'),'--out',str(dest)]
        save(out/'jobs.json',dict(complete=True,targetsRun=False,command=command));print(json.dumps(dict(prepared=True,jobs=str(out/'jobs.json'))));return
    require(a.resume_plan is not None and os.sched_getaffinity(0)=={3},'Resume plan and root CPU3 guard required')
    rp=read(a.resume_plan);require(rp['complete'] and pin(SELF) in rp['inputs'],'Resume method differs')
    for p in rp['inputs']:verify(p)
    require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_EVENTS_OUT','BEND_PROFILE_COUNTERS']),'Diagnostic environment refused')
    plan,acq,partial,cases,_=admission();out.mkdir();start=time.monotonic();c=cases[-1];built=acq['rows'][-1]
    result=dict(kind='phase144-last-case-resume',complete=False,inputs=rp['inputs']+[pin(a.resume_plan)],newRows=[],scope=rp['reason'])
    def persist():result['seconds']=time.monotonic()-start;save(out/'report.json',result)
    persist()
    try:
        for rnd in range(4):
            for role in M.ROLES[rnd:]+M.ROLES[:rnd]:
                binary=built['products'][role]['binary'];cmd=[binary['file'],'--threads','1','--gpu','off','--',str(c['repetitions']),str(c['warmups']),*map(str,c['runtimeArgs'])]
                t=time.monotonic();r=subprocess.run(cmd,cwd=ROOT,capture_output=True,timeout=30);seconds=time.monotonic()-t;stem=f"{c['name']}-{role}-{rnd}"
                so=out/(stem+'.stdout');se=out/(stem+'.stderr');so.write_bytes(r.stdout);se.write_bytes(r.stderr)
                job=dict(label=stem,command=cmd,seconds=seconds,exitCode=r.returncode,stdout=pin(so),stderr=pin(se))
                elapsed=O.observation(r.stdout,r.stderr,r.returncode,c,seconds)
                result['newRows'].append(dict(name=c['name'],role=role,round=rnd,binary=binary,elapsedMs=elapsed,correct=True,job=job));persist()
        rows=partial['rows'][:704]+result['newRows'];require(len(rows)==720,'Final observation count differs');summary=[]
        for c in cases:
            med={role:statistics.median(r['elapsedMs'] for r in rows if r['name']==c['name'] and r['role']==role) for role in M.ROLES}
            row=dict(name=c['name'],family=c['family'],ratioEligible=c['ratioEligible'],mediansMs=med,below20msRoles=[r for r in M.ROLES if med[r]<20])
            if c['ratioEligible']:
                require(all(v>0 for v in med.values()),'Nonpositive timed interval')
                row.update(codegenOverBaseline=med['codegen']/med['baseline'],candidateOverBaseline=med['candidate']/med['baseline'],candidateOverCodegen=med['candidate']/med['codegen'],fastOverCandidate=med['fast']/med['candidate'],fastOverBaseline=med['fast']/med['baseline'])
            summary.append(row)
        eligible=[r for r in summary if r['ratioEligible']];gm=lambda xs:math.exp(statistics.mean(math.log(x) for x in xs))
        result['summary']=dict(cases=summary,timedCases=len(eligible),observations=len(rows),geometric={k:gm([r[k] for r in eligible]) for k in ['codegenOverBaseline','candidateOverBaseline','candidateOverCodegen','fastOverCandidate','fastOverBaseline']},summedMedianBatchMs={role:sum(r['mediansMs'][role] for r in eligible) for role in M.ROLES},lowResolutionCases=[r['name'] for r in eligible if r['below20msRoles']],scope='704 complete observations retained; last case independently rerun in full16-observation balanced block. Same frozen counts/oracle. Separate blocks may drift; descriptive ratios, no fresh upstream ratio.')
        result.update(rows=rows,retainedRows=704,excludedRows=partial['rows'][704:],excludedReason=rp['reason'],originalDeadline=pin(GUARD),acquisition=pin(ACQUIRE),originalPlan=pin(PLAN))
        for p in rp['inputs']:verify(p)
        result['complete']=True
    except BaseException as e:result['error']=repr(e);raise
    finally:persist()
    print(json.dumps(dict(complete=True,seconds=result['seconds'],geometric=result['summary']['geometric'])))


if __name__=='__main__':main()
