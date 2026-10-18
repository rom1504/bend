#!/usr/bin/env python3
"""Sample unchanged compiler executable; diagnostics are separate from timing."""
import argparse,importlib.util,json,os,sys,time
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3]
s=importlib.util.spec_from_file_location('run',HERE/'run.py');R=importlib.util.module_from_spec(s);s.loader.exec_module(R)
def main():
    p=argparse.ArgumentParser();p.add_argument('--compiler',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--source',type=Path,required=True);p.add_argument('--oracle',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--sampler',type=Path,required=True);p.add_argument('--period-us',type=int,default=8000);a=p.parse_args();out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
    release,binding=R.N.load();argv=R.N.native_args(release,a.source,out/'program',calls=5);argv[0]=str(a.compiler.resolve());argv[argv.index(release['assets']['runtime']['file'])]=str(a.runtime.resolve())
    inputs=[R.pin(x) for x in [a.compiler,a.runtime,a.source,a.sampler,a.oracle,__file__]]
    report=dict(kind='phase108-leaf-profile',complete=False,inputs=inputs,command=argv,periodUs=a.period_us);R.save(out/'report.json',report)
    env=dict(os.environ,LD_PRELOAD=str(a.sampler.resolve()),BEND_SAMPLE_OUT=str(out/'samples.txt'),BEND_SAMPLE_PERIOD_US=str(a.period_us))
    with (out/'stdout').open('xb') as stdout,(out/'stderr').open('xb') as stderr:r=R.P.run(argv,stdout=stdout,stderr=stderr,env=env,cwd=ROOT,timeout=180)
    report['status']=r.returncode
    if r.returncode:raise RuntimeError('profiled compiler failed')
    report['outputs']=[R.pin(out/f'program.{i}.c') for i in range(1,6)]
    assert all(x['sha256']==R.pin(a.oracle)['sha256'] for x in report['outputs'])
    analysis=HERE.parent/'phase68/parity-survey/sample-analysis-v2.py'
    spec=importlib.util.spec_from_file_location('analysis',analysis);M=importlib.util.module_from_spec(spec);spec.loader.exec_module(M)
    header,maps,pcs=M.parse(out/'samples.txt');report['header']=header
    # Non-PIE images: nm addresses and sampled PCs share a coordinate system.
    import subprocess,bisect,collections
    symbols=[]
    for line in subprocess.check_output(['nm','-n','--defined-only',str(a.compiler)],text=True).splitlines():
        fields=line.split()
        if len(fields)>=3 and fields[1] in ['t','T']:symbols.append((int(fields[0],16),fields[2]))
    keys=[x[0] for x in symbols];counts=collections.Counter()
    for pc,count in pcs.items():
        mapping=next((m for m in maps if m['start']<=pc<m['end']),None)
        if not mapping or Path(mapping['path'])!=a.compiler.resolve():counts['[other mapping]']+=count;continue
        i=bisect.bisect_right(keys,pc)-1;counts[symbols[i][1] if i>=0 else '[unknown]']+=count
    report['topLeafSymbols']=[dict(name=k,samples=n,fraction=n/header['samples']) for k,n in counts.most_common(40)]
    report['samples']=R.pin(out/'samples.txt');report['zeroLoss']=not header['dropped'] and not header['overruns'];report['complete']=True
    for x in inputs:R.N.verify(x)
    R.save(out/'report.json',report);print(json.dumps(dict(complete=True,samples=header['samples'],zeroLoss=report['zeroLoss'],top=report['topLeafSymbols'][:15])))
if __name__=='__main__':main()
