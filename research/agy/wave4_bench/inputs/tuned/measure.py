"""Run inputs on a single timing lane. Report raw batches and per-call medians."""
import argparse
import hashlib
import json
import math
from pathlib import Path
from statistics import median
import subprocess
from oracle import value, word
from functools import lru_cache
from contract import load

HERE=Path(__file__).resolve().parent
SPEC=load()
CAT_PATH=HERE.parent/'catalogs/native45/catalog.json'
if hashlib.sha256(CAT_PATH.read_bytes()).hexdigest()!=SPEC['native45_catalog_sha256']:
    raise ValueError('native45 catalog differs from v1 pin')
CAT=json.loads(CAT_PATH.read_text())
FROZEN={r['id']:r['point'] for r in CAT['cases']}

def products_from(directories):
    products={}
    for directory in directories:
        for key,item in json.loads((directory/'products.json').read_text()).items():
            if key in products: raise ValueError('duplicate product '+key)
            if hashlib.sha256(Path(item['argv'][0]).read_bytes()).hexdigest()!=item['sha256']:
                raise ValueError('changed executable '+key)
            products[key]=item
    return products

@lru_cache(maxsize=256)
def seed_bank(family,n,seed):
    return [value(family,n,word(seed+i*2654435761)) for i in range(32)]

def batch_hash(values,count):
    # Hashing a block is an affine map modulo 2^32. Exponentiate that
    # map to validate millions of calls without rerunning the fast kernel.
    mult=16777619
    block=0
    for v in values:
        block=word(mult*block+v)
    factor=pow(mult,32,1<<32)
    repeats,tail=divmod(count,32)
    h=0
    while repeats:
        if repeats&1: h=word(factor*h+block)
        block=word(factor*block+block)
        factor=word(factor*factor)
        repeats>>=1
    for v in values[:tail]:
        h=word(mult*h+v)
    return h

def execute(product,n,seed,values,reps,warm):
    cmd=product['argv']
    args=[reps,warm,n,seed]
    result=subprocess.run([*cmd,*map(str,args)],capture_output=True,text=True,timeout=25,check=True)
    lines=result.stdout.splitlines()
    if result.stderr or len(lines)!=4 or lines[:3]!=[str(values[0]),str(batch_hash(values,warm)),str(batch_hash(values,reps))]:
        raise ValueError((cmd[0],n,seed,reps,lines,result.stderr[:250]))
    ms=int(lines[3])
    if ms<0: raise ValueError('timer moved backwards')
    return ms

def calibrate(call,base):
    reps=32*max(1,base//(24*32))
    for _ in range(12):
        ms=call(reps)
        if ms>=72: return reps
        if reps==100_000_000: raise ValueError('timer floor at calibration limit')
        reps=min(100_000_000,reps*min(16,max(2,math.ceil(96/max(ms,1)))))
    raise ValueError('failed to calibrate')

def run(out,products,families):
    out.mkdir(exist_ok=True,parents=True)
    result={'suite':'native-tuned-v1','native45_catalog_sha256':SPEC['native45_catalog_sha256'],
            'products':{k:v['sha256'] for k,v in products.items()},'checks':[],'rows':[]}
    all_entries={}
    for family in families:
        config=SPEC['families'][family]
        entries={}
        for form in config['forms']:
            shared_source=None
            for role in SPEC['roles']:
                key=f'{family}-{form}-{role}'
                product=products[key]
                if role!='hand-c':
                    source=product['inputs']['source']
                    if shared_source and source!=shared_source:
                        raise ValueError('different Bend source across targets for '+key)
                    shared_source=source
                entries[key]=dict(product,role=role)
        for n,seed in config['controls']:
            values=seed_bank(family,n,seed)
            answer=values[0]
            for product in entries.values():
                execute(product,n,seed,values,35,3)
            result['checks'].append(dict(family=family,n=n,seed=seed,expected=answer,products=len(entries)))
        all_entries[family]=entries
    (out/'controls.json').write_text(json.dumps(result['checks'],indent=2)+'\n')
    for family in families:
        config=SPEC['families'][family]
        entries=all_entries[family]
        for identifier in config['points']:
            p=FROZEN.get(identifier) or SPEC['extension_points'][identifier]
            n,seed=p['runtimeArgs']
            values=seed_bank(family,n,seed)
            answer=values[0]
            if identifier in FROZEN and str(answer)+'\n'!=p['expectedStdout']:
                raise ValueError('native45 oracle disagrees for '+identifier)
            def call(key,reps):
                return execute(entries[key],n,seed,values,reps,32)
            reps={}
            for key in entries:
                try:
                    reps[key]=calibrate(lambda count:call(key,count),p['repetitions'])
                except ValueError as error:
                    raise ValueError(f'{identifier} {key}: {error}') from error
            # Balanced Latin square. Every product occupies every position once.
            keys=list(entries)
            count=len(keys)
            offsets=[0]+[i//2+1 if i%2==0 else count-(i+1)//2 for i in range(count-1)]
            samples={k:[] for k in keys}
            for r in range(count):
                for offset in offsets:
                    key=keys[(r+offset)%count]
                    samples[key].append(call(key,reps[key]))
            if any(min(times)<=0 for times in samples.values()):
                raise ValueError('timer resolution insufficient for '+identifier)
            us={k:1000*median(v)/reps[k] for k,v in samples.items()}
            row=dict(id=identifier,family=family,input=[n,seed],expected=answer,
                     seed_bank=values,warmups=32,fixed_reps=p['repetitions'],calibrated_reps=reps,
                     samples_ms=samples,median_us=us)
            result['rows'].append(row)
            (out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
            print(identifier,{k:round(v,4) for k,v in us.items()},flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('out',type=Path)
    p.add_argument('builds',nargs='+',type=Path)
    p.add_argument('--families', choices=SPEC['families'], nargs='+', default=list(SPEC['families']))
    args=p.parse_args()
    run(args.out,products_from(args.builds),args.families)
