#!/usr/bin/env python3
"""One native06 request with explicit new runtime transport; no repeated historical gates."""
import argparse,json,re,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
from support import ROOT,P,args as native_args,transition,historical,read,pin,verify
from image_support import authenticate_unqualified

def request_auth(image,build,live=False):
    auth,provenance=authenticate_unqualified(image,build)
    if live:auth=dict(auth,cache=None)
    return auth,provenance
GUARD=P/'phase86/guard.py'

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('image',type=Path);ap.add_argument('build',type=Path);ap.add_argument('out',type=Path)
    ap.add_argument('--expect-error',choices=['parse','check'])
    ap.add_argument('--source',type=Path);ap.add_argument('--oracle',type=Path)
    ap.add_argument('--seconds',type=int,default=240);ap.add_argument('--calls',type=int,choices=[1,5],default=1)
    ap.add_argument('--live',action='store_true');ap.add_argument('--check-only',action='store_true')
    a=ap.parse_args();assert 1<=a.seconds<=600
    out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase90');out.mkdir(parents=True,exist_ok=False)
    report=dict(kind='phase90-native-runtime-migrated-emission',complete=False,passed=False,executionPerformed=False,
        checkOnly=a.check_only,method=pin(__file__),scope='Native07 built from unpatched native06 C independently equal to genuine JS B2. Actual request and optional exact C or expected semantic rejection; final public admission remains separate.')
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save()
    try:
        auth,provenance=request_auth(a.image,a.build,a.live)
        source=pin(a.source) if a.source else verify(auth['source'])
        assert source['bytes']<=16*1024**2
        oracle=pin(a.oracle) if a.oracle else None
        self_pin=pin(ROOT/'selfhost/build/phase90/own-native06-self01/report.json');prior=read(self_pin['file'])
        assert prior['kind']=='phase90-c-patched-native-self-emission-diagnostic'
        assert prior['complete'] and prior['passed'] and prior['exactC'] and prior['inputsUnchanged']
        assert prior['producer']['authentication']==provenance['originProducer']
        assert prior['source']==auth['source'] and prior['c']['sha256']==provenance['originProducer']['c']['sha256']
        process=read(prior['guard']+'/process.json')
        assert process==prior['process'] and process['complete'] and process['returncode']==0 and not process.get('stoppedFor')
        runtime=provenance['requestRuntime']
        report.update(producer=dict(stage='native compiler built from unpatched native06 emission',authentication=provenance['producer'],build=provenance['build'],priorSelfEmission=self_pin),
            transition=provenance['transition'],transport=provenance['transport'],subject=source,
            requestRuntime={k:runtime[k] for k in ['plan','ready','templateReceipt','runtime','template','driver','parts','effects','effectsDir']},
            sourceUnchanged=source==auth['source'],cache=auth['cache'],base=auth['base'],calls=a.calls,oracle=oracle,expectedError=a.expect_error,
            methods=[pin(__file__),pin(Path(__file__).with_name('support.py')),pin(Path(__file__).with_name('image_support.py')),pin(GUARD),pin(P/'programs/support.py')])
        save()
        if a.check_only:report.update(complete=True,passed=True);save();return
        prefix=out/'output';directory=out/'guard'
        command=[sys.executable,'-B',str(GUARD),'--out',str(directory),'--seconds',str(a.seconds),
            '--rss-mib','2048','--available-mib','4096','--cpu','3','--',*native_args(auth,source['file'],prefix,a.calls)]
        report.update(executionPerformed=True,command=command,guard=str(directory));save()
        result=subprocess.run(command,capture_output=True,text=True)
        process=read(directory/'process.json') if (directory/'process.json').exists() else {}
        outputs=[pin(Path(str(prefix)+f'.{i}.c')) for i in range(1,a.calls+1) if Path(str(prefix)+f'.{i}.c').exists()]
        stderr=(directory/'stderr.log').read_text() if (directory/'stderr.log').exists() else ''
        report.update(guardReturncode=result.returncode,guardStdout=result.stdout,guardStderr=result.stderr,process=process,outputs=outputs,
            requestMs=list(map(int,re.findall(r'request=\d+ request_ms=(\d+)',stderr))),
            guardReceipts=[pin(p) for p in sorted(directory.glob('*')) if p.is_file()])
        if outputs:report['output']=outputs[-1]
        report['exactC']=None if oracle is None else all(all(p[k]==oracle[k] for k in ['sha256','bytes']) for p in outputs)
        current,_=request_auth(a.image,a.build,a.live);assert current==auth and pin(source['file'])==source
        assert pin(self_pin['file'])==self_pin
        for m in report['methods']:verify(m)
        if oracle:verify(oracle)
        report['inputsUnchanged']=True
        success=result.returncode==0 and process.get('complete') and process.get('returncode')==0 and not process.get('stoppedFor')
        success=bool(success and len(outputs)==a.calls and len(report['requestMs'])==a.calls
            and len({p['sha256'] for p in outputs})==1 and all(0<p['bytes']<=64*1024**2 for p in outputs)
            and (oracle is None or report['exactC']))
        if a.expect_error:
            assert oracle is None and a.calls==1
            success=bool(result.returncode!=0 and process.get('complete') and process.get('returncode')==1 and not process.get('stoppedFor')
                and not outputs and len(report['requestMs'])==1 and a.expect_error+':' in stderr)
            report['expectedRejectionObserved']=success
        report.update(complete=success,passed=success,independentlyCompared=bool(success and oracle));save()
        assert success,'Native request failed or expected C differed; all outputs and guard evidence preserved.'
    except Exception as error:
        report['error']=str(error);report['retainedRefusalOrFailure']=True;save();raise

if __name__=='__main__':main()
