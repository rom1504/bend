"""Retain every immutable artifact path/byte, coalesce exact duplicate inodes."""
from pathlib import Path
import hashlib,json,os
ROOT=Path(__file__).resolve().parents[4]
plan=ROOT/'selfhost/build/phase116/dedup-plan01.json';out=ROOT/'selfhost/build/phase116/dedup01.json'
assert not out.exists()
rows=json.loads(plan.read_text());freed=0
for r in rows:
 ps=[ROOT/p for p in r['paths']]
 for p in ps:
  assert p.is_file() and not p.is_symlink() and p.stat().st_size==r['bytes'] and hashlib.sha256(p.read_bytes()).hexdigest()==r['sha256']
 for p in ps[1:]:
  if os.path.samefile(ps[0],p):continue
  if p.stat().st_nlink==1:freed+=p.stat().st_size
  temp=p.with_name(p.name+'.dedup116');assert not temp.exists();os.link(ps[0],temp);os.replace(temp,p)
  assert hashlib.sha256(p.read_bytes()).hexdigest()==r['sha256']
out.write_text(json.dumps(dict(complete=True,reclaimedBytes=freed,plan=str(plan),scope='Frozen generated QBE/assembly/object only; all paths and bytes retained. Never modify linked artifacts in place.',groups=rows),indent=2)+'\n')
print(freed)
