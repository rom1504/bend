#!/usr/bin/env python3
"""Compile a Base-importing Bend source with the qualified native compiler; no Node host."""
import argparse,datetime,hashlib,json,os,shutil,subprocess,sys,tempfile
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
DEFAULT=HERE/'native-admission.json'

def pin(file):
    file=Path(file).resolve();h=hashlib.sha256()
    with file.open('rb') as f:
        for data in iter(lambda:f.read(1024*1024),b''):h.update(data)
    return dict(file=str(file),sha256=h.hexdigest(),bytes=file.stat().st_size)

def verify(record):
    actual=pin(record['file']);assert actual==record,'Artifact changed: '+actual['file'];return actual

def load(pointer,live=False):
    pointer_pin=pin(pointer);selection=json.loads(Path(pointer_pin['file']).read_text())
    assert selection['kind']=='phase90-native-compiler-selection' and selection['complete']
    admission_pin=verify(selection['admission']);admission=json.loads(Path(admission_pin['file']).read_text())
    assert admission['kind']=='phase90-native-self-hosted-compiler-admission' and admission['version']==1 and admission['complete']
    assert not admission['cPatched'] and admission['selfQualified'] and admission['liveQualified'] and admission['cachedQualified']
    assert admission['source']['sha256']=='d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
    assert admission['runtime']['sha256']=='9e1c59078878be94052cb4d2d63a713e19e29b41ed3f94b034f2175a50efd0a9'
    for k in ['binary','base','runtime','template']:verify(admission[k])
    assert len(admission['parts'])==5 and len(admission['effects'])==9
    for i,part in enumerate(admission['parts']):
        verify(part);assert part['file']==admission['runtime']['file']+f'.part{i}'
    for effect in admission['effects']:verify(effect)
    if not live:
        verify(admission['cache']['carrier']);assert admission['cacheBasePath']==admission['base']['file']
        assert admission['cache']['carrier']['sha256']=='07af8cddb84820d861fc9f5d9475907754a64a9319de7d597c925149d8b186a7'
    return admission,dict(selection=pointer_pin,admission=admission_pin)

def native_args(admission,source,prefix,calls=1,live=False):
    assert calls in (1,5)
    argv=[admission['binary']['file'],'--threads','1','--gpu','off','--',admission['argvSentinel'],str(Path(source).resolve()),
          admission['base']['file'],admission['runtime']['file'],admission['effectsDir'],str(Path(prefix).resolve()),str(calls)]
    if not live:argv.extend([admission['cache']['carrier']['file'],admission['cache']['stamp']])
    return argv

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('source',type=Path);p.add_argument('-o','--output',type=Path,required=True)
    p.add_argument('--live',action='store_true');p.add_argument('--admission',type=Path,default=DEFAULT)
    p.add_argument('--calls',type=int,choices=[1,5],default=1,help='Diagnostic repeat count; every generated C must agree')
    p.add_argument('--seconds',type=int,default=60);a=p.parse_args();assert 1<=a.seconds<=600
    log_root=ROOT/'selfhost/build/native/requests';log_root.mkdir(parents=True,exist_ok=True)
    out=Path(tempfile.mkdtemp(prefix=datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ-'),dir=log_root))
    report=dict(kind='phase90-native-compiler-request',complete=False,method=pin(__file__),log=str(out));status=1
    try:
        source=pin(a.source);assert source['bytes']<=16*1024**2
        destination=a.output.resolve();assert not destination.exists(),'Output already exists'
        admission,binding=load(a.admission,a.live);prefix=out/'program'
        argv=native_args(admission,source['file'],prefix,a.calls,a.live)
        guard=ROOT/'selfhost/tools/performance/phase86/guard.py'
        command=[sys.executable,'-B',str(guard),'--out',str(out/'guard'),'--seconds',str(a.seconds),'--rss-mib','2048','--available-mib','4096','--cpu','3','--',*argv]
        report.update(source=source,selection=binding,live=a.live,calls=a.calls,command=command)
        job=subprocess.run(command,capture_output=True,text=True)
        (out/'launcher.stdout').write_text(job.stdout);(out/'launcher.stderr').write_text(job.stderr)
        process=json.loads((out/'guard/process.json').read_text());report['process']=process
        stderr=out/'guard/stderr.log'
        if stderr.exists():sys.stderr.write(stderr.read_text())
        assert job.returncode==0 and process['complete'] and process['returncode']==0 and not process.get('stoppedFor'),'Compilation failed; see retained request evidence'
        outputs=[pin(Path(str(prefix)+f'.{i}.c')) for i in range(1,a.calls+1)]
        generated=outputs[0]
        assert all(0<record['bytes']<=64*1024**2 for record in outputs)
        assert all((record['sha256'],record['bytes'])==(generated['sha256'],generated['bytes']) for record in outputs),'Repeated generated C differs'
        report.update(outputs=outputs,repeatedCEqual=True)
        assert pin(source['file'])==source and load(a.admission,a.live)==(admission,binding),'Inputs changed during request'
        destination.parent.mkdir(parents=True,exist_ok=True)
        with tempfile.NamedTemporaryFile(prefix='.'+destination.name+'.',dir=destination.parent) as f:
            with Path(generated['file']).open('rb') as r:shutil.copyfileobj(r,f)
            f.flush();assert pin(f.name)['sha256']==generated['sha256'];os.link(f.name,destination)
        report.update(complete=True,generated=generated,output=pin(destination));status=0
    except Exception as error:
        report['error']=str(error);print('native compiler: '+str(error),file=sys.stderr)
    finally:
        (out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print('Request evidence: '+str(out),file=sys.stderr)
    return status

if __name__=='__main__':sys.exit(main())
