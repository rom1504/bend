"""Measure source-level zipper representation changes on the Phase199 native compiler."""
import argparse
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.append(str(ROOT/'research/phase199/scan-transfer'))
from baseline import authenticate, command, pin, read, write

FLAGS=['+RTS','--threads','1','--gpu','off','-RTS','--RTS']


def execute(exe,point,n,w):
    start=time.monotonic()
    p=subprocess.run([str(exe),*FLAGS,str(n),str(w),*map(str,point['inputs'])],capture_output=True,timeout=10)
    wall=time.monotonic()-start
    words=p.stdout.decode(errors='replace').splitlines()
    assert p.returncode==0 and not p.stderr and len(words)==4 and words[:3]==[str(point['digest']),str(w),str(n)] and words[3].isdecimal(),(point,words,p.stderr)
    ms=int(words[3]);assert ms<=wall*1000+2
    return dict(stdout=words,elapsedMs=ms,seconds=wall,repetitions=n,
                nsPerInvocation=ms*1e6/n if n else None)


def main(a):
    assert os.sched_getaffinity(0)=={3};out=a.out.resolve();out.mkdir(parents=True)
    spec=read(a.source);src=authenticate(spec['source']);assert Path(src).name=='coverage-bst-64.bend'
    case='coverage-bst-64'
    qualified=read(ROOT/'selfhost/build/phase198/p199-integrated-live-plan02/manifest.json')
    products=next(row for row in qualified['cases'] if row['id']==case)['products']
    old=Path(authenticate(products['candidate']['artifact']))
    c=Path(authenticate(products['c']['artifact']))
    request=read(ROOT/f'selfhost/build/phase198/p199-integrated-native45-01/{case}/machine/report.json')
    for item in request['inputs']:authenticate(item)
    cc=authenticate(read(ROOT/'selfhost/build/phase194/assets.json')['assets']['linker'])
    runtime=read(ROOT/'selfhost/build/phase199/runtime-bundle01/report.json')['variants']['live']['bundle']
    bundle=authenticate(runtime)
    report=dict(complete=False,source=pin(a.source),runtime=runtime,stock=pin(old),c=pin(c),roles={},checks=[],samples=[])
    write(out/'report.json',report)
    paths={'stock':old}
    for role in a.roles.split(','):
        file=authenticate(spec['roles'][role]);d=out/role;d.mkdir()
        try:
            command(d,'source-check',['selfhost/.assets/bin/bun','selfhost/tools/build/check-source.mjs','--source',file,
                '--out',d/'upstream','--manifest','selfhost/src/compiler.json','--upstream','selfhost/.bootstrap/upstream-phase182'])
            accepted=read(d/'upstream/report.json');assert accepted['complete'] and accepted['unresolvedHoles']==0
            argv=request['compilerCommand'][:];assert argv[8]=='x86-object';argv[9]=file
            obj=d/'program.o';command(d,'emit',argv,obj);assert obj.read_bytes().startswith(b'\x7fELF')
            exe=d/'program';tc=request['toolchain']
            command(d,'link',[cc,*tc['linkerFlags'],obj,bundle,*tc['libraries'],'-o',exe])
            report['roles'][role]=dict(source=pin(Path(file)),checker=pin(d/'upstream/report.json'),object=pin(obj),exe=pin(exe))
            paths[role]=exe
        except Exception as e:
            report['roles'][role]=dict(source=pin(Path(file)),refusal=str(e)[:900])
        write(out/'report.json',report)
    assert len(paths)>1
    for point in spec['cases']:
        n=int(point is spec['cases'][0])
        proof={r:execute(b,point,n,0) for r,b in {'c':c,**paths}.items()}
        report['checks'].append(dict(point=point,roles=proof));write(out/'report.json',report)
    point=spec['cases'][0]
    counts={}
    for role,exe in paths.items():
        n=1024
        for _ in range(8):
            x=execute(exe,point,n,2)['elapsedMs']
            if 100<=x<=210:break
            n=max(1,round(n*140/max(1,x)))
        else:raise ValueError('calibration '+role)
        counts[role]=n
    names=list(paths)
    for order in (names,names[::-1]):
        pairs=[]
        for i in range(len(order)):
            obs={}
            for role in order[i:]+order[:i]:
                obs[role]=execute(paths[role],point,counts[role],3)
            pairs.append(obs)
        report['samples'].append(pairs);write(out/'report.json',report)
    report['sessions']=[{r:statistics.median(o[r]['nsPerInvocation']/o['stock']['nsPerInvocation'] for o in pairs)
                          for r in paths if r!='stock'} for pairs in report['samples']]
    report['complete']=True;write(out/'report.json',report)
    print(report['sessions'])


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--roles',default='compact,direct');main(p.parse_args())
