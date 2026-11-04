#!/usr/bin/env python3
"""Content-deduplicated, reopened and hash-verified evidence; no deletion."""
import gzip,hashlib,io,json,shutil,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'implementation/phase161/evidence';OUT.mkdir(exist_ok=True)
archive=OUT/'phase161.tar.gz';assert not archive.exists()
def digest(f):
 h=hashlib.sha256();n=0
 for b in iter(lambda:f.read(1024*1024),b''):h.update(b);n+=len(b)
 return dict(bytes=n,sha256=h.hexdigest())
def pin(p):
 with p.open('rb') as f:return digest(f)
files=set()
for name in ['selfhost/build/phase161','experiments/phase161','selfhost/tools/profiler']:
 files.update(p for p in (ROOT/name).rglob('*') if p.is_file() and '__pycache__' not in p.parts)
files.update((ROOT/'selfhost/build-retention/phase161').rglob('*.json'))
files.update(ROOT/name for name in ['selfhost/tools/build/common.py','selfhost/tools/execution.py',
 'selfhost/tools/build-retention/guard.py','selfhost/tools/build-retention/close.py',
 'selfhost/tools/build-retention/archive-v02.py','experiments/phase147/tools/profile-candidate.py'])
aliases={};payloads={};sources={}
for p in sorted(files):
 assert p.resolve()==p
 identity=pin(p);key='payloads/'+identity['sha256'];sources.setdefault(key,p)
 aliases[str(p.relative_to(ROOT))]=dict(payload=key,mode=p.stat().st_mode&0o777,**identity)
 payloads[key]=identity
prerequisites=[]
for phase in [152,153,156,157,158,159,160]:
 p=ROOT/f'implementation/phase{phase}/evidence/capsule.json'
 prerequisites.append(dict(receipt=str(p.relative_to(ROOT)),**pin(p)))
index=dict(kind='phase161-exact-evidence',complete=True,payloads=payloads,aliases=aliases,
 prerequisites=prerequisites,scope='Exact source request outputs, diagnostic relink, profiles, source audits, failed diagnostic preparation/build methods, closure/pruning and read-only alias receipts. Content-identical files share one archive payload. External inputs/images/oracles are preserved by the pinned prerequisite capsules; system toolchain remains external. No production promotion.')
encoded=(json.dumps(index,indent=2)+'\n').encode()
assert shutil.disk_usage(ROOT).free>5*1024**3+40*1024**2
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,filename='',mode='wb',mtime=0,compresslevel=6) as gz,tarfile.open(fileobj=gz,mode='w|') as tf:
 info=tarfile.TarInfo('INDEX.json');info.size=len(encoded);info.mode=0o644;tf.addfile(info,io.BytesIO(encoded))
 for key,p in sorted(sources.items()):
  assert pin(p)==payloads[key]
  info=tarfile.TarInfo(key);info.size=payloads[key]['bytes'];info.mode=0o644
  with p.open('rb') as f:tf.addfile(info,f)
seen=set()
with tarfile.open(archive,'r:gz') as tf:
 for m in tf:
  assert m.isfile() and m.name not in seen;seen.add(m.name)
  with tf.extractfile(m) as f:
   if m.name=='INDEX.json':assert f.read()==encoded
   else:assert m.name in payloads and digest(f)==payloads[m.name]
assert seen==set(payloads)|{'INDEX.json'}
for name,row in aliases.items():assert pin(ROOT/name)=={k:row[k] for k in ['bytes','sha256']}
index.update(archive=dict(path=archive.name,**pin(archive)),reopenedVerified=True,inputsUnchanged=True,
 logicalBytes=sum(r['bytes'] for r in aliases.values()),payloadBytes=sum(r['bytes'] for r in payloads.values()),
 restore='Read INDEX.json, verify each payload SHA256/bytes, then restore each alias only into an absent path and apply its saved mode. Never overwrite frozen artifacts.')
(OUT/'capsule.json').write_text(json.dumps(index,indent=2)+'\n')
print(json.dumps(dict(archive=index['archive'],files=len(aliases),payloads=len(payloads),logicalBytes=index['logicalBytes'],payloadBytes=index['payloadBytes'])))
