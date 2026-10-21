"""Bind unchanged authenticated QBE to an independently built cached runtime."""
import argparse,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--emission',required=True);p.add_argument('--runtime',required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--names',nargs='*');a=p.parse_args();e=json.loads(Path(a.emission).read_text());r=json.loads(Path(a.runtime).read_text());assert e['complete'] and r['complete'];assert pin(r['object']['file'])==r['object'];names=a.names or [x['name'] for x in e['cases']];cases=[x for x in e['cases'] if x['name'] in names];assert len(cases)==len(names)
for c in cases:assert pin(c['qbe']['file'])==c['qbe']
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase118');out.mkdir();e.update(runtime=r['object'],cases=cases,runtimeOnlyRebinding=True,parentEmission=pin(a.emission),inputs=[*e['inputs'],pin(__file__),pin(a.emission),pin(a.runtime),r['source'],r['object'],*r['inputs']]);(out/'report.json').write_text(json.dumps(e,indent=2)+'\n')
