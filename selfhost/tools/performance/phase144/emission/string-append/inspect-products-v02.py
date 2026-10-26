"""Read checked small QBE products; verify concat placement and ABI capability."""
import argparse, hashlib, json, re
from pathlib import Path

def pin(p):
    p=Path(p).resolve();b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

def decode(s):
    return re.sub(r'FID_((?:\d+_)+)',lambda m:''.join(chr(int(n)) for n in m[1].strip('_').split('_')),s)

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--baseline',type=Path,required=True)
p.add_argument('--candidate',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();assert not a.out.exists()
reports=[json.loads(f.read_text()) for f in (a.baseline,a.candidate)]
assert all(r['complete'] for r in reports)
assert [x['name'] for x in reports[0]['cases']]==[x['name'] for x in reports[1]['cases']]
result=dict(kind='phase144-append-actual-product-inspection-v2',complete=False,inputs=[pin(__file__),pin(a.baseline),pin(a.candidate)],rows=[])
for role,r in zip(('baseline','candidate'),reports):
    for c in r['cases']:
        assert pin(c['qbe']['file'])==c['qbe'];result['inputs'].append(c['qbe'])
        descriptor=None;wrapper=None;current=None;lines=[]
        for line in Path(c['qbe']['file']).open():
            if line.startswith('export data $p111_program ='):
                descriptor=line.strip()
            if line.startswith(('function ','export function ')):
                current=decode(line).split('$',1)[-1].split('(',1)[0]
                lines=[]
            if current=='p113d_$direct.String.append':
                lines.append(line)
                if line.strip()=='}':wrapper=''.join(lines);current=None
        assert descriptor and wrapper,'Missing descriptor/direct String.append'
        words=descriptor.split('{',1)[1].rsplit('}',1)[0].split(',')
        assert len(words)==24 and words[0].strip()=='l 11101' and words[1].strip()=='l 192'
        cap=int(words[11].strip().removeprefix('l '));assert cap&1,'Sequential capability missing'
        if role=='candidate':
            old=next(x for x in result['rows'] if x['role']=='baseline' and x['name']==c['name'])
            assert cap&4,'Candidate lost live-register transport'
            assert (cap & ~4)==(old['capabilities'] & ~4),'Other capability bits changed'
        calls=[decode(x.strip()) for x in wrapper.splitlines() if ' call ' in x]
        concat=sum('call $p125_rt_concat_typed(' in x for x in calls)
        fallback=sum('$p113d_$p118.trmc.$direct.String.append(' in x for x in calls)
        assert concat==(1 if role=='candidate' else 0),('Unexpected concat placement',role,c['name'],calls)
        assert fallback>=1,'Original complete worker must remain available'
        result['rows'].append(dict(role=role,name=c['name'],capabilities=cap,liveRegisterBank=bool(cap&4),concatCalls=concat,fallbackCalls=fallback,calls=calls,qbe=c['qbe']))
result['scope']='Candidate must retain live-register transport; baseline List fixture already lacked bit4. Other capability bits remain exact. List performance combines transport recovery and append admission; String preserves its baseline capability mask.'
result['complete']=True;a.out.parent.mkdir(parents=True,exist_ok=True)
a.out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(complete=True,rows=result['rows'])))
