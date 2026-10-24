#!/usr/bin/env python3
"""One frozen real-compiler edit through the existing native session.

Transport/evidence only. No compiler source, cache policy or oracle modification.
--prepare runs no targets; --run requires the coordinator's resource guard.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import threading
import time

sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
METHOD=ROOT/'selfhost/tools/performance/phase134/session/native-run-v04.py'
spec=importlib.util.spec_from_file_location('p134_session',METHOD)
S=importlib.util.module_from_spec(spec);spec.loader.exec_module(S)
pin,verify,require=S.pin,S.verify,S.require
PHASE=ROOT/'selfhost/build/phase135'


def read(p):return json.loads(Path(p).read_text())


def save(p,r):
    tmp=p.with_suffix('.tmp');tmp.write_text(json.dumps(r,indent=2)+'\n');tmp.replace(p)


def prepare(a):
    session_path=ROOT/'selfhost/build/phase134/session-native-measured04/report.json'
    session=read(session_path);prior=read(verify(session['plan']))
    require(session['complete'],'Completed native session experiment required')
    paths=[ROOT/'selfhost/build/phase130/p131-final-self01/report.json',ROOT/'selfhost/build/phase130/p132-edited-full01/report.json']
    refs=[read(p)for p in paths]
    require(all(x['complete'] and x['exitCode']==0 and not x['stderr']['bytes']for x in refs),'Complete independent full QBE oracles required')
    for x in refs:
        require(x['base']==prior['base'] and x['carrier']==prior['carrier'] and x['stamp']==prior['stamp'],'Full oracle Base/carrier mismatch')
        require(x['command'][6:]==['phase111',x['source']['file'],x['base']['file'],'cache',x['carrier']['file'],x['stamp']], 'Oracle actual source path mismatch')
    edit_path=ROOT/'selfhost/build/phase132/source-edit01/report.json';edit=read(edit_path)
    require(edit['complete'] and edit['source']==refs[1]['source'] and edit['baselineQbe']==refs[0]['product'],'Historical edit binding mismatch')
    before=verify(refs[0]['source']).read_text();after=verify(refs[1]['source']).read_text()
    marker='def p111q_main() -> String:\n';require(before.count(marker)==1,'Expected unique emitter declaration')
    start=before.index(marker);end=before.index('\n\n',start);old=before[start:end]
    require(old.count('%result')==2 and after==before[:start]+old.replace('%result','%answer')+before[end:],'Not the exact one-declaration edit')
    require(len(before.encode())==len(after.encode()),'Source-length preservation failed')
    inputs=[pin(__file__),pin(METHOD),pin(S.METHOD),pin(S.N.METHOD),pin(sys.executable),pin(session_path),session['plan'],
            *session['inputs'],pin(edit_path),*edit['inputs'],*[pin(p)for p in paths]]
    for x in refs:inputs.extend([x['source'],x['product'],x['image'],x['base'],x['carrier']])
    inputs=list({(x['file'],x['sha256']):x for x in inputs}.values())
    for row in inputs:verify(row)
    folder=a.plan.absolute().parent;require(folder==folder.resolve() and folder.is_relative_to(PHASE) and not folder.exists(),'Fresh real Phase135 plan directory required')
    folder.mkdir(parents=True)
    plan=dict(kind='phase135-real-compiler-edit-session',complete=True,inputs=inputs,image=session['image'],runtime=session['runtime'],
        experimentalCompilerSource=session['source'],base=prior['base'],carrier=prior['carrier'],stamp=prior['stamp'],
        revisions=[dict(role=s,source=r['source'],expectedQbe=r['product'],reference=pin(p))for s,r,p in zip(['A','B'],refs,paths)],
        out=str(a.out.absolute()),mode='warm',limitSeconds=1200,
        guards=dict(cpu=3,rssMiB=4096,availableMiB=16384,fileMiB=256),
        edit=dict(declaration='p111q_main',old='%result',new='%answer',occurrences=2,sameSourceLength=True),
        scope='One full compiler A→B retained-cache scalability/output experiment. Historical source paths and complete QBE are unchanged. No cold-reset/no-cache/upstream performance comparison; no machine build or promotion.',
        timingScope='Whole process wall/CPU/RSS; IO.now preparation,A,B intervals include checking,transformation,verification,render,write,close. Cache construction forA is charged.')
    save(a.plan,plan);print(json.dumps(dict(complete=True,plan=pin(a.plan),targetsRun=False)))


def run(a):
    plan=read(a.plan);require(plan['complete'] and plan['kind']=='phase135-real-compiler-edit-session','Frozen plan required')
    require(pin(__file__)in plan['inputs'],'Changed supervisor')
    require(not any(k in os.environ for k in ['LD_PRELOAD','BEND_SAMPLE_OUT','BEND_SAMPLE_CONTEXT_OUT','BEND_PROFILE_COUNTERS','BEND_PROFILE_EVENTS_OUT']),'No ambient profiling')
    for row in plan['inputs']:verify(row)
    out=Path(plan['out']);require(out==out.resolve() and out.is_relative_to(PHASE) and not out.exists(),'Fresh real Phase135 output required')
    out.parent.mkdir(parents=True,exist_ok=True)
    oa,ob=S.safe_outputs(out,{Path(x['file']).resolve()for x in plan['inputs']})
    command=[plan['image']['file'],'--threads','1','--gpu','off','--','phase134-session',*[r['source']['file']for r in plan['revisions']],plan['base']['file'],plan['carrier']['file'],plan['stamp'],str(oa),str(ob),plan['mode']]
    report=dict(kind='phase135-real-compiler-edit-session-result',complete=False,plan=pin(a.plan),inputs=plan['inputs'],command=command,
        image=plan['image'],runtime=plan['runtime'],scope=plan['scope'],timingScope=plan['timingScope'],inheritedAffinity=sorted(os.sched_getaffinity(0)))
    start=time.monotonic();child=None;expired=threading.Event()
    def persist():report['totalSeconds']=time.monotonic()-start;save(out/'report.json',report)
    persist()
    try:
        with(out/'stdout').open('xb')as so,(out/'stderr').open('xb')as se:
            t=time.monotonic();child=subprocess.Popen(command,cwd=out,stdout=so,stderr=se,start_new_session=True)
            def stop():
                expired.set()
                try:os.killpg(child.pid,signal.SIGKILL)
                except ProcessLookupError:pass
            timer=threading.Timer(plan['limitSeconds'],stop);timer.daemon=True;timer.start()
            try:
                _,status,usage=os.wait4(child.pid,0);child.returncode=os.waitstatus_to_exitcode(status)
            except BaseException:stop();child.wait();raise
            finally:timer.cancel();timer.join()
            report.update(exitCode=child.returncode,nativeWallSeconds=time.monotonic()-t,userSeconds=usage.ru_utime,systemSeconds=usage.ru_stime,cpuSeconds=usage.ru_utime+usage.ru_stime,peakRssKiB=usage.ru_maxrss,timedOut=expired.is_set())
        require(not expired.is_set() and child.returncode==0,'Native full session failed/timed out')
        require(not(out/'stderr').stat().st_size,'Native full session diagnostics')
        report['stats']=S.parse_stats(out/'stdout');report['products']=[]
        for revision,path in zip(plan['revisions'],[oa,ob]):
            product=S.regular(path);expected=revision['expectedQbe']
            same=all(product[k]==expected[k]for k in ['bytes','sha256'])
            report['products'].append(dict(role=revision['role'],actual=product,expected=expected,byteExact=same))
            require(same,'Full QBE differs from historical independent oracle for'+revision['role'])
        require(report['stats']['A']['counts'][0]==report['stats']['A']['counts'][2]==0,'Initial full request unexpectedly had prior hits')
        report['warmReuseObserved']=any(report['stats']['B']['counts'][i]>0for i in [0,2])
        report['complete']=True
    except BaseException as error:report['error']=repr(error)
    finally:
        for name in ['stdout','stderr']:
            if(out/name).exists():report[name]=pin(out/name)
        report['changedInputs']=[]
        for row in plan['inputs']:
            try:verify(row)
            except(OSError,ValueError):report['changedInputs'].append(row['file'])
        if report['changedInputs']:report['complete']=False
        persist()
    print(json.dumps({k:report.get(k)for k in ['complete','nativeWallSeconds','stats','peakRssKiB','error','changedInputs']}))
    return 0if report['complete']else 1


if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__);g=ap.add_mutually_exclusive_group(required=True)
    g.add_argument('--prepare',action='store_true');g.add_argument('--run',action='store_true')
    ap.add_argument('--plan',type=Path,required=True);ap.add_argument('--out',type=Path)
    a=ap.parse_args()
    if a.prepare:require(a.out is not None,'Result path required');prepare(a)
    else:sys.exit(run(a))
