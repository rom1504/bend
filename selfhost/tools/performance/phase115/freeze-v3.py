import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
p=HERE/'manifest02.json';x=json.loads(p.read_text());a=ROOT/'selfhost/build/phase111/p115-api04/report.json';checked=json.loads(a.read_text());assert checked['complete'] and checked['checked']
x.update(api=checked['api'],apiReport=pin(a),derivation=dict(parent=pin(p),reason='Remove extra legacy policy0 lookup; retain policies/cases/oracles and require every output to match prior measured products.'))
x['inputs'] += [pin(p),pin(__file__),pin(ROOT/'selfhost/build/phase115/source04/manifest.json')]
out=HERE/'manifest03.json';assert not out.exists();out.write_text(json.dumps(x,indent=2)+'\n')
