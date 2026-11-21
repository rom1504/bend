"""Retain actual and rejected job receipts plus complete checks and paired timings."""
import gzip
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
BUILD=ROOT/'selfhost/build/phase199'
CLOSE=ROOT/'selfhost/build-retention/phase199'
evidence={}
for guard in sorted(BUILD.glob('p200-spill-*-guard')):
    name=guard.name.removesuffix('-guard')
    closure=CLOSE/(name+'-close')
    assert closure.is_dir()
    files=[guard/'process.json',guard/'retention.json',*closure.glob('*.json'),BUILD/name/'report.json',guard/'stderr.log']
    entries={}
    for f in files:
        if f.is_file() and f.stat().st_size:
            entries[str(f.relative_to(ROOT))]=dict(sha256=hashlib.sha256(f.read_bytes()).hexdigest(),
                  data=json.loads(f.read_text()) if f.suffix=='.json' else f.read_text()[-4000:])
    evidence[name]=entries
(HERE/'receipts.json.gz').write_bytes(gzip.compress(json.dumps(evidence,indent=2).encode(),mtime=0))
