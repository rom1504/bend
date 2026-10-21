"""Deduplicate only three exact immutable generation products; retain all paths."""
import hashlib,json,os
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
out=ROOT/'selfhost/build/phase115/dedup01.json'
assert not out.exists()
pairs=[('p114-native-final02-full-emit/program.ssa','p114-native-final02-self/program.ssa'),('p114-native-final02-n1/program.s','p114-native-final02-self/build/program.s'),('p114-native-final02-n1/program.o','p114-native-final02-self/build/program.o')]
rows=[]
for left,right in pairs:
 a,b=[ROOT/'selfhost/build/phase111'/n for n in [left,right]]
 assert a.is_file() and b.is_file() and not a.is_symlink() and not b.is_symlink()
 x,y=pin(a),pin(b);assert (x['bytes'],x['sha256'])==(y['bytes'],y['sha256'])
 rows.append(dict(left=x,right=y,alreadyLinked=os.path.samefile(a,b)))
report=dict(complete=False,method=pin(Path(__file__).resolve()),files=rows,scope='Exact immutable build products only. Original paths and bytes remain; never mutate these frozen files in place. No source, executable or runtime touched.')
out.write_text(json.dumps(report,indent=2)+'\n')
for row in rows:
 a,b=[Path(row[k]['file']) for k in ['left','right']]
 if not row['alreadyLinked']:
  temp=b.with_name(b.name+'.dedup115');assert not temp.exists()
  os.link(a,temp);os.replace(temp,b)
 assert pin(a)==row['left'] and pin(b)==row['right'] and os.path.samefile(a,b)
report.update(complete=True,reclaimedBytes=sum(r['left']['bytes'] for r in rows if not r['alreadyLinked']))
out.write_text(json.dumps(report,indent=2)+'\n');print(report['reclaimedBytes'])
