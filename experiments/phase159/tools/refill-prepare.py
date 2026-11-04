#!/usr/bin/env python3
"""Prepare a single independently audited GC search-budget ablation."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
def pin(p):
 b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
src=ROOT/'selfhost/build/phase157/vendor/rt/bendrt.h';old=src.read_text();bound=pin(src)
assert bound['sha256']=='b99a4c3d186b233b5ebbc70fe6923f2de422827ee1a1a22eaddcc768d340167a'
needle='for (uintptr_t n = 0; b == NULL && n <= nw; n++) {'
replacement='for (uintptr_t n = 0; b == NULL && n <= nw && (shared || n < 64); n++) {'
assert old.count(needle)==1
out=ROOT/'selfhost/build/phase159/refill-prepare01';out.mkdir(exist_ok=False)
p=out/'bendrt.h';p.write_text(old.replace(needle,replacement))
assert p.read_text().replace(replacement,needle)==old
(out/'report.json').write_text(json.dumps(dict(complete=True,original=bound,candidate=pin(p),method=pin(Path(__file__)),needle=needle,replacement=replacement,scope='Only optional non-RC reuse search bounded. Unchanged allocation/GC fallback, generated computation and ownership checks. Requires independent output and resource gates.'),indent=2)+'\n')
