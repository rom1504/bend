#!/usr/bin/env python3
"""Deduplicate and verify Phase82 evidence; run only after all target writers close."""
import datetime,hashlib,json,stat,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent;OUT=HERE/'evidence01'
assert not OUT.exists();OUT.mkdir()
def digest(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  while chunk:=f.read(1024*1024):h.update(chunk)
 return h.hexdigest()
files=[];empty=[];objects={};links=[]
for directory in [ROOT/'selfhost/build/phase82',HERE]:
 for p in sorted(directory.rglob('*')):
  if OUT in p.parents or p.name.startswith('usage-') or '__pycache__' in p.parts:continue
  if p.is_symlink():
   links.append(dict(path=str(p.relative_to(ROOT)),target=str(p.readlink())));continue
  if p.is_dir() and not any(p.iterdir()):empty.append(str(p.relative_to(ROOT)))
  if p.is_file():
   sha=digest(p);files.append(dict(path=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=sha,mode=stat.S_IMODE(p.stat().st_mode)));objects.setdefault(sha,p)
manifest=dict(kind='phase82-content-addressed-evidence-v1',files=files,symbolicLinks=links,emptyDirectories=empty,privateUsageExcluded=True,external='Historical phase baselines, pinned upstream and toolchains remain external dependencies. All Phase82 measurements, diagnostic derivative, profiles and outputs are included.')
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
archive=OUT/'objects.zip'
with zipfile.ZipFile(archive,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for sha,p in objects.items():
  assert digest(p)==sha;z.write(p,'objects/'+sha)
with zipfile.ZipFile(archive) as z:
 for sha in objects:assert hashlib.sha256(z.read('objects/'+sha)).hexdigest()==sha
 for r in files:
  p=ROOT/r['path'];assert digest(p)==r['sha256'] and stat.S_IMODE(p.stat().st_mode)==r['mode'] and p.stat().st_size==r['bytes']
for r in links:assert str((ROOT/r["path"]).readlink())==r["target"]
whole=digest(archive);parts=[]
with archive.open('rb') as f:
 while chunk:=f.read(32*1024*1024):
  part=OUT/('objects.zip.part-%03d'%len(parts));part.write_bytes(chunk);parts.append(dict(path=part.name,bytes=len(chunk),sha256=digest(part)))
joined=hashlib.sha256()
for r in parts:joined.update((OUT/r['path']).read_bytes())
assert joined.hexdigest()==whole
result=dict(complete=True,recordedUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),files=len(files),uniqueObjects=len(objects),inputBytes=sum(r['bytes'] for r in files),archiveBytes=archive.stat().st_size,archiveSha256=whole,manifestSha256=digest(OUT/'manifest.json'),parts=parts,inputsUnchanged=True,modesRecordedAndVerified=True,allArchivedContentVerified=True,privateUsageExcluded=True)
(OUT/'verification.json').write_text(json.dumps(result,indent=2)+'\n');archive.unlink();print(json.dumps({k:v for k,v in result.items() if k!='parts'}))
