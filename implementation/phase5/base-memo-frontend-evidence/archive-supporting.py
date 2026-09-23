#!/usr/bin/env python3
"""Retain historical P5-021 supporting observations without inventing input lineage."""
import gzip, hashlib, io, json, pathlib, tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3]
OUT=pathlib.Path(__file__).resolve().parent
roots=[ROOT/'selfhost/build/phase5'/n for n in ['base-cache-cost','base-memo']]
sha=lambda b:hashlib.sha256(b).hexdigest()
files={p for root in roots for p in root.rglob('*') if p.is_file()}
reports=[p for p in files if p.name=='report.json']
verified=[]; gaps=[]; external=[]
for report in sorted(reports):
 r=json.loads(report.read_text())
 for item in r.get('inputs',[]):
  p=pathlib.Path(item['file']); recorded=item.get('sha256')
  if not recorded: continue
  actual=sha(p.read_bytes()) if p.is_file() else None
  canonical=str(p.resolve()) if p.exists() else None
  if actual!=recorded or (item.get('canonicalPath') and canonical!=item['canonicalPath']):
   gaps.append({'report':str(report.relative_to(ROOT)),'input':item,'currentSha256':actual,'currentCanonicalPath':canonical});continue
  verified.append({'report':str(report.relative_to(ROOT)),'input':item})
  try:p.relative_to(ROOT)
  except ValueError:external.append(item)
  else:files.add(p)
# Recover an old consumed tool only when its exact recorded bytes were retained.
byhash={}
for p in sorted(files):byhash.setdefault(sha(p.read_bytes()),[]).append(str(p.relative_to(ROOT)))
for gap in gaps:gap['retainedExactByteCandidates']=byhash.get(gap['input']['sha256'],[])
archive=OUT/'supporting.tar.gz';assert not archive.exists();members=[]
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0) as gz:
 with tarfile.open(fileobj=gz,mode='w|') as tar:
  for p in sorted(files):
   data=p.read_bytes();name=str(p.relative_to(ROOT));info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644;tar.addfile(info,io.BytesIO(data));members.append({'path':name,'bytes':len(data),'sha256':sha(data)})
index={m['path']:m for m in members}
with tarfile.open(archive,'r:gz') as tar:
 actual=tar.getmembers();assert len(actual)==len(index)
 for item in actual:
  assert item.isfile() and not pathlib.PurePosixPath(item.name).is_absolute() and '..' not in pathlib.PurePosixPath(item.name).parts
  data=tar.extractfile(item).read();assert index[item.name]=={'path':item.name,'bytes':len(data),'sha256':sha(data)}
manifest={'kind':'phase5-base-memo-supporting-evidence','archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'members':members,'verifiedHistoricalInputs':verified,'historicalInputGaps':gaps,'external':external,'scope':'Cost attribution, focused ABBA, both candidate preparations and gates. Gaps in old mutable tool identities remain explicit; actual archived bytes are never claimed to be a different historical input.'}
(OUT/'supporting-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({k:v for k,v in manifest.items() if k not in ['members','verifiedHistoricalInputs','external']}))
