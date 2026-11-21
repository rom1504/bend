#!/usr/bin/env python3
"""One bounded source-kernel ceiling; invoked only by the shared lane owner."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import statistics
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.path.insert(0, str(ROOT/'research/phase196/screen'))
from measure import execute

def digest(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def pin(p): return dict(file=str(p),bytes=Path(p).stat().st_size,sha256=digest(p))
def checked(p):
    assert digest(p['file'])==p['sha256'],p
    return p['file']
def save(p,v): p.write_text(json.dumps(v,indent=2)+'\n')
def call(cmd):
    p=subprocess.run(list(map(str,cmd)),capture_output=True,text=True,timeout=4)
    assert p.returncode==0,(cmd,p.returncode,p.stdout,p.stderr)
    return p.stdout
def oracle(n,seed):
    a=[seed]*128;acc=0
    for i in range(n):
        acc=(acc+a[i&127])&0xffffffff;a[i&127]=acc^(i&0xffffffff)
    return acc

def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);args=p.parse_args()
    out=args.out;out.mkdir(parents=True,exist_ok=False)
    started=time.monotonic();freeze=json.loads((HERE/'frozen.json').read_text())
    result=dict(complete=False,freeze=pin(HERE/'frozen.json'),scope=freeze['scope'],observations=[],pilots=[],binding=[])
    save(out/'report.json',result)
    try:
        for v in freeze['inputs']: checked(v)
        tools=freeze['tools'];obj=out/'kernel.o';exe=out/'program'
        commands=[[checked(tools['clang']),*freeze['cFlags'],'-c',HERE/'kernel.c','-o',obj],
                  [checked(tools['linker']),'-no-pie',obj,'-o',exe]]
        for cmd in commands: call(cmd)
        result['commands']=[list(map(str,x)) for x in commands]
        result['object']=pin(obj);result['executable']=pin(exe)
        (out/'disassembly.txt').write_text(call(['/usr/bin/objdump','-d','-Mintel',exe]))
        controls=call([exe,'check']);(out/'checks.jsonl').write_text(controls)
        result['checks']=[json.loads(x) for x in controls.splitlines()]
        independent=0
        for row in result['checks']:
            if row['kind']!='vector': continue
            a=row['initial'].copy();acc=row['acc'];i=row['i']
            for _ in range(row['n']):
                acc=(acc+a[i%128])%2**32;a[i%128]=acc^i;i=(i+1)%2**32
            assert a==row['final'] and acc==row['result'];independent+=1
        result['independentFullStateChecks']=independent
        products={k:checked(v) for k,v in freeze['products'].items()}
        for n,seed in freeze['bindingPoints']:
            expected=str(oracle(n,seed))+'\n'
            for role,product in products.items():
                value,_=execute(product,[n,seed],0,0,expected)
                result['binding'].append(dict(role=role,n=n,seed=seed,**value))
        save(out/'report.json',result)
        def observe(role,reps):
            if role in ('scalar','simd4'):
                r=json.loads(call([exe,role,reps,4096,17]))
                assert r['reps']==r['success']==reps and r['result']==2339999928
                return dict(elapsedNs=r['ns'],perCallNs=r['ns']/reps,details=r)
            value,_=execute(products[role],[4096,17],reps,4,'2339999928\n')
            return dict(elapsedNs=value['elapsedMs']*1e6,perCallNs=value['elapsedMs']*1e6/reps,details=value)
        counts={}
        # About 100 ms per role/round; bounded calibration, no adaptive retry campaign.
        for role in freeze['roles']:
            pilot=observe(role,4096)
            result['pilots'].append(dict(role=role,repetitions=4096,**pilot))
            counts[role]=max(1,min(1000000,math.ceil(1e8/pilot['perCallNs'])))
        for round_ in range(6):
            roles=freeze['roles'];order=roles[round_%len(roles):]+roles[:round_%len(roles)]
            for role in order:
                obs=observe(role,counts[role])
                assert obs['elapsedNs']>=4e7,('sample too short',role,obs)
                result['observations'].append(dict(role=role,round=round_,repetitions=counts[role],**obs))
            save(out/'report.json',result)
        med={role:statistics.median(r['perCallNs'] for r in result['observations'] if r['role']==role) for role in freeze['roles']}
        result.update(complete=True,mediansNs=med,simdOverScalar=med['simd4']/med['scalar'],simdOverMatureC=med['simd4']/med['c'],simdOverCurrent=med['simd4']/med['current'])
    except Exception as e:
        result['error']=repr(e);raise
    finally:
        result['wallSeconds']=time.monotonic()-started;save(out/'report.json',result)

if __name__=='__main__': main()
