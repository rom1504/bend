#!/usr/bin/env python3
"""Serial rotated native/JS-hosted reference comparisons with exact C oracles."""
import argparse, json, re
from pathlib import Path
from broad import ROOT, P, NODE, pin, save, guard
from native_support import authenticate, native_args, DEFAULT_CACHE

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('out',type=Path);p.add_argument('--calls',type=int,choices=(1,5),default=1)
p.add_argument('--rounds',type=int,default=2)
p.add_argument('--roles',default='native01,native02,cached02,typescript,b2')
p.add_argument('--cases',default='small,numeric_closed,lexer_original,map_closed,functions65,unicode')
a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
baseline=json.loads((ROOT/'selfhost/build/phase88/screen01/report.json').read_text())
roles=a.roles.split(',');names=a.cases.split(',');auth={}
for role in roles:
    if role.startswith('native') or role=='cached02':
        image=ROOT/('selfhost/build/phase88/compiler-native01' if role=='native01' else 'selfhost/build/phase88/compiler-native02')
        auth[role]=authenticate(image,DEFAULT_CACHE if role=='cached02' else None)
rows=[];report=dict(complete=False,passed=False,calls=a.calls,rounds=a.rounds,roles=roles,cases=names,
                   method=pin(__file__),support=pin(P/'phase88/native_support.py'),authentication=auth,rows=rows)
save(out/'plan.json',report)
for rnd in range(a.rounds):
    for ix,name in enumerate(names):
        source=Path(baseline['cases'][name])
        order=roles[ix%len(roles):]+roles[:ix%len(roles)]
        if rnd%2:order=list(reversed(order))
        for role in order:
            prefix=out/f'{rnd+1}-{name}-{role}'
            cmd=native_args(auth[role],source,prefix,a.calls) if role in auth else [NODE,'--max-old-space-size=1024','--stack-size=4096',str(P/'phase86/reference.mjs'),role,str(source),str(prefix),str(a.calls)]
            job=guard(Path(str(prefix)+'-guard'),cmd,60)
            logs='\n'.join((Path(job['guard'])/n).read_text() for n in ['stdout.log','stderr.log'])
            outputs=[pin(Path(str(prefix)+f'.{i}.c')) for i in range(1,a.calls+1) if Path(str(prefix)+f'.{i}.c').exists()]
            oracleRole='typescript' if role=='typescript' else 'b2'
            oracle=next(r['outputs'][0]['sha256'] for r in baseline['rows'] if r['case']==name and r['role']==oracleRole)
            exact=len(outputs)==a.calls and all(o['sha256']==oracle for o in outputs)
            metrics=dict(re.findall(r'(base_prepare_ms|runtime_prepare_ms)=(\d+)',logs))
            requests=list(map(int,re.findall(r'request=\d+ request_ms=(\d+)',logs)))
            reference=Path(str(prefix)+'.json')
            if reference.exists():requests=[v['requestMs'] for v in json.loads(reference.read_text())['calls']]
            process=json.loads((Path(job['guard'])/'process.json').read_text())
            row=dict(round=rnd+1,case=name,role=role,job=job,outputs=outputs,exact=exact,metrics=metrics,
                     requestMs=requests,processWallSeconds=process['wallSeconds'],peakRssBytes=process.get('peakTreeRssBytes'))
            rows.append(row);save(out/'report.json',report)
            print(json.dumps({k:row[k] for k in ['round','case','role','exact','metrics','requestMs','processWallSeconds']}),flush=True)
            if not job['pass_'] or not exact:raise SystemExit('failed job or output; preserved report')
for role,identity in auth.items():
    assert authenticate(identity['image']['file'],DEFAULT_CACHE if role=='cached02' else None)==identity
report.update(complete=True,passed=True);save(out/'report.json',report)
