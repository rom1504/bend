"""Build and compare actual checked Bend Map programs with a root-owned prefix."""
import argparse
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
from prototype import EDGE_KEYS, pin
from trace import trace

sys.path.append(str(ROOT/'research/phase196/screen'))
from measure import bench, checked_tool, execute, read, save


def oracle(out,case,role,exe,point,reps,expected,convention='bend-rts-v1'):
    command=[str(exe),*bench.native_runtime_arguments({'runtimeArgumentConvention':convention}),str(reps),'0',*map(str,point)]
    start=time.monotonic()
    run=subprocess.run(command,capture_output=True,timeout=10)
    wall=time.monotonic()-start
    receipt=dict(stdout=run.stdout.decode(errors='replace'),stderr=run.stderr.decode(errors='replace'),code=run.returncode,wall=wall)
    try:
        receipt['elapsedMs']=bench.observation(run.stdout,run.stderr,run.returncode,
            dict(expectedStdout=expected,repetitions=reps,warmups=0),wall)
    except Exception:
        save(out/'refusal.json',dict(case=case,role=role,stage='complete output and count',inputs=point,expected=expected,**receipt))
        raise
    return receipt


def main(args):
    assert os.sched_getaffinity(0)=={3}
    out=args.out.resolve();out.mkdir()
    data=read(args.source)
    assert data['complete'] and checked_tool(data['base']) and checked_tool(data['lookup'])
    assets=read(ROOT/'selfhost/build/phase194/assets.json');tc=assets['toolchains']['x86']
    cc,rt=(checked_tool(assets['assets'][k]) for k in ('linker','qbe-runtime'))
    native=read(ROOT/'selfhost/build/phase198/native45-02/report.json')['rows']
    refs=read(ROOT/'selfhost/build/phase195/references01/manifest.json')['cases']
    report=dict(complete=False,driver=pin(Path(__file__)),source=pin(args.source),cases={})
    save(out/'report.json',report)
    for name in args.cases.split(','):
        source=data['cases'][name];d=out/name;d.mkdir()
        use='coverage-map-churn-32' if name=='map-edges' else name
        old=next(x for x in native if x['id']==use);ref=next(x for x in refs if x['id']==use)
        example=read(ROOT/'selfhost/build/phase198/native45-02'/use/'machine/report.json')
        for desc in example['inputs']:checked_tool(desc)
        r=dict(products={},checks=[],samples=[],cells=[]);report['cases'][name]=r
        binaries={}
        for role in args.roles.split(','):
            if role=='stock' and use==name:
                binaries[role]=checked_tool(old['artifact']);r['products'][role]=dict(binary=old['artifact'],object=old['object'],qualified=True)
                continue
            sourcefile=checked_tool(source['roles'][role]);check=d/(role+'-source-check')
            cmd=['selfhost/.assets/bin/bun','selfhost/tools/build/check-source.mjs','--source',sourcefile,'--out',str(check),'--manifest','selfhost/src/compiler.json','--upstream','selfhost/.bootstrap/upstream-phase182']
            p=subprocess.run(cmd,capture_output=True,timeout=20)
            if p.returncode:
                detail=read(check/'report.json') if (check/'report.json').exists() else p.stderr.decode()[-1900:]
                save(out/'refusal.json',dict(case=name,role=role,stage='upstream source check',detail=detail))
                raise RuntimeError(str(detail.get('error',detail) if isinstance(detail,dict) else detail)[-1500:])
            validated=read(check/'report.json')
            assert validated['complete'] and validated['typeAccepted'] and validated['unresolvedHoles']==0
            cmd=example['compilerCommand'][:];assert cmd[8]=='x86-object';cmd[9]=sourcefile
            start=time.monotonic();p=subprocess.run(cmd,capture_output=True,timeout=45)
            if p.returncode or p.stderr or p.stdout[:4]!=b'\x7fELF':
                err=dict(case=name,role=role,stage='native source/codegen',code=p.returncode,stdout=p.stdout[:4096].decode(errors='replace'),stderr=p.stderr[:4096].decode(errors='replace'))
                save(out/'refusal.json',err);raise RuntimeError(str(err)[:1700])
            obj=d/(role+'.o');obj.write_bytes(p.stdout);exe=d/role
            p=subprocess.run([cc,*tc['linkerFlags'],obj,rt,*tc['libraries'],'-o',exe],capture_output=True,timeout=20)
            assert p.returncode==0 and not p.stderr,p.stderr
            binaries[role]=exe;r['products'][role]=dict(binary=pin(exe),object=pin(obj),sourceCheck=pin(check/'report.json'),source=source['roles'][role],compiler=pin(Path(cmd[0])),secondsToLink=time.monotonic()-start)
            save(out/'report.json',report)
        for i,point in enumerate([source['inputs'],[0,0],[1,17],[4,17],[23,99],[64,0]]):
            if 'aggregation' in name:
                amounts={}
                for j in range(point[0]):
                    key='部門'+str((j+point[1])%16)
                    amounts[key]=amounts.get(key,0)+(37*j+point[1])%1000
                expected=''.join(k+'='+str(v)+';' for k,v in sorted(amounts.items()))+'\n'
            else:
                keys=data.get('edgeKeys',EDGE_KEYS)
                expected=str(trace(*point,key=(lambda n:keys[n%len(keys)]) if name=='map-edges' else (lambda n:'key'+str(n)))['digest'])+'\n'
            if i==0:assert expected.strip()==str(source['expected'])
            entry=dict(inputs=point,expected=expected,roles={})
            if name!='map-edges':
                cref=ref['products']['c'];entry['matureC']=oracle(out,name,'matureC',checked_tool(cref['artifact']),point,int(i==0),expected,cref['runtimeArgumentConvention'])
            for k,p in binaries.items():entry['roles'][k]=oracle(out,name,k,p,point,int(i==0),expected)
            r['checks'].append(entry)
            save(out/'report.json',report)
        save(out/'report.json',report)
        if not args.time:continue
        assert 'stock' in binaries and 'cached' in binaries
        n=ref['point']['repetitions'];point=source['inputs'];expected=str(source['expected'])+'\n'
        for _ in range(8):
            obs,_=execute(binaries['stock'],point,n,2,expected)
            if 180<=obs['elapsedMs']<=320:break
            n=max(1,math.ceil(n*230/max(1,obs['elapsedMs'])))
        probe,_=execute(binaries['cached'],point,n,2,expected)
        if probe['elapsedMs']>330:
            n=max(1,round(n*230/probe['elapsedMs']))
        for session in range(2):
            orders=(('stock','clone','cached'),('clone','cached','stock'),('cached','stock','clone')) if 'clone' in binaries else (('stock','cached'),('cached','stock'),('stock','cached'),('cached','stock'))
            for ri,order in enumerate(orders):
                observations={}
                for k in (order if session==0 else tuple(reversed(order))):
                    observations[k]=execute(binaries[k],point,n,4,expected)[0]
                r['samples'].append(dict(session=session,round=ri,repetitions=n,observations=observations))
            filtered=[x['observations'] for x in r['samples'] if x['session']==session]
            for other in (k for k in ('stock','clone') if k in binaries):
                ratios=[x['cached']['elapsedMs']/x[other]['elapsedMs'] for x in filtered]
                r['cells'].append(dict(session=session,against=other,ratios=ratios,median=statistics.median(ratios)))
            save(out/'report.json',report)
    report['complete']=True;save(out/'report.json',report)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--source',type=Path,required=True)
    p.add_argument('--cases',required=True);p.add_argument('--roles',required=True);p.add_argument('--time',action='store_true')
    main(p.parse_args())
