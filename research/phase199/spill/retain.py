"""Archive each checked attempt, native product receipt, and guarded qualification result."""
from pathlib import Path
import gzip
import hashlib
import json

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=ROOT/'selfhost/build/phase199'
CLOSE=ROOT/'selfhost/build-retention/phase199'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
bundle={}
for run in sorted(BUILD.glob('spill-*-guard')):
    name=run.name.removesuffix('-guard')
    close=CLOSE/(name+'-close')
    if not close.is_dir():continue
    out=BUILD/name
    files=[run/'process.json',run/'retention.json',*close.glob('*.json'),out/'report.json',run/'stderr.log']
    if (out/'stderr').exists():files.append(out/'stderr')
    entries={}
    for f in files:
        if f.is_file() and f.stat().st_size:
            entries[str(f.relative_to(ROOT))]=dict(sha256=digest(f),data=json.loads(f.read_text()) if f.suffix=='.json' else f.read_text()[-5000:])
    bundle[name]=entries
(HERE/'observations.json.gz').write_bytes(gzip.compress(json.dumps(bundle,indent=2).encode(),mtime=0))
print([(name,round(next(v['data']['wallSeconds'] for k,v in entries.items() if k.endswith('guard/process.json')),2)) for name,entries in bundle.items()])
