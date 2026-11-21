"""Source-level ceilings for split/join fusion and pushing it through a repetition."""
import argparse
import json
import os
from pathlib import Path
import statistics
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sys.path.insert(0, str(ROOT / 'research/phase199/scan-transfer'))
from baseline import authenticate, command, pin, read, write
sys.path.insert(0, str(ROOT / 'research/phase200/tree'))
from importlib.util import spec_from_file_location, module_from_spec
spec = spec_from_file_location('p200_tree_screen', ROOT/'research/phase200/tree/screen.py')
shared = module_from_spec(spec)
spec.loader.exec_module(shared)
execute = shared.execute

def transform(source, distributed):
    banner = '# Phase93: fixed catalog inputs, repeated complete-result validation.'
    prefix, driver = source.split(banner)
    original = '  text = p37.text.repeat(U32.to_nat(size), String.append("α,β,🍎,中,", String.append(U32.show(seed), ",")))\n  sjoin("|", ssplit(44, text))'
    block = 'String.append("α,β,🍎,中,", String.append(U32.show(seed), ","))'
    body = ('  p37.text.repeat(U32.to_nat(size), p200.text.replace("|", 44, '+block+'))' if distributed else
            '  text = p37.text.repeat(U32.to_nat(size), '+block+')\n  p200.text.replace("|", 44, text)')
    assert prefix.count(original) == 1 and prefix.count('import Base\n') == 1
    return prefix.replace(original, body).replace('import Base\n', 'import Base\n\n'+(HERE/'replace.bend').read_text()+'\n') + banner + driver

def main(out):
    assert os.sched_getaffinity(0) == {3}
    out.mkdir(parents=True, exist_ok=False)
    base = ROOT / 'selfhost/build/phase198'
    catalog = read(base/'p199-integrated-live-plan02/manifest.json')
    runtime = authenticate(read(ROOT/'selfhost/build/phase199/runtime-bundle01/report.json')['variants']['live']['bundle'])
    report = {'complete': False, 'method': pin(__file__), 'kernel': pin(HERE/'replace.bend'), 'cases': {}}
    save = lambda: write(out/'report.json', report)
    for name in ('coverage-unicode-text-16', 'coverage-unicode-text-64'):
        row = next(c for c in catalog['cases'] if c['id'] == name)
        stock = authenticate(row['source'])
        req = read(base/'p199-integrated-native45-01'/name/'machine/report.json')
        for item in req['inputs']: authenticate(item)
        products = {k: authenticate(row['products'][role]['artifact']) for k,role in [('c','c'),('stock','candidate')]}
        result = {'input':pin(stock),'products':{}, 'checks':[], 'samples':[]}
        report['cases'][name]=result
        save()
        for label in ('stream','distributed'):
            d=out/name/label
            d.mkdir(parents=True)
            s=d/'input.bend'
            s.write_text(transform(Path(stock).read_text(),label=='distributed'))
            command(d,'check',['selfhost/.assets/bin/bun','selfhost/tools/build/check-source.mjs','--source',s,'--out',d/'check','--manifest','selfhost/src/compiler.json','--upstream','selfhost/.bootstrap/upstream-phase182'])
            assert read(d/'check/report.json')['unresolvedHoles']==0
            argv=req['compilerCommand'].copy()
            assert argv[8]=='x86-object'
            argv[9]=str(s)
            obj=d/'program.o';command(d,'emit',argv,obj)
            assert obj.read_bytes().startswith(b'\x7fELF')
            link=next(j for j in req['jobs'] if j['label']=='link')['command'].copy()
            for previous,new in [(req['object']['file'],obj),(req['binary']['file'],d/'program'),(req['runtime']['file'],runtime)]:
                assert link.count(previous)==1
                link[link.index(previous)]=str(new)
            command(d,'link',link)
            products[label]=d/'program'
            result['products'][label]={'source':pin(s),'object':pin(obj),'exe':pin(products[label]),'check':pin(d/'check/report.json')}
        size,seed=map(int,row['point']['runtimeArgs'])
        pts=[(size,seed),(0,0),(1,0),(3,0xffffffff),(17,65535)]
        for i,(n,x) in enumerate(pts):
            q={'inputs':[n,x], 'digest':('α|β|🍎|中|'+str(x)+'|')*n}
            result['checks'].append({k:execute(b,q,int(i==0),0)['stdout'] for k,b in products.items()})
        q={'inputs':[size,seed],'digest':('α|β|🍎|中|'+str(seed)+'|')*size}
        counts={}
        for label,b in products.items():
            count=4096
            for _ in range(8):
                elapsed=execute(b,q,count,2)['elapsedMs']
                if 110<=elapsed<=240:break
                count=max(1,round(count*160/max(1,elapsed)))
            else: raise ValueError('calibration: '+label)
            counts[label]=count
        labels=list(products)
        for n in range(len(labels)):
            sample={}
            for label in labels[n:]+labels[:n]:
                sample[label]=execute(products[label],q,counts[label],3)
                assert sample[label]['elapsedMs']>=100
            result['samples'].append(sample);save()
        result['ratios']={label:{ref:statistics.median(s[label]['nsPerInvocation']/s[ref]['nsPerInvocation'] for s in result['samples']) for ref in ('stock','c')} for label in ('stream','distributed')}
    report['complete']=True;save()
    print({k:r['ratios'] for k,r in report['cases'].items()})

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);main(p.parse_args().out.resolve())
