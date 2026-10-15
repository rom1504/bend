#!/usr/bin/env python3
"""One guarded self-emission after immutable eight-case qualification; no repeated gates."""
import argparse,json,re,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
P=ROOT/'selfhost/tools/performance'
sys.path.insert(0,str(P/'phase88'))
from native_support import authenticate,DEFAULT_CACHE,pin,verify
from own_native_support import authenticate_own,own_args
from whitespace_oracles import load_oracles
GUARD=P/'phase86/guard.py'

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('image',type=Path);ap.add_argument('gates',type=Path);ap.add_argument('out',type=Path)
    ap.add_argument('--check-only',action='store_true');ap.add_argument('--seconds',type=int,default=240)
    args=ap.parse_args();assert 1<=args.seconds<=240
    out=args.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase90')
    out.mkdir(parents=True,exist_ok=False)
    report=dict(kind='phase90-c-patched-native-self-emission-diagnostic',complete=False,passed=False,
        checkOnly=args.check_only,executionPerformed=False,method=pin(__file__),inputs=[],
        scope='One C-patched native compiler diagnostic self-emission, compared to original checked JS B1 C; not its patched build source, native B2 or public image qualification.')
    def save():(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    save();inputs={}
    def bound(p):
        a=verify(p);previous=inputs.setdefault(a['file'],a);assert previous==a;return a
    def file(p):return bound(pin(p))
    def tree(v):
        if isinstance(v,dict):
            if 'sha256' in v and 'bytes' in v and ('file' in v or 'path' in v):bound(v)
            else:
                for x in v.values():tree(x)
        elif isinstance(v,list):
            for x in v:tree(x)
    def read(p):return json.loads(Path(p).read_text())
    def unchanged():
        for p in inputs.values():verify(p)
    try:
        for p in [__file__,HERE/'own_native_support.py',HERE/'whitespace_oracles.py',GUARD,P/'programs/support.py',P/'phase88/native_support.py',sys.executable]:file(p)
        auth=authenticate_own(args.image,None);tree(auth)
        old=authenticate(ROOT/'selfhost/build/phase88/compiler-native02',DEFAULT_CACHE);tree(old)
        qualification=file(args.gates);assert Path(qualification['file']).name=='gates.json'
        gates=read(qualification['file']);tree(gates['inputs'])
        assert gates['kind']=='phase90-c-patched-native-diagnostic-gates'
        assert gates['complete'] and gates['passed'] and gates['executionPerformed'] and not gates['checkOnly']
        assert gates['liveQualified'] and gates['cacheQualifiedForThisExperiment']
        method=bound(gates['method']);assert method==file(HERE/'own-native-gates.py')
        assert method['sha256']=='6585803ad190556134d9dceaf79a9b29a19183a615d924ea50d9f8ec4eb1dfc3'
        assert gates['nativeCompiler']==auth and gates['cacheOrigin']==old['cache']
        source=bound(gates['source']);assert source==auth['source']
        assert source['sha256']=='d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
        assembly=bound(gates['derivation']);assert assembly['sha256']=='9b4c0796b7504ebcb030ae9ffe5f4d0d37dbd6ac4637e4723acf895de196fea9'
        cases,proof=load_oracles(bound(gates['cpuPreprocessingProof'])['file'],auth,file,bound,tree)
        assert gates['oracleCases']==cases
        expected=[(mode,c) for mode in ['live','cached'] for c in cases];assert len(gates['rows'])==len(expected)==8
        for row,(mode,case) in zip(gates['rows'],expected):
            assert row['name']==mode+'-'+case['name'] and row['mode']==mode
            assert row['passed'] and row['exactC'] and row['inputBindingsUnchanged'] and row['guardReturncode']==0
            assert row['source']==case['source'] and row['oracle']==case['oracle']
            output=bound(row['output']);assert all(output[k]==case['oracle'][k] for k in ['sha256','bytes'])
            directory=Path(row['guard']);process=read(file(directory/'process.json')['file'])
            assert process==row['process'] and process['complete'] and process['returncode']==0 and not process.get('stoppedFor')
            producer=auth if mode=='live' else dict(auth,cache=old['cache'])
            argv=own_args(producer,case['source']['file'],directory.parent/row['name'],1)
            assert process['command'][-len(argv):]==argv and row['command'][-len(argv):]==argv
            assert process['rssLimitBytes']==2048*1024**2 and process['availableFloorBytes']==4096*1024**2
            for p in read(file(directory/'inputs.json')['file']):bound(p)
            file(directory/'method.json')
        parent=file(ROOT/'selfhost/build/phase90/js-self11/report.json')
        assert auth['emission']==parent and auth['provenance']=='C-table-accessor-diagnostic'
        assert auth['originalProvenance']=='JS-B1-cross-host-emitted-C' and auth['diagnosticOnly']
        parent_report=read(parent['file']);oracle=bound(parent_report['output']);assert oracle==auth['c']
        cached=dict(auth,cache=old['cache'])
        report.update(qualification=qualification,producer=dict(stage='C-patched native compiler diagnostic',provenance=auth['provenance'],authentication=auth),
            source=source,derivation=assembly,ancestorNineEffectProof=gates['ancestorNineEffectProof'],base=auth['base'],runtime=auth['runtime'],
            runtimeParts=auth['runtimeParts'],effects=gates['nineEffects'],cache=old['cache'],parentEmission=parent,oracle=oracle,
            cpuPreprocessingProof=proof,inputs=list(inputs.values()),compiled=False,independentlyCompared=False)
        unchanged();save()
        if args.check_only:
            report.update(complete=True,passed=True,scope='Offline admission only; no target or self-emission.');save();return
        prefix=out/'self';directory=out/'self-guard'
        command=[sys.executable,'-B',str(GUARD),'--out',str(directory),'--seconds',str(args.seconds),'--rss-mib','2048','--available-mib','4096','--cpu','3','--',*own_args(cached,source['file'],prefix,1)]
        report.update(command=command,guard=str(directory),executionPerformed=True);save()
        job=subprocess.run(command,capture_output=True,text=True)
        report.update(guardReturncode=job.returncode,guardStdout=job.stdout,guardStderr=job.stderr)
        process=read(directory/'process.json') if (directory/'process.json').exists() else {};report['process']=process
        output=Path(str(prefix)+'.1.c')
        if output.exists():report['c']=pin(output)
        stderr=(directory/'stderr.log').read_text() if (directory/'stderr.log').exists() else ''
        report['requestMs']=list(map(int,re.findall(r'request=\d+ request_ms=(\d+)',stderr)))
        report['exactC']=bool(report.get('c') and all(report['c'][k]==oracle[k] for k in ['sha256','bytes']))
        report['guardReceipts']=[pin(p) for p in sorted(directory.glob('*')) if p.is_file()]
        unchanged();assert authenticate_own(args.image,None)==auth
        assert authenticate(ROOT/'selfhost/build/phase88/compiler-native02',DEFAULT_CACHE)==old
        report['inputsUnchanged']=True
        success=job.returncode==0 and process.get('complete') and process.get('returncode')==0 and not process.get('stoppedFor')
        success=bool(success and report['exactC'] and len(report['requestMs'])==1)
        report.update(complete=success,passed=success,independentlyCompared=success);save()
        assert success,'Self-emission failed or full C differs; preserved process, partial outputs and comparison.'
    except Exception as error:
        report['error']=str(error);report['retainedRefusalOrFailure']=True;save();raise

if __name__=='__main__':main()
