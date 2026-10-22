"""Explicit additive-runtime ablation; exact checked QBE remains unchanged."""
import argparse,hashlib,json
from pathlib import Path
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--emission',type=Path,required=True);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
e=json.loads(a.emission.read_text());r=json.loads(a.runtime.read_text());assert e['complete'] and r['complete'] and not a.out.exists()
assert r['kind']=='phase125-additive-runtime'
for x in e['inputs']+r['inputs']+[r['source'],r['object']]:assert pin(x['file'])==x
for x in e['cases']:assert pin(x['qbe']['file'])==x['qbe']
e['runtimeAblation']=dict(parentEmission=pin(a.emission),parentRuntime=e['runtime'],runtimeReport=pin(a.runtime),scope='Exact checked QBE; same additive p125_rt_concat ABI, different independently audited uniqueness acceptance.')
e['runtime']=r['object'];e['inputs'] += [pin(a.emission),pin(a.runtime),pin(__file__),r['source'],r['object'],*r['inputs']]
a.out.write_text(json.dumps(e,indent=2)+'\n')
