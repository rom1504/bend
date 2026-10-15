#!/usr/bin/env python3
"""Acquire and time original45 native batch products, with serial guarded jobs."""
import argparse, importlib.util, json, math, os, shutil, statistics, subprocess, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
P = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(P/'phase92/comparison'))
from support import authenticate, native_args, pin, read, verify, unchanged

def methods():
    return [pin(p) for p in [Path(__file__), P/'phase92/comparison/support.py',
            P/'phase86/guard.py', P/'programs/support.py', P/'phase46/execute.py']]

def save(path, value):
    path = Path(path)
    tmp = path.with_suffix(path.suffix+'.tmp')
    tmp.write_text(json.dumps(value, indent=2)+'\n')
    tmp.replace(path)

def guard(out, command, seconds=60):
    assert shutil.disk_usage(ROOT).free > 164*1024**2, 'Need 160 MiB reserve and per-job headroom'
    argv = [sys.executable,'-B',str(P/'phase86/guard.py'),'--out',str(out),
            '--seconds',str(seconds),'--cpu','3','--rss-mib','2048',
            '--available-mib','4096','--',*map(str,command)]
    result = subprocess.run(argv, cwd=ROOT, capture_output=True, text=True)
    proc = read(out/'process.json') if (out/'process.json').exists() else {}
    job = dict(guard=str(out), command=argv, process=proc, guardExit=result.returncode)
    assert result.returncode == 0 and proc.get('complete') and not proc.get('stoppedFor'), (job,result.stderr)
    return job

def collect_products(paths):
    cases = {}
    for path in paths:
        report = read(path)
        assert report['complete']
        for row in report['cases']:
            assert row['passed'] and row['sameNativeC'] and row['id'] not in cases
            for role in ['own','upstream']:
                verify(row['products'][role]['c']); verify(row['products'][role]['binary'])
            cases[row['id']] = row
    return cases

def acquire(args, out):
    context = authenticate(ROOT/'selfhost/build/phase92/upstream-b1/build.json')
    manifest = read(args.manifest)
    selected = [x for x in manifest['cases'] if not args.cases or x['id'] in args.cases.split(',')]
    assert selected
    if args.cases: assert {x['id'] for x in selected} == set(args.cases.split(','))
    survey_path = ROOT/'selfhost/build/phase83/survey01/plan.json'
    survey = read(survey_path)
    upstream_root = Path(survey['roles']['typescript']['bend']['file']).parent
    upstream = [verify(x) for x in survey['inputs'] if x.get('file','').startswith(str(upstream_root)+'/')]
    assert len(upstream) == 32
    assert {x['file'] for x in upstream} == {str(upstream_root/name) for name in ['bend.ts','comp.ts','base.bend']} | {str(x) for x in (upstream_root/'effs').glob('*.c')}
    bun = pin(ROOT/'selfhost/.bootstrap/bun-1.4.3/bun')
    worker = pin(P/'phase86/reference.mjs')
    report = dict(kind='phase93-native-runtime-acquisition', complete=False, method=pin(__file__), methodInputs=methods(),
                  manifest=pin(args.manifest), authentication=context, upstreamInputs=upstream,
                  survey=pin(survey_path), bun=bun, worker=worker, cases=[], started=time.time())
    save(out/'report.json',report)
    try:
        for case in selected:
            verify(case['source'])
            row = dict(case, passed=False, products={}, emissions={})
            report['cases'].append(row)
            directory = out/case['id']; directory.mkdir()
            for role in ['b1','b2','upstream']:
                prefix = directory/role
                cmd = (native_args(context,role,case['source']['file'],prefix) if role!='upstream'
                       else [bun['file'],worker['file'],'typescript',case['source']['file'],str(prefix),'1'])
                row['emissions'][role] = guard(directory/(role+'-emit'),cmd)
                row['emissions'][role]['c'] = pin(str(prefix)+'.1.c')
                if role=='upstream':
                    receipt = read(str(prefix)+'.json')
                    assert receipt['complete'] and receipt['calls'][0]['observation']==dict(status='ok',checked=True)
                    row['emissions'][role]['receipt'] = pin(str(prefix)+'.json')
            b1,b2 = [row['emissions'][r]['c'] for r in ['b1','b2']]
            assert Path(b1['file']).read_bytes()==Path(b2['file']).read_bytes()
            row['sameNativeC'] = True
            # B1's duplicate has exact retained B2 bytes; keep an explicit restoration map.
            row['deduplicated'] = dict(original=b1, retained=b2, reason='Full bytes equal; reconstruct by copy.')
            Path(b1['file']).unlink()
            for role,key in [('own','b2'),('upstream','upstream')]:
                c = row['emissions'][key]['c']; binary = directory/(role+'.program')
                clang = context['clang']['file']
                cmd = [clang,'-isystem',str(Path(clang).parents[1]/'include/clang'),
                       '-std=c11','-O3',c['file'],'-o',str(binary),'-lpthread','-lm']
                job = guard(directory/(role+'-build'),cmd)
                row['products'][role] = dict(c=c,binary=pin(binary),build=job)
            row['passed']=True; save(out/'report.json',report)
            print(json.dumps(dict(acquired=case['id'],sameNativeC=True)),flush=True)
        unchanged(context)
        for x in upstream: verify(x)
        for x in report['methodInputs']: verify(x)
        for x in selected: verify(x['source'])
        assert pin(args.manifest)==report['manifest'] and pin(__file__)==report['method']
        report.update(complete=True,inputsUnchanged=True)
    except BaseException as exc:
        report['error']=repr(exc); raise
    finally:
        report['finished']=time.time(); save(out/'report.json',report)

