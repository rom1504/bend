"""Append a bounded Bend experiment; no parent declaration may change."""
import argparse,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(r):assert pin(r['file'])==r,r['file']
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase115')
selection=ROOT/'implementation/phase114/selection.json';s=json.loads(selection.read_text())['nativeQualified']
for k in ['source','api','runtime','admission']:verify(s[k])
source=Path(s['source']['file']).read_text();module=HERE/'plans.bend';new=module.read_text()
old_names=set(re.findall(r'^(?:def|type|law) (\S+)',source,re.M));new_names=re.findall(r'^(?:def|type|law) (\S+)',new,re.M)
assert len(set(new_names))==len(new_names) and not set(new_names)&old_names
assert all(n.startswith(('p115_','P115')) for n in new_names)
out.mkdir(parents=True);(out/'plans.bend').write_bytes(module.read_bytes());(out/'compiler.bend').write_text(source+'\n'+new)
inputs=[pin(selection),s['source'],s['api'],s['runtime'],s['admission'],pin(module),pin(__file__)]
m=dict(complete=True,checked=False,source=pin(out/'compiler.bend'),base=s['source'],inputs=inputs,added=new_names,overrides=[],scope='Exact parent bytes followed by new Bend declarations; source composition only.')
(out/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(json.dumps(m['source']))
