#!/usr/bin/env python3
"""Resume the preserved broad01 pre-launch disk stop; never rerun its 89 good requests."""
import argparse, json, os, re, shutil, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
from support import ROOT, P, authenticate, native_args, pin, read, verify, unchanged
from run import summarize
HERE = Path(__file__).resolve().parent

def save(file, value): Path(file).write_text(json.dumps(value,indent=2)+'\n')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--parent',type=Path,required=True); parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--check-only',action='store_true'); args=parser.parse_args()
    parent_pin=pin(args.parent); parent=read(parent_pin['file']); parent_dir=Path(parent_pin['file']).parent
    assert parent['kind']=='phase92-same-source-native-compiler-comparison'
    assert not parent['complete'] and not parent['passed'] and parent['inputsUnchanged']
    assert parent['error']=='AssertionError: Need 160 MiB reserve plus per-job output headroom'
    assert parent['corpus']=='broad45' and parent['rounds']==parent['calls']==1 and not parent['live']
    assert len(parent['cases'])==45 and len(parent['rows'])==90 and parent['programExecutions']==[]
    assert verify(parent['method'])==pin(HERE/'run.py')
    for item in parent['inputs']: verify(item)
    context=authenticate(parent['authentication']['build']['file']); assert context==parent['authentication']
    cases={x['name']:x for x in parent['cases']}; rows=parent['rows'][:-1]; pending=parent['rows'][-1]
    seen=set(); evidence=[]
    for row in rows:
        key=(row['round'],row['case'],row['role']); assert key not in seen; seen.add(key)
        assert row['passed'] and row['exactC'] and len(row['outputs'])==1
        guard_dir=Path(row['job']['guard']); process_pin=pin(guard_dir/'process.json'); process=read(process_pin['file'])
        assert process==row['job']['process'] and process['complete'] and process['returncode']==0 and not process.get('stoppedFor')
        assert process['command'][-len(row['argv']):]==row['argv'] and row['processWallMs']==1000*process['wallSeconds']
        output=verify(row['outputs'][0]); oracle=verify(cases[row['case']]['oracle'])
        assert (output['sha256'],output['bytes'])==(oracle['sha256'],oracle['bytes'])
        assert Path(output['file']).read_bytes()==Path(oracle['file']).read_bytes()
        stderr=pin(guard_dir/'stderr.log'); logs=Path(stderr['file']).read_text()
        clocks=re.findall(r'^request=1 request_ms=(\d+) consumed_chars=(\d+)$',logs,re.M)
        assert len(clocks)==1 and int(clocks[0][0])==row['requestMs'] and [int(clocks[0][1])]==row['consumedChars']
        evidence.extend([process_pin,stderr,output])
    assert len(seen)==89 and not pending['passed'] and 'job' not in pending and 'outputs' not in pending
    assert (pending['round'],pending['case'],pending['role'])==(1,'coverage-record-aggregation-256','b2')
    label=f'1-{pending["case"]}-b2'; old_prefix=parent_dir/label
    assert pending['argv']==native_args(context,'b2',cases[pending['case']]['source']['file'],old_prefix)
    assert not Path(str(old_prefix)+'.1.c').exists() and not (parent_dir/(label+'-guard')).exists()
    expected={(1,name,role) for name in cases for role in ['b1','b2']}
    assert expected-seen=={(1,pending['case'],'b2')}
    out=args.out.resolve(); assert out.is_relative_to(ROOT/'selfhost/build/phase92') and not out.exists()
    out.mkdir(parents=True)
    report=dict(kind='phase92-native-broad-continuation',complete=False,passed=False,checkOnly=args.check_only,
        executionPerformed=False,method=pin(__file__),parent=parent_pin,parentError=parent['error'],
        parentReportedTargetJobs=parent['targetJobsRun'],parentActuallyCompletedCompilerJobs=89,
        parentPendingRow=pending,authentication=context,cases=parent['cases'],rows=list(rows),
        programExecutions=[],inputs=parent['inputs']+[parent_pin,pin(__file__)],reusedEvidence=evidence,
        newTargetJobsStarted=0,scope='Reuse89 verified complete C emissions; one missing native B2 request, then45 shared-product Clang builds and45 exact-stdout executions. Original failed report is unchanged. Compilation clocks cross a disk-reclamation pause; six-source fresh screen remains the primary speed comparison. Program executions are correctness checks, not runtime benchmarks.')
    def final_inputs():
        unchanged(context)
        for item in report['inputs']+evidence: assert pin(item['file'])==item
    save(out/'report.json',report)
    if args.check_only:
        final_inputs(); report.update(complete=True,passed=True,inputsUnchanged=True)
        save(out/'report.json',report); print(json.dumps(dict(complete=True,targetJobsRun=0,reusedRequests=89,remainingRequests=1,report=str(out/'report.json')))); return
    def guarded(label,argv,seconds=60):
        assert shutil.disk_usage(ROOT).free>=176*1024**2,'Need 160 MiB reserve plus per-job output headroom'
        directory=out/(label+'-guard')
        command=[sys.executable,'-B',str(P/'phase86/guard.py'),'--out',str(directory),'--seconds',str(seconds),
            '--rss-mib','2048','--available-mib','4096','--cpu','3','--',*map(str,argv)]
        report['newTargetJobsStarted']+=1; save(out/'report.json',report)
        env={k:v for k,v in os.environ.items() if not k.startswith('BEND_') and k not in ['NODE_OPTIONS','NODE_PATH']}
        done=subprocess.run(command,cwd=ROOT,env=env,capture_output=True,text=True)
        process=read(directory/'process.json') if (directory/'process.json').exists() else {}
        job=dict(command=command,guard=str(directory),process=process,guardExit=done.returncode,stdout=done.stdout,stderr=done.stderr)
        assert done.returncode==0 and process.get('complete') and process.get('returncode')==0 and not process.get('stoppedFor'),job
        return job
    started=time.monotonic(); error=None
    try:
        report['executionPerformed']=True
        case=cases[pending['case']]; prefix=out/label
        row=dict(round=1,case=case['name'],role='b2',passed=False,resumed=True)
        row['argv']=native_args(context,'b2',case['source']['file'],prefix); report['rows'].append(row)
        row['job']=guarded(label,row['argv']); row['processWallMs']=1000*row['job']['process']['wallSeconds']
        output=pin(str(prefix)+'.1.c'); row['outputs']=[output]
        assert (output['sha256'],output['bytes'])==(case['oracle']['sha256'],case['oracle']['bytes'])
        assert Path(output['file']).read_bytes()==Path(case['oracle']['file']).read_bytes()
        logs=(Path(row['job']['guard'])/'stderr.log').read_text()
        clocks=re.findall(r'^request=1 request_ms=(\d+) consumed_chars=(\d+)$',logs,re.M); assert len(clocks)==1
        row.update(requestMs=int(clocks[0][0]),requestsMs=[int(clocks[0][0])],consumedChars=[int(clocks[0][1])])
        for key in ['base_prepare_ms','runtime_prepare_ms']:
            values=re.findall(r'^'+key+r'=(\d+)$',logs,re.M); assert len(values)==1; row[key]=int(values[0])
        row.update(exactC=True,passed=True); save(out/'report.json',report)
        report['summary']=summarize(report['rows'],list(cases),['b1','b2'])
        for case in cases.values():
            selected=next(x for x in report['rows'] if x['case']==case['name'] and x['role']=='b2')
            executable=out/(case['name']+'.program'); clang=context['clang']['file']
            result=dict(case=case['name'],input=selected['outputs'][0],passed=False); report['programExecutions'].append(result)
            result['build']=guarded(case['name']+'-clang',[clang,'-isystem',str(Path(clang).parents[1]/'include/clang'),'-O2',result['input']['file'],'-o',str(executable),'-lm','-pthread'])
            result['binary']=pin(executable)
            result['run']=guarded(case['name']+'-execute',[str(executable),'--threads','1','--gpu','off'],20)
            stdout=Path(result['run']['guard'])/'stdout.log'; stderr=Path(result['run']['guard'])/'stderr.log'
            result.update(stdout=pin(stdout),stderr=pin(stderr),expected=case['expectedStdout'])
            assert stdout.read_text().rstrip('\n')==case['expectedStdout'],'Generated program stdout changed'
            result['passed']=True; save(out/'report.json',report)
            print(json.dumps(dict(case=case['name'],exactC=True,executionPassed=True)),flush=True)
        assert len(report['rows'])==90 and len(report['programExecutions'])==45 and report['newTargetJobsStarted']==91
    except BaseException as exc:
        error=exc; report['error']=f'{type(exc).__name__}: {exc}'
    try: final_inputs(); report['inputsUnchanged']=True
    except BaseException as exc: error=error or exc; report['inputVerificationError']=str(exc)
    report.update(complete=error is None,passed=error is None,elapsedSeconds=time.monotonic()-started,
        compilerOutputs=90 if error is None else sum(x.get('passed',False) for x in report['rows']))
    save(out/'report.json',report)
    if error: raise error

if __name__=='__main__': main()
