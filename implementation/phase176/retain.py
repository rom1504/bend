#!/usr/bin/env python3
"""Retain compact exact experiment evidence; never run targets or prune originals."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
BUILD=ROOT/'selfhost/build/phase176'
OUT=Path(__file__).resolve().parent
if (OUT/'evidence.tar.gz').exists():
    raise SystemExit('Evidence is sealed. Restore the verified archive for inspection; do not recapture over this report.')
(OUT/'evidence').mkdir(exist_ok=True)
rows=[]
for path in sorted(BUILD.rglob('*')):
    if not path.is_file():continue
    rel=path.relative_to(BUILD)
    keep=(path.suffix in ['.json','.jsonl','.stdout','.stderr','.log'] or path.name in ['stdout','stderr'])
    # Exact small input snapshots preserve failed syntax and both architecture
    # experiments. Larger parser closures remain reproducible generated sources.
    keep=keep or (path.name=='compiler.bend' and path.stat().st_size<=20000)
    if not keep:continue
    raw=path.read_bytes()
    if len(raw)>4*1024**2:continue
    retained=raw
    exact=True
    if path.name=='manifest.json':
        value=json.loads(raw)
        if value.get('kind')=='phase176-api-source' and len(value.get('originalSourceMap',[]))>1500:
            kept={(r['kind'],r['name']) for r in value['declarations']}
            count=len(value['originalSourceMap'])
            value['originalSourceMap']=[r for r in value['originalSourceMap']if (r['kind'],r['name'])in kept]
            value['sourceMapRetention']=dict(originalEntries=count,scope='Derived provenance summary: only retained declaration positions. Original manifest remains in build storage; reconstruct full map from pinned maintained source.')
            retained=(json.dumps(value,indent=2)+'\n').encode()
            exact=False
    # Preserve the filename convention used by the first capture, even when
    # provenance compaction now makes a formerly large manifest small.
    packed=len(raw)>100000
    destination=OUT/'evidence'/rel
    if packed:destination=destination.with_name(destination.name+'.gz')
    destination.parent.mkdir(parents=True,exist_ok=True)
    data=gzip.compress(retained,mtime=0)if packed else retained
    if destination.exists():
        prior=destination.read_bytes();decoded=gzip.decompress(prior)if packed else prior
        assert decoded in (raw,retained),str(destination)
        if decoded!=retained:destination.write_bytes(data)
    else:destination.write_bytes(data)
    assert (gzip.decompress(destination.read_bytes())if packed else destination.read_bytes())==retained
    rows.append(dict(original=str(path),retained=str(destination.relative_to(ROOT)),bytes=len(raw),
                     sha256=hashlib.sha256(raw).hexdigest(),exact=exact,retainedBytes=len(retained),
                     retainedSha256=hashlib.sha256(retained).hexdigest(),gzip=packed,storedBytes=destination.stat().st_size))
(OUT/'evidence-index.json').write_text(json.dumps(dict(complete=True,rows=rows,
    scope='Reports, logs and small source snapshots are exact. Large metadata source manifests explicitly retain derived selected-declaration provenance summaries, with original hashes and exact=false. Images, QBE, assembly, hosted APIs and large input sources use retained build assets and recorded reconstruction commands.'),indent=2)+'\n')
print(json.dumps(dict(files=len(rows),storedBytes=sum(x['storedBytes']for x in rows))))
