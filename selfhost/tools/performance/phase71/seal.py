#!/usr/bin/env python3
"""Small evidence archive; preserve inputs and exclude private usage telemetry."""
import hashlib,json,zipfile,datetime
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent;OUT=HERE/'evidence01'
assert not OUT.exists();OUT.mkdir()
files=[]
for directory in [ROOT/'selfhost/build/phase71',HERE]:
 for p in sorted(directory.rglob('*')):
  if OUT in p.parents or p.name.startswith('usage-') or '__pycache__' in p.parts:continue
  if p.is_file():
   assert not p.is_symlink();files.append(p)
rows=[dict(path=str(p.relative_to(ROOT)),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest(),mode=p.stat().st_mode) for p in files]
manifest=dict(kind='phase71-evidence',files=rows,privateUsageExcluded=True,external='Pinned Phase70 baseline, compiler source and toolchains are external.')
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
archive=OUT/'evidence.zip'
with zipfile.ZipFile(archive,'x',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p,row in zip(files,rows):z.write(p,row['path'])
with zipfile.ZipFile(archive) as z:
 for p,row in zip(files,rows):
  assert hashlib.sha256(z.read(row['path'])).hexdigest()==row['sha256']==hashlib.sha256(p.read_bytes()).hexdigest()
  assert z.getinfo(row['path']).external_attr>>16==row['mode']
result=dict(complete=True,recordedUtc=datetime.datetime.now(datetime.timezone.utc).isoformat(),files=len(rows),archiveBytes=archive.stat().st_size,archiveSha256=hashlib.sha256(archive.read_bytes()).hexdigest(),inputsUnchanged=True,modesVerified=True,privateUsageExcluded=True)
(OUT/'verification.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