def sample(out, case, role, repetitions, warmups):
    product=case['products'][role]; verify(product['binary'])
    values=list(case['point']['args'])+[0,0]
    command=[sys.executable,'-B',str(P/'phase46/execute.py'),str(out/'child.json'),
             product['binary']['file'],'--threads','1','--gpu','off','--',
             str(repetitions),str(warmups),str(values[0]),str(values[1])]
    job=guard(out,command,40)
    child=read(out/'child.json')
    expected=str(case['expected'])+'\n'+str(warmups)+'\n'+str(repetitions)+'\n'
    stdout=child['stdout']
    assert child['returncode']==0 and not child['stderr'] and stdout.startswith(expected), (case['id'],role,child,expected)
    suffix=stdout[len(expected):]
    assert suffix.endswith('\n') and suffix[:-1].isdecimal(), child
    ms=int(suffix[:-1]); assert 0<=ms<=child['processSeconds']*1000+2
    return dict(case=case['id'],role=role,repetitions=repetitions,warmups=warmups,
                elapsedMs=ms,processSeconds=child['processSeconds'],correct=True,
                qualified=ms>=100,job=job,child=pin(out/'child.json'))

def timing(args,out):
    cases=collect_products(args.acquired)
    if args.cases: cases={k:cases[k] for k in args.cases.split(',')}
    assert cases
    report=dict(kind='phase93-native-runtime-'+args.action,complete=False,method=pin(__file__),methodInputs=methods(),
                acquired=[pin(p) for p in args.acquired],records=[],started=time.time(),plan={})
    save(out/'report.json',report)
    try:
        if args.action=='calibrate':
            for name,case in cases.items():
                n=8
                for attempt in range(9):
                    trials=[]
                    for role in ['own','upstream']:
                        r=sample(out/f'{name}-{attempt}-{role}',case,role,n,min(16,max(1,n//8)))
                        report['records'].append(r);trials.append(r);save(out/'report.json',report)
                    fast=min(r['elapsedMs'] for r in trials)
                    if fast>=50:
                        repetitions=max(n,math.ceil(n*args.target_ms/fast))
                        assert repetitions<=200_000_000
                        report['plan'][name]=dict(repetitions=repetitions,warmups=min(32,max(1,repetitions//8)),calibration=n)
                        print(json.dumps(dict(calibrated=name,ms=[x['elapsedMs'] for x in trials],n=repetitions)),flush=True)
                        break
                    n=min(200_000_000,n*min(32,max(2,math.ceil(75/max(1,fast)))))
                else: raise AssertionError('Calibration did not reach 50 ms: '+name)
        else:
            plans={}
            for file in args.plans:
                plan=read(file);assert plan['complete'] and not plans.keys()&plan['plan'].keys()
                plans.update(plan['plan'])
            report['planInputs']=[pin(p) for p in args.plans]
            report['plan']={k:plans[k] for k in cases}
            for ix,(name,case) in enumerate(cases.items()):
                p=plans[name]; n=p['repetitions']; warm=p['warmups']
                for rnd in range(args.rounds):
                    roles=['own','upstream'] if (ix+rnd)%2==0 else ['upstream','own']
                    for role in roles:
                        r=sample(out/f'{name}-{rnd}-{role}',case,role,n,warm)
                        r['round']=rnd+1;report['records'].append(r);save(out/'report.json',report)
                        assert r['qualified'], ('Below 100 ms; preserve attempt and recalibrate',r)
                med={role:statistics.median(r['elapsedMs'] for r in report['records'] if r['case']==name and r['role']==role) for role in ['own','upstream']}
                print(json.dumps(dict(measured=name,mediansMs=med,ratio=med['own']/med['upstream'])),flush=True)
        for p in report['acquired']:verify(p)
        for p in report['methodInputs']:verify(p)
        assert pin(__file__)==report['method']
        report['complete']=True
    except BaseException as exc:
        report['error']=repr(exc);raise
    finally:
        report['finished']=time.time();save(out/'report.json',report)

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('action',choices=['acquire','calibrate','measure'])
    p.add_argument('--out',type=Path,required=True);p.add_argument('--cases')
    p.add_argument('--manifest',type=Path);p.add_argument('--acquired',type=Path,nargs='+')
    p.add_argument('--plans',type=Path,nargs='+');p.add_argument('--rounds',type=int,default=3)
    p.add_argument('--target-ms',type=int,default=250)
    args=p.parse_args();out=args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase93') and not out.exists()
    out.mkdir(parents=True)
    if args.action=='acquire':acquire(args,out)
    else:timing(args,out)

if __name__=='__main__':main()
