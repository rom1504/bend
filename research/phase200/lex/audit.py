"""Read-only actual ELF evidence for recomputation and eliminated helper work."""
from pathlib import Path
import subprocess,re,json,hashlib
P=Path(__file__).resolve().parent
obj=Path('selfhost/build/phase200/lex-token03/candidate.o')
def pin(f):
 f=Path(f);b=f.read_bytes();return dict(file=str(f),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def pretty(n):
 m=re.search(r'FID_((?:\d+_)+)$',n)
 return ''.join(chr(int(t)) for t in m[1].rstrip('_').split('_')) if m else n
wanted={'$direct.p200.ident','$direct.p200.number','$direct.p200.plan','$direct.p93.loop'}
raw=subprocess.check_output(['objdump','-dr','-M','intel','--no-show-raw-insn',str(obj)],text=True)
rows=[];current=None
for line in raw.splitlines():
 m=re.match(r'([0-9a-f]+) <(.*)>:',line)
 if m:
  name=pretty(m[2]);current=dict(symbol=m[2],decoded=name,address=int(m[1],16),instructions=[],relocations=[]) if name in wanted else None
  if current:rows.append(current)
 elif current:
  m=re.match(r'\s*([0-9a-f]+):\s+(.*)',line)
  if m:
   text=m[2]
   for token in re.findall(r'[A-Za-z_0-9.]+',text):
    if 'FID_' in token:text=text.replace(token,pretty(token))
   current['relocations' if text.startswith('R_') else 'instructions'].append([m[1],text])
for row in rows:
 if row['decoded'] in ['$direct.p200.ident','$direct.p200.number']:assert not row['relocations']
 if row['decoded']=='$direct.p200.plan':assert all('p111_rt_' not in t and 'p125_rt_' not in t for _,t in row['relocations'])
 if row['decoded']=='$direct.p93.loop':assert any('$direct.p93.value' in t for _,t in row['relocations'])
(P/'machine.json').write_text(json.dumps(dict(object=pin(obj),method=pin(__file__),scope='Actual ELF, no target execution. Scalar token loops have no calls; plan calls only ordinary scalar helpers; benchmark repetition worker transfers to p93.value on every positive iteration.',workers=rows),indent=2)+'\n')
print([(r['decoded'],len(r['instructions']),len(r['relocations'])) for r in rows])
