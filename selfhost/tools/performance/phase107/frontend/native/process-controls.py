#!/usr/bin/env python3
"""Host-only paired wait-method probe; no compiler, emitted program, or API execution."""
import argparse, errno, hashlib, importlib.util, json, os, shutil, statistics, subprocess, sys, time
from pathlib import Path
from unittest import mock
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
CHILD='''import json,os,sys,time
record,delay,code=sys.argv[1:];start=time.monotonic_ns()
data=dict(pid=os.getpid(),startedNs=start)
with open(record,'w') as f:json.dump(data,f)
sys.stdout.write('out\\n');sys.stdout.flush()
time.sleep(float(delay))
sys.stderr.write('err\\n');sys.stderr.flush()
data.update(finishedNs=time.monotonic_ns())
with open(record,'w') as f:json.dump(data,f)
raise SystemExit(int(code))
'''
def pin(file):
    file=Path(file).resolve(strict=True);raw=file.read_bytes();return dict(file=str(file),bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);p.add_argument('--rounds',type=int,default=7);a=p.parse_args();assert 1<=a.rounds<=30
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False);helper=HERE/'process.py';spec=importlib.util.spec_from_file_location('p107_process',helper);process=importlib.util.module_from_spec(spec);spec.loader.exec_module(process)
    inputs=[pin(__file__),pin(helper),pin(sys.executable),pin(subprocess.__file__),pin(process.selectors.__file__)]
    shutil.copyfile(__file__,out/'method.py');shutil.copyfile(helper,out/'process.py');child=out/'child.py';child.write_text(CHILD)
    report=dict(kind='phase107-pidfd-supervision-probe',complete=False,passed=False,started=time.time(),inputs=inputs,snapshots=[pin(out/'method.py'),pin(out/'process.py'),pin(child)],python=sys.version,affinity=sorted(os.sched_getaffinity(0)),rounds=a.rounds,jobs=[],controls=[],scope='Host-only child sleeps/exits/timeouts. No compiler or generated-program speedup claim; integration remains separate.',clockScope='Alternating subprocess.run versus process.run, same Python -I -S child, full invocation wall. returnLagSeconds is parent return minus child final timestamp before metadata flush/exit, so includes small child shutdown cost. Popen capture wrapper is identical in both arms.')
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save();real_popen=subprocess.Popen
    def trial(label,method,delay=0,code=0,timeout=2,exception=None,check=False):
        so,se,record=out/(label+'.stdout'),out/(label+'.stderr'),out/(label+'.child.json');children=[]
        def spawn(*args,**kwargs):
            c=real_popen(*args,**kwargs);children.append(c);return c
        command=[sys.executable,'-I','-S',child,record,str(delay),str(code)];row=dict(label=label,method=method,command=list(map(str,command)),delaySeconds=delay,timeoutSeconds=timeout,expectedExit=code,expectedException=exception.__name__ if exception else None);report['jobs'].append(row);save();caught=None;result=None
        fds_before=len(os.listdir('/proc/self/fd'))
        with so.open('xb') as stdout,se.open('xb') as stderr,mock.patch.object(subprocess,'Popen',spawn):
            before=time.monotonic_ns()
            try:result=(subprocess.run if method=='stdlib' else process.run)(row['command'],stdout=stdout,stderr=stderr,timeout=timeout,check=check)
            except BaseException as error:caught=error
            after=time.monotonic_ns()
        row.update(seconds=(after-before)/1e9,stdout=pin(so),stderr=pin(se),exception=repr(caught) if caught else None,pids=[c.pid for c in children])
        for c in children:
            try:pid,status=os.waitpid(c.pid,os.WNOHANG)
            except ChildProcessError:continue
            if pid==0:c.kill();c.wait()
            raise AssertionError('runner did not reap child '+str(c.pid))
        row['reaped']=True;assert len(os.listdir('/proc/self/fd'))==fds_before,'fd leak'
        if children:row['returncode']=children[0].returncode
        if record.exists():
            data=json.loads(record.read_text());row['child']=pin(record)
            if 'finishedNs' in data:row.update(childWorkSeconds=(data['finishedNs']-data['startedNs'])/1e9,returnLagSeconds=(after-data['finishedNs'])/1e9)
        if result is not None:row.update(returncode=result.returncode,waitMethod=getattr(result,'wait_method','stdlib'),fallback=getattr(result,'wait_fallback',None))
        elif isinstance(caught,subprocess.TimeoutExpired):row.update(returncode=children[0].returncode,waitMethod=getattr(caught,'wait_method','stdlib'))
        save()
        assert (caught is None) if exception is None else isinstance(caught,exception),(label,repr(caught))
        if exception is subprocess.TimeoutExpired:assert children and children[0].returncode==-9 and so.read_bytes() in [b'',b'out\n'] and se.read_bytes()==b''
        elif exception is None or exception is subprocess.CalledProcessError:
            assert children[0].returncode==code and so.read_bytes()==b'out\n' and se.read_bytes()==b'err\n',label
        return row
    try:
        for turn in range(a.rounds):
            for index,ms in enumerate([0,10,40,100]):
                order=['stdlib','pidfd'] if (turn+index)%2==0 else ['pidfd','stdlib']
                for method in order:
                    row=trial('sample-'+str(turn)+'-'+str(ms)+'-'+method,method,ms/1000);row.update(round=turn,delayMs=ms,order=order)
                    if method=='pidfd':assert row['waitMethod'] in ['pidfd','already-exited'],'pidfd unavailable: no pidfd timing claim'
        for method in ['stdlib','pidfd']:
            trial('exit7-'+method,method,code=7);report['controls'].append(method+' nonzero exit')
            trial('check7-'+method,method,code=7,check=True,exception=subprocess.CalledProcessError);report['controls'].append(method+' checked nonzero exit')
            trial('timeout-'+method,method,delay=2,timeout=0.1,exception=subprocess.TimeoutExpired);report['controls'].append(method+' timeout killed and reaped')
        with mock.patch.object(process,'_pidfd_open',None):
            assert trial('fallback-missing','pidfd')['waitMethod']=='fallback'
            assert trial('fallback-timeout','pidfd',delay=2,timeout=0.1,exception=subprocess.TimeoutExpired)['waitMethod']=='fallback'
        def unsupported(*args):raise OSError(errno.ENOSYS,'controlled unsupported pidfd')
        with mock.patch.object(process,'_pidfd_open',unsupported):assert trial('fallback-unsupported','pidfd')['waitMethod']=='fallback'
        report['controls']+=['missing pidfd fallback','fallback timeout killed and reaped','unsupported pidfd fallback']
        original_selector=process._selector;interruptions=[]
        def interrupted_selector():
            selector=original_selector();original_select=selector.select
            def select(timeout):
                interruptions.append(timeout)
                if len(interruptions)==1:time.sleep(0.01);raise InterruptedError()
                return original_select(timeout)
            selector.select=select;return selector
        with mock.patch.object(process,'_selector',interrupted_selector):trial('interrupted-select','pidfd',delay=0.04)
        assert len(interruptions)>=2 and interruptions[1]<=interruptions[0]-0.005;report['controls'].append('interrupted select retries same deadline');report['interruptedSelectTimeouts']=interruptions
        def broken_selector():raise RuntimeError('controlled selector failure')
        with mock.patch.object(process,'_selector',broken_selector):trial('selector-error','pidfd',delay=2,exception=RuntimeError)
        report['controls'].append('unexpected wait failure kills and reaps')
        assert trial('blocking','pidfd',timeout=None)['waitMethod']=='blocking';report['controls'].append('no-deadline blocking wait')
        try:process.run([sys.executable,'-I','-S','-c','pass'],stdout=subprocess.PIPE,stderr=None,timeout=1)
        except ValueError:report['controls'].append('PIPE rejected before spawn')
        else:raise AssertionError('PIPE accepted')
        summaries=[]
        for ms in [0,10,40,100]:
            samples={method:[r['seconds'] for r in report['jobs'] if r.get('delayMs')==ms and r['method']==method] for method in ['stdlib','pidfd']};lags={method:[r['returnLagSeconds'] for r in report['jobs'] if r.get('delayMs')==ms and r['method']==method] for method in samples};medians={k:statistics.median(v) for k,v in samples.items()};summaries.append(dict(delayMs=ms,samples=samples,returnLagSeconds=lags,medianSeconds=medians,pidfdToStdlibMedianRatio=medians['pidfd']/medians['stdlib']))
        for item in inputs:assert pin(item['file'])==item
        report.update(complete=True,passed=True,summaries=summaries)
    except BaseException as error:report['error']=repr(error);raise
    finally:report['finished']=time.time();save()
    print(json.dumps(dict(complete=True,passed=True,samples=8*a.rounds,controls=len(report['controls']),report=pin(out/'report.json'))))
if __name__=='__main__':main()
