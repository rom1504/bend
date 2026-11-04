#!/usr/bin/env python3
"""Reproduce the audited whitespace-only compatibility source; no targets."""
import hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
source=ROOT/'selfhost/tests/phase157/workload.bend'
raw=source.read_bytes()
assert hashlib.sha256(raw).hexdigest()=='d0dbf871ef6f4b7d966a58293bedb9e1355038f01ebe1f7e81c69e93f1d9081e'
text=raw.decode();matches=list(re.finditer(r'=>\n[ \t]+',text));assert len(matches)==368
normalized=re.sub(r'=>\n[ \t]+','=> ',text).encode()
assert hashlib.sha256(normalized).hexdigest()=='a926e00c75df0bc2b5c49eaccdb8cd98eb21a4b461592891338e4178fe65cca1'
assert normalized==(ROOT/'selfhost/tests/phase157/workload-compatible.bend').read_bytes()
print(json.dumps(dict(complete=True,targetsRun=False,sourceSha256=hashlib.sha256(raw).hexdigest(),normalizedSha256=hashlib.sha256(normalized).hexdigest(),count=len(matches),offsets=[x.start()for x in matches],gate='Upstream checked emission produces identical C; QBE produces identical IR/assembly/object. No AST-equivalence theorem claimed.')))
