"""Build frozen assembly alternatives and run complete, checked native workloads."""
import argparse
import json
import math
import os
from pathlib import Path
import subprocess
import sys
import time

from regions import BUILD, ROOT, digest, read
sys.path.insert(0, str(ROOT/'selfhost/tools/bench'))
import bench

HERE = Path(__file__).resolve().parent
FROZEN = HERE/'frozen.json'
ASSETS = BUILD/'phase194/assets.json'
REFERENCES = BUILD/'phase195/references01/manifest.json'
EXTRA = {
    'tree-bitonic': [(3,3),(6,17),(9,123)],
    'coverage-bst-64': [(1,3),(32,0),(61,123)],
    'editdist': [(0,17),(1,3),(3,123)],
    'variation-ray-active-64-2440': [(16,17),(64,2240),(128,2440)],
    'lexer': [(2,3),(6,17),(10,123)],
}


def save(path, value):
    path.write_text(json.dumps(value,indent=2)+'\n')


def cases():
    return {c['id']:c for c in read(REFERENCES)['cases'] if c['id'] in EXTRA}


def checked_tool(pin):
    path=ROOT/pin['file']
    assert digest(path)==pin['sha256'],path
    return str(path)


def execute(exe,args,reps,warmups,expected,convention='bend-rts-v1'):
    cmd=[str(exe),*bench.native_runtime_arguments({'runtimeArgumentConvention':convention}),str(reps),str(warmups),*map(str,args)]
    started=time.monotonic()
    child=subprocess.run(cmd,capture_output=True,timeout=12)
    wall=time.monotonic()-started
    if expected is None:
        first=child.stdout.decode().splitlines()[0]
        assert first.isdecimal(),first
        expected=first+'\n'
    elapsed=bench.observation(child.stdout,child.stderr,child.returncode,
                              dict(expectedStdout=expected,repetitions=reps,warmups=warmups),wall)
    return dict(stdout=child.stdout.decode(),elapsedMs=elapsed,wall=wall), expected


def build(out, frozen):
    assets=read(ASSETS)
    toolchain=assets['toolchains']['x86']
    assembler,linker,runtime=[checked_tool(assets['assets'][k]) for k in ['assembler','linker','qbe-runtime']]
    refs=cases()
    result=dict(freeze=digest(FROZEN),assets=digest(ASSETS), references=digest(REFERENCES),cases={})
    for case,prof in frozen['profiles'].items():
        original=ROOT/prof['assembly']
        assert digest(original)==prof['assemblySha'] and digest(ROOT/prof['elf'])==prof['elfSha']
        lines=original.read_text().splitlines()
        rows=[r for r in frozen['candidates'] if r['case']==case]
        ref=refs[case]
        assert checked_tool(ref['source']) and checked_tool(ref['expectedFile'])
        c=ref['products']['c']
        point=ref['point']
        oracles=[]
        for i,args in enumerate([point['runtimeArgs'],*EXTRA[case]]):
            # The fixed catalog harness counts matches against its baked-in value.
            # Extra points print the actual result once with empty timed/warmup loops.
            reps=1 if i==0 else 0
            measured,expected=execute(checked_tool(c['artifact']),args,reps,0,
                              point['expectedStdout'] if i==0 else None,c['runtimeArgumentConvention'])
            oracles.append(dict(args=args,repetitions=reps,expected=expected,cObservation=measured))
        products={}
        for row in [None,*rows]:
            name=row['name'] if row else 'baseline'
            directory=out/case/name
            directory.mkdir(parents=True)
            source=directory/'program.s'
            variant=lines.copy()
            if row:
                i=row['line']-1
                assert [s.strip() for s in lines[i:i+len(row['before'])]]==row['before']
                variant[i:i+len(row['before'])]=['  '+s for s in row['after']]
            source.write_text('\n'.join(variant)+'\n')
            if not row: assert source.read_bytes()==original.read_bytes()
            obj,elf=directory/'program.o',directory/'program'
            for cmd in ([assembler,*toolchain['assemblerFlags'],'-o',obj,source],
                        [linker,*toolchain['linkerFlags'],obj,runtime,*toolchain['libraries'],'-o',elf]):
                child=subprocess.run(cmd,capture_output=True,timeout=15)
                assert child.returncode==0 and not child.stderr,child.stderr
            obs=[execute(elf,v['args'],v['repetitions'],0,v['expected'])[0] for v in oracles]
            products[name]=dict(file=str(elf.relative_to(ROOT)),sha256=digest(elf),objectSha=digest(obj),sourceSha=digest(source),checks=obs)
        result['cases'][case]=dict(point=point,oracles=oracles,cProduct=c['artifact'],products=products)
        save(out/'build.json',result)
    result['complete']=True
    save(out/'build.json',result)


def measure(out, built, reverse):
    build_report=read(built)
    assert build_report['complete'] and build_report['freeze']==digest(FROZEN)
    result=dict(buildSha=digest(built),reverse=reverse,rows=[],pilots=[])
    cases_order=list(build_report['cases'])
    if reverse: cases_order.reverse()
    started=time.monotonic()
    for case in cases_order:
        row=build_report['cases'][case]
        point=row['point']
        names=list(row['products'])
        if reverse:names.reverse()
        paths={k:checked_tool(v) for k,v in row['products'].items()}
        args,expected=point['runtimeArgs'],point['expectedStdout']
        n=point['repetitions']
        for attempt in range(10):
            v,_=execute(paths['baseline'],args,n,4,expected)
            result['pilots'].append(dict(case=case,n=n,**v))
            if 250<=v['elapsedMs']<=550:break
            n=max(1,math.ceil(n*330/max(1,v['elapsedMs'])))
        else: raise ValueError('Calibration failed: '+case)
        for ri in range(8):
            shift=ri%4
            order=names[shift:]+names[:shift]
            for role in order:
                v,_=execute(paths[role],args,n,4,expected)
                assert v['elapsedMs']>=100
                result['rows'].append(dict(case=case,name=role,round=ri,repetitions=n,**v))
            save(out/'timing.json',result)
    assert all(digest(ROOT/v['file'])==v['sha256'] for r in build_report['cases'].values() for v in r['products'].values())
    result.update(complete=True,wallSeconds=time.monotonic()-started)
    save(out/'timing.json',result)


if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('stage',choices=['build','measure'])
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--built',type=Path)
    p.add_argument('--reverse',action='store_true')
    args=p.parse_args()
    assert os.sched_getaffinity(0)=={3}
    args.out.mkdir(parents=True,exist_ok=False)
    if args.stage=='build': build(args.out,read(FROZEN))
    else: measure(args.out,args.built,args.reverse)
