"""Prepare existing aligned builds and clean profiler runs; never execute them."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
PY=str(Path(sys.executable).resolve())


def pin(path):
    path=Path(path).resolve(); b=path.read_bytes()
    return dict(file=str(path),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())


def read(path): return json.loads(Path(path).read_text())


def save(path,value):
    with Path(path).open('x') as stream: stream.write(json.dumps(value,indent=2)+'\n')


def verify(item): assert pin(item['file'])==item, item['file']


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emission',type=Path)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--repetitions',type=int,default=1000000)
    p.add_argument('--seal',action='store_true')
    a=p.parse_args(); out=a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase131')
    if a.seal:
        plan=read(out/'jobs.json'); inputs=[pin(out/'jobs.json'),pin(__file__),*plan['inputs']]
        for item in inputs: verify(item)
        workloads=[]
        for name in ['compiler-tag','record-transfer']:
            variants=[]
            for role in ['baseline','candidate']:
                file=Path(plan['products'][role][name]); report=read(file)
                assert report['complete'] and report['outputExact']
                for item in report['inputs']+[report['binary']]:verify(item)
                inputs += [pin(file),report['binary']]
                variants.append(dict(name=role,binary=report['binary'],
                    command=[report['binary']['file'],'--threads','1','--gpu','off','--',str(plan['repetitions'])],
                    expected=dict(exitCode=0,stdout=dict(kind='prefix-integer-line',prefix=f'1\n{plan["repetitions"] % (1 << 32)}\n'),
                        stderr=dict(kind='exact',bytes=0,sha256=hashlib.sha256(b'').hexdigest()))))
            workloads.append(dict(name=name,timeoutSeconds=15,variants=variants))
        # The literal-path correctness case is mandatory even though untimed.
        control=read(plan['products']['candidate']['virtual-controls'])
        assert control['complete'] and control['outputExact']
        inputs.append(pin(plan['products']['candidate']['virtual-controls']))
        save(out/'timing-manifest.json',dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),
            inputs=inputs,workloads=workloads,scope='Same frozen two query sources, ordinary three-case oracles required. Matched clean sequential runtime/aligned builds; total child CPU/wall timings. One million repetitions selected before execution from prior100k baseline35ms calibration. No full-compiler speed claim.'))
        print(json.dumps(dict(sealed=True,targetsRun=False)))
        return
    assert a.emission and 1<=a.repetitions<=10000000 and not out.exists()
    e=read(a.emission);assert e['complete']
    cases=read(HERE/'cases-v02.json')['cases']
    inputs=[pin(__file__),pin(a.emission),pin(HERE/'cases-v02.json'),pin(HERE/'oracle.json'),
        pin(HERE/'virtual-controls.oracle.json'),*e['inputs'],e['runtime']]
    for item in inputs: verify(item)
    products={role:{} for role in ['baseline','candidate']}
    for name in ['compiler-tag','record-transfer']:
        file=ROOT/f'selfhost/build/phase111/p131-regions-jobs02-baseline-{name}-build/report.json'
        b=read(file);assert b['complete'] and b['outputExact'];verify(b['binary'])
        inputs += [pin(file),b['binary']];products['baseline'][name]=str(file)
    out.mkdir();jobs=[]
    def guard(name,command,seconds):
        jobs.append(dict(name=name,command=[PY,'-B',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),
            '--out',str(out/(name+'-guard')),'--seconds',str(seconds),'--rss-mib','2048',
            '--available-mib','16384','--file-mib','64','--cpu','3','--',*map(str,command)]))
    for name in ['compiler-tag','record-transfer','virtual-controls']:
        row=next(x for x in e['cases']if x['name']==name)
        case=next(x for x in cases if x['name']==name)
        assert row['verified'] and row['parentVerified'] and row['source']==case['source']
        verify(row['qbe']);inputs += [row['qbe'],case['source'],case['expected']]
        dest=ROOT/f'selfhost/build/phase111/p131-{out.name}-{name}-build'
        products['candidate'][name]=str(dest/'report.json')
        expected=HERE/('virtual-controls.expected.stdout' if name=='virtual-controls' else 'expected.stdout')
        inputs.append(pin(expected))
        guard(name+'-build',[PY,'-B',ROOT/'selfhost/tools/performance/phase123/build-aligned.py',
            '--source',row['qbe']['file'],'--runtime',e['runtime']['file'],'--out',dest,
            '--expected',expected,'--seconds','30'],75)
    jobs.append(dict(name='seal',command=[PY,'-B',str(Path(__file__).resolve()),'--out',str(out),'--seal']))
    guard('timing',[PY,'-B',ROOT/'selfhost/tools/profiler/run.py','--manifest',out/'timing-manifest.json',
        '--out',out/'timing','--modes','clean','--rounds','3'],190)
    save(out/'jobs.json',dict(complete=True,targetsRun=False,inputs=inputs,products=products,
        repetitions=a.repetitions,jobs=jobs,scope='Root-owned serial execution in order; stop on any failure. Baseline binaries are reused. Inspect actual hot machine work before broad timing or promotion.'))
    print(json.dumps(dict(prepared=True,targetsRun=False,jobs=str(out/'jobs.json'))))


if __name__=='__main__':main()
