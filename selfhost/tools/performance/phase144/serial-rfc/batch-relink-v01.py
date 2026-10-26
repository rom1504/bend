"""Fixed-work runtime-only comparison over four preserved Phase131 objects."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import signal
import statistics
import subprocess
import time

HERE=Path(__file__).resolve().parent
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path); value=importlib.util.module_from_spec(spec);spec.loader.exec_module(value);return value
M=module('relink',HERE/'relink-v01.py');ROOT=M.ROOT;RAW=M.RAW
ORACLE=ROOT/'selfhost/tools/performance/phase112/benchmark45/run.py'
O=module('observation',ORACLE)
NAMES=['coverage-map-churn-128','coverage-record-aggregation-256','coverage-bst-64','coverage-unicode-text-64']

def prepare(base_path,out):
    M.require(not out.exists() and out.resolve().is_relative_to(RAW),'Fresh phase144 output required')
    inputs={}
    def keep(item):
        path=M.verify(item) if isinstance(item,dict) else Path(item)
        p=M.pin(path);inputs[p['file']]=p;return p
    base_pin=keep(base_path);base=M.read(base_path)
    M.require(base['complete'] and M.same(base['method'],M.pin(M.__file__)),'Base plan differs')
    for i in base['inputs']:keep(i)
    bridge_pin=keep(ROOT/'implementation/phase131/native-program-equality.json');bridge=M.read(bridge_pin['file'])
    qualification_pin=keep(ROOT/'implementation/phase131/final/native-qualification.json');qualified=M.read(qualification_pin['file'])
    M.require(qualified['complete'] and qualified['nativeQualified'] and bridge['complete'] and bridge['all45ByteExact'],'Phase131 qualification missing')
    M.require(M.same(qualified['n2'],bridge['image']) and M.same(qualified['source'],bridge['source']) and M.same(bridge['runtime'],base['runtimes']['atomic']),'Phase131 source/runtime bridge differs')
    for i in [bridge['source'],bridge['image'],bridge['runtime']]:keep(i)
    screen_pin=keep(bridge['measuredScreen']);screen=M.read(screen_pin['file'])
    manifest_pin=keep(ROOT/'selfhost/tools/performance/phase112/benchmark45/manifest01.json');manifest=M.read(manifest_pin['file'])
    M.require(screen['complete'] and not screen['correctnessOnly'] and any(M.same(manifest_pin,i) for i in screen['inputs']),'Original batch screen not complete')
    oracle_pin=keep(ORACLE);M.require(any(M.same(oracle_pin,i)for i in screen['inputs']),'Changed observation oracle')
    cases=[]
    for name in NAMES:
        case=next(c for c in manifest['cases']if c['name']==name)
        b=next(c for c in bridge['cases']if c['name']==name)
        rows=[r for r in screen['rows']if r['name']==name and r['role']=='candidate']
        M.require(len(rows)==3 and all(r['correct'] and r['status']==0 for r in rows),'Historical batch failed')
        M.require(b['byteExact'] and M.same(b['source'],case['source']) and all(M.same(r['binary'],b['measuredBinary'])for r in rows),'Measured program source differs')
        for i in [b['source'],b['nativeQbe'],b['hostedQbe'],b['measuredBinary'],b['receipt']]:keep(i)
        M.require(b['nativeQbe']['sha256']==b['hostedQbe']['sha256'] and b['nativeQbe']['bytes']==b['hostedQbe']['bytes'],'Native/hosted QBE differs')
        receipt=M.read(b['receipt']['file'])
        M.require(receipt['complete'] and M.same(receipt['product'],b['nativeQbe']) and M.same(receipt['image'],bridge['image']),'Native producer differs')
        expected=keep(case['expectedStdoutEvidence']);M.require(M.verify(expected).read_bytes()==case['expectedStdout'].encode(),'Independent expected output differs')
        built=next(x for x in screen['builds']if x['name']==name);bp=keep(built['report']);build=M.read(bp['file'])
        M.require(built['status']==0 and build['complete'] and M.same(build['binary'],b['measuredBinary']) and not build['perProgramC'] and not build['cproc'],'Batch build differs')
        M.require(all(any(M.same(x,i)for i in build['inputs'])for x in [b['hostedQbe'],base['runtimes']['atomic'],base['cc']]),'Batch build inputs differ')
        obj=keep(build['object']);link=next(j['command']for j in build['jobs']if j['label']=='link')
        M.require(Path(link[0]).resolve()==Path(base['cc']['canonicalPath']) and link[1:]==['-no-pie',obj['file'],base['runtimes']['atomic']['file'],'-pthread','-lm','-o',b['measuredBinary']['file']],'Old link policy differs')
        args=rows[0]['command'][1:]
        M.require(args[:5]==['--threads','1','--gpu','off','--'] and all(r['command'][1:]==args for r in rows),'Batch arguments differ')
        observed=dict(case,repetitions=int(args[5]),warmups=int(args[6]))
        M.require(args[7:]==list(map(str,case['runtimeArgs'])),'Workload parameters differ')
        for r in rows:
            so=keep(r['stdout']);se=keep(r['stderr'])
            M.require(O.observation(M.verify(so).read_bytes(),M.verify(se).read_bytes(),r['status'],observed,r['wallSeconds'])==r['elapsedMs'],'Historical observer differs')
        M.require(min(r['elapsedMs']for r in rows)>=100,'Batch below historical100ms floor')
        cases.append(dict(name=name,source=case['source'],object=obj,build=bp,nativeReceipt=b['receipt'],
            expectedStdout=case['expectedStdout'],expectedStdoutEvidence=expected,args=args,
            repetitions=observed['repetitions'],warmups=observed['warmups'],historicalMs=[r['elapsedMs']for r in rows]))
    keep(Path(__file__));out.mkdir()
    result=dict(kind='phase144-runtime-batch-relink-plan-v01',complete=True,preparedOnly=True,targetsRun=False,
        method=M.pin(__file__),semanticPlan=base_pin,runtimes=base['runtimes'],cc=base['cc'],nativeBridge=bridge_pin,
        nativeQualification=qualification_pin,cases=cases,rounds=6,inputs=list(inputs.values()),environment=M.ENV,
        cpu=3,childDeadlineSeconds=15,scope='Runtime-only isolation over four retained Phase131 fixed-work batch objects. Same emitted code and work counts, original atomic versus serial RFC runtime. Six balanced alternating pairs per case; full result/count oracle plus elapsed suffix. Not current Phase143 codegen, all45 runtime coverage or compiler throughput.')
    M.save(out/'plan.json',result);print(json.dumps(dict(plan=M.pin(out/'plan.json'),cases=NAMES,rounds=6)))

def run(plan_path,qualification_path,out):
    pp=M.pin(plan_path);plan=M.read(plan_path);qp=M.pin(qualification_path);qualification=M.read(qualification_path)
    M.require(plan['complete'] and M.same(plan['method'],M.pin(__file__)),'Plan/method differs')
    M.require(qualification['complete'] and qualification['passed'] and qualification['group']=='full' and len(qualification['cases'])==61 and M.same(qualification['plan'],plan['semanticPlan']),'61-case semantic prerequisite missing')
    M.require(os.sched_getaffinity(0)=={3} and not out.exists() and out.resolve().is_relative_to(RAW),'Fresh root-guarded CPU3 run required')
    for i in plan['inputs']:M.verify(i)
    out.mkdir();started=time.monotonic()
    result=dict(kind='phase144-runtime-batch-relink-v01',complete=False,plan=pp,semanticQualification=qp,inputs=plan['inputs'],
        images={},jobs=[],rows=[],environment=M.ENV,affinity=[3],startedEpoch=time.time(),scope=plan['scope'])
    def child(label,command):
        before=time.monotonic();epoch=time.time();timeout=False
        p=subprocess.Popen(command,cwd=ROOT,env=M.ENV,stdin=subprocess.DEVNULL,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True)
        try:so,se=p.communicate(timeout=plan['childDeadlineSeconds'])
        except subprocess.TimeoutExpired:
            timeout=True;os.killpg(p.pid,signal.SIGKILL);so,se=p.communicate()
        elapsed=time.monotonic()-before;prefix=out/str(len(result['jobs']));a=prefix.with_suffix('.stdout');b=prefix.with_suffix('.stderr');a.write_bytes(so);b.write_bytes(se)
        job=dict(label=label,command=command,status=p.returncode,wallSeconds=elapsed,startedEpoch=epoch,finishedEpoch=time.time(),timedOut=timeout,stdout=M.pin(a),stderr=M.pin(b));result['jobs'].append(job);M.save(out/'report.json',result)
        M.require(not timeout and p.returncode==0 and not se,'Child failed: '+label)
        return job,so,se
    try:
        for c in plan['cases']:
            result['images'][c['name']]={}
            for role in ['atomic','serial']:
                binary=out/(c['name']+'-'+role)
                j,so,se=child('link-'+c['name']+'-'+role,[plan['cc']['canonicalPath'],'-no-pie',c['object']['file'],plan['runtimes'][role]['file'],'-pthread','-lm','-o',str(binary)])
                M.require(so==b'','Link stdout differs');result['images'][c['name']][role]=M.pin(binary)
        for rnd in range(plan['rounds']):
            order=plan['cases'][rnd%4:]+plan['cases'][:rnd%4]
            for c in order:
                for role in (['atomic','serial']if rnd%2==0 else ['serial','atomic']):
                    binary=result['images'][c['name']][role]
                    job,so,se=child(c['name']+'-'+role+'-'+str(rnd),[binary['file']]+c['args'])
                    elapsed=O.observation(so,se,job['status'],c,job['wallSeconds'])
                    result['rows'].append(dict(name=c['name'],role=role,round=rnd,binary=binary,job=len(result['jobs'])-1,elapsedMs=elapsed,wallSeconds=job['wallSeconds'],correct=True))
                    M.save(out/'report.json',result)
        summary=[]
        for c in plan['cases']:
            rows=[r for r in result['rows']if r['name']==c['name']]
            values={role:[r['elapsedMs']for r in rows if r['role']==role]for role in ['atomic','serial']}
            M.require(all(len(v)==6 for v in values.values()),'Missing timing pair')
            medians={role:statistics.median(v)for role,v in values.items()}
            eligible=min(v for a in values.values()for v in a)>=20
            summary.append(dict(name=c['name'],samplesMs=values,mediansMs=medians,minimum20ms=eligible,
                serialOverAtomic=medians['serial']/medians['atomic'] if eligible else None,
                pairedRatios=[values['serial'][i]/values['atomic'][i] if values['atomic'][i] else None for i in range(6)]))
        for i in plan['inputs']:M.verify(i)
        M.require(M.same(pp,M.pin(plan_path)) and M.same(qp,M.pin(qualification_path)),'Receipt changed during run')
        result['summary']=summary;result['complete']=True
    except Exception as error:result['error']=str(error);raise
    finally:result['seconds']=time.monotonic()-started;result['finishedEpoch']=time.time();M.save(out/'report.json',result)
    print(json.dumps(dict(report=M.pin(out/'report.json'),complete=True,observations=len(result['rows']),summary=result['summary'])))

if __name__=='__main__':
    p=argparse.ArgumentParser();s=p.add_subparsers(dest='mode',required=True)
    a=s.add_parser('prepare');a.add_argument('--semantic-plan',type=Path,required=True);a.add_argument('--out',type=Path,required=True)
    a=s.add_parser('run');a.add_argument('--plan',type=Path,required=True);a.add_argument('--qualification',type=Path,required=True);a.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    if a.mode=='prepare':prepare(a.semantic_plan.absolute(),a.out.absolute())
    else:run(a.plan.absolute(),a.qualification.absolute(),a.out.absolute())
