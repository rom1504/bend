"""Check source-level fusion ceilings with the current native x86 compiler."""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
BUILD = ROOT / 'selfhost/build'
sys.path.insert(0, str(ROOT/'research/phase196/screen'))
from measure import execute, checked_tool, bench

CASES = ['coverage-expression-128','coverage-record-aggregation-256',
         'coverage-expression-32','coverage-record-aggregation-64']


def read(p):
    return json.loads(Path(p).read_bytes())


def pin(p):
    p=Path(p)
    return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size}


def alternatives(source, expression):
    prefix, old = source.split('def bench(size: U32, seed: U32) -> ')
    body, harness = old.split('# Phase93:',1)
    if expression:
        assert body.strip() == 'U32:\n  eval(p37.expr(U32.to_nat(size), seed))'
        versions = {k:(HERE/f'expr-{k}.bend').read_text() for k in ('fold','affine')}
    else:
        assert body.strip() == 'String:\n  p37.render(Map.to_list(&2, U32, p37.aggregate(p37.records(U32.to_nat(size), 0, seed), Map.new(&2, U32))))'
        f = (HERE/'records.bend').read_text()
        assert f.count('p37.amount(U32.read(U32.show(amount)))') == 1
        versions = {'fold':f, 'roundtrip':f.replace('p37.amount(U32.read(U32.show(amount)))','amount')}
    return {k:prefix+v+'\n# Phase93:'+harness for k,v in versions.items()}


def extra_output(product, point):
    exe=checked_tool(product['artifact'])
    convention=product['runtimeArgumentConvention']
    command=[exe,*bench.native_runtime_arguments({'runtimeArgumentConvention':convention}), '0','0',*map(str,point)]
    now=time.monotonic()
    p=subprocess.run(command,capture_output=True,timeout=10)
    first,sep,counts=p.stdout.partition(b'\n')
    assert sep
    expected=first.decode()+'\n'
    bench.observation(p.stdout,p.stderr,p.returncode,{'expectedStdout':expected,'repetitions':0,'warmups':0},time.monotonic()-now)
    return expected


def main(out):
    assert os.sched_getaffinity(0)=={3}
    out.mkdir(parents=True,exist_ok=False)
    reference=BUILD/'phase195/references01/manifest.json'
    ref={c['id']:c for c in read(reference)['cases']}
    manifest=BUILD/'phase198/native45-01/programs.manifest.json'
    actual={c['id']:c for c in read(manifest)['cases']}
    roles=read(manifest)['roles']
    assert len(roles)==1
    role=next(iter(roles))
    r={'complete':False,'pins':[pin(p) for p in [__file__,HERE/'plan.md',HERE/'expr-fold.bend',HERE/'expr-affine.bend',
                                      HERE/'records.bend',reference,manifest]],'cases':[]}
    save=lambda:(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
    save()
    for ix,case in enumerate(CASES):
        ordinary=actual[case]
        c=ref[case]['products']['c']
        pin_src=ordinary['source']
        assert ref[case]['source']==pin_src and ordinary['point']==ref[case]['point']
        rec=read(BUILD/'phase198/native45-01'/case/'machine/report.json')
        original=ordinary['products'][role]
        assert rec['complete'] and rec['binary']==original['artifact']
        jobs={j['label']:j['command'] for j in rec['jobs']}
        binaries={'baseline':checked_tool(original['artifact']),'c':checked_tool(c['artifact'])}
        row={'case':case,'ordinarySource':pin_src,'producer':rec['request']['image'],'variants':{},'extra':[],
             'calibration':{},'samples':{},'medianMs':{},'ratios':{}}
        r['cases'].append(row)
        for k,text in alternatives(Path(checked_tool(pin_src)).read_text(), 'expression' in case).items():
            folder=out/case/k
            folder.mkdir(parents=True)
            source=folder/'main.bend';source.write_text(text)
            obj=folder/'program.o';exe=folder/'program'
            cmd=jobs['compiler'][:]
            assert cmd.count(pin_src['file'])==1
            cmd[cmd.index(pin_src['file'])]=str(source.resolve())
            with obj.open('wb') as f:
                proc=subprocess.run(cmd,stdout=f,stderr=subprocess.PIPE,timeout=40)
            row['variants'][k]={'source':pin(source),'compile':cmd,'stderr':proc.stderr.decode(errors='replace')[:3000],
                                'exit':proc.returncode}
            save()
            if proc.returncode:
                continue
            assert obj.read_bytes()[:4]==b'\x7fELF',obj.read_bytes()[:200]
            link=jobs['link'][:]
            link[link.index(original['generatedSource']['file'])]=str(obj.resolve())
            link[link.index(original['artifact']['file'])]=str(exe.resolve())
            subprocess.run(link,check=True,capture_output=True,timeout=15)
            row['variants'][k].update(product=pin(obj),binary=pin(exe),link=link)
            binaries[k]=str(exe)
        point=ordinary['point']; args=point['runtimeArgs']
        for inputs in ([0,0],[1,4294967295],[19,7],[57,12345]):
            expected=extra_output(c,inputs)
            obs={k:execute(exe,inputs,0,0,expected, c['runtimeArgumentConvention'] if k=='c' else original['runtimeArgumentConvention'])[0] for k,exe in binaries.items()}
            row['extra'].append({'args':inputs,'expected':expected,'observed':obs})
        for k,exe in binaries.items():
            count=max(1,min(128,point['repetitions']));row['calibration'][k]=[]
            for _ in range(15):
                convention=c['runtimeArgumentConvention'] if k=='c' else original['runtimeArgumentConvention']
                observed,_=execute(exe,args,count,3,point['expectedStdout'],convention)
                ms=observed['elapsedMs'];row['calibration'][k].append([count,ms])
                if 135<=ms<=450:break
                count=max(1,math.ceil(count*190/max(1,ms)))
            else:raise AssertionError('calibration '+case+'/'+k)
            row['samples'][k]=[]
        order=list(binaries)
        for i in range(len(order)):
            keys=order[(i+ix)%len(order):]+order[:(i+ix)%len(order)]
            for k in keys:
                count=row['calibration'][k][-1][0]
                convention=c['runtimeArgumentConvention'] if k=='c' else original['runtimeArgumentConvention']
                obs,_=execute(binaries[k],args,count,3,point['expectedStdout'],convention)
                assert obs['elapsedMs']>=100
                row['samples'][k].append({'count':count,**obs})
        for k,obs in row['samples'].items():
            row['medianMs'][k]=statistics.median(x['elapsedMs']/x['count'] for x in obs)
        row['ratios']={k:v/row['medianMs']['baseline'] for k,v in row['medianMs'].items()}
        save()
    r['complete']=all(all(z['exit']==0 for z in row['variants'].values()) for row in r['cases']);save()
    print([(c['case'],c['ratios']) for c in r['cases']])
    return r['complete']

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
    sys.exit(0 if main(p.parse_args().out) else 1)
