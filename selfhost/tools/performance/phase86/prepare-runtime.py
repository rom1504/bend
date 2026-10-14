#!/usr/bin/env python3
"""Transport already Bend-produced canonical chunks; no marker parsing here."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
template=ROOT/'selfhost/src/runtime/native/runtime-template.json';raw=ROOT/'selfhost/src/runtime/native/runtime.c'
def sha(b):return hashlib.sha256(b).hexdigest()
assert sha(template.read_bytes())=='f9f5a1c98f17f892d891032ca35489234e43d3b4112a18e592e6da408b09736c'
t=json.loads(template.read_text());assert sha(raw.read_bytes())==t['runtimeSha256'] and len(t['parts'])==5
assert ''.join(t['parts']).encode()==raw.read_bytes()
out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=False)
prefix=out/'runtime.c';prefix.write_bytes(raw.read_bytes())
records=[]
for i,part in enumerate(t['parts']):
    f=Path(str(prefix)+f'.part{i}');f.write_text(part);records.append(dict(path=str(f),sha256=sha(f.read_bytes()),bytes=f.stat().st_size))
(out/'receipt.json').write_text(json.dumps(dict(producer='existing Bend ne_runtime_prepare artifact',template=str(template),templateSha256=sha(template.read_bytes()),runtimeSha256=sha(raw.read_bytes()),parts=records),indent=2)+'\n')
print(prefix)
