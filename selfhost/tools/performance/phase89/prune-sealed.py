#!/usr/bin/env python3
"""Prune large archived experimental copies, verifying archive and local bytes."""
import hashlib,json,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def sha(b):return hashlib.sha256(b).hexdigest()
protected=set(json.loads((ROOT/'selfhost/tools/performance/phase88/evidence01/native-assets.json').read_text())['files'])
protected.add('selfhost/build/phase86/runtime01/receipt.json')
rows=[];archives=[]
for phase in [84,85,86,87]:
 directory=ROOT/f'selfhost/tools/performance/phase{phase}/evidence01'
 archive=directory/f'phase{phase}.zip';manifest=directory/'manifest.json'
 if not archive.exists() or not manifest.exists():continue
 records=json.loads(manifest.read_text())
 if not isinstance(records,list):continue
 archives.append(dict(file=str(archive.relative_to(ROOT)),sha256=sha(archive.read_bytes()),bytes=archive.stat().st_size))
 with zipfile.ZipFile(archive) as saved:
  members=set(saved.namelist())
  for record in records:
   name=record.get('file','');p=ROOT/name
   if name in protected or not name.startswith(f'selfhost/build/phase{phase}/') or not p.is_file():continue
   if p.stat().st_size<65536 or name not in members:continue
   data=p.read_bytes()
   assert len(data)==record['bytes'] and sha(data)==record['sha256'],name
   assert saved.read(name)==data,name
   p.unlink();rows.append(record)
report=dict(complete=True,archives=archives,removed=rows,freedBytes=sum(r['bytes'] for r in rows),scope='Large raw experimental copies only, verified against unchanged historical capsules; active native admission assets protected.')
path=ROOT/'implementation/phase89/prune-sealed01.json'
with path.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(files=len(rows),freedBytes=report['freedBytes'])))
