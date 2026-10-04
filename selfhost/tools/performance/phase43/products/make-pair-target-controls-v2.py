"""Fix sequential definition visibility; preserve all v1 consumed target inputs."""
from pathlib import Path
import hashlib,json,sys
base=Path(__file__).resolve().parent
for name in ['pair-target','pair-ignored-target']:
 old=base/'fixtures'/(name+'-controls.bend');s=old.read_text()
 marker='# Binary recursion keeps this independent consumer outside the older Nat scalar island.'
 at=s.index(marker);observer=s[at:];body=s[:at].rstrip()+'\n'
 assert body.startswith('import Base\n');fixed='import Base\n\n'+observer+'\n'+body[len('import Base\n'):].lstrip('\n')
 new=base/'fixtures'/(name+'-controls-v2.bend');assert not new.exists();new.write_text(fixed)
 assert fixed.index('def p43.pair.observer(')<fixed.index('def p43.pair.'+('ignored.finish'if 'ignored'in name else'finish')+'(')
 oldcatalog=base/(name+'-catalog-v1.json');r=json.loads(oldcatalog.read_text());data=new.read_bytes()
 for c in r['cases']:
  c['source'].update(path='fixtures/'+new.name,sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
 r['oracleProducer']=dict(path='make-pair-target-controls-v2.py',sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
 r['sourceVersion']=2;r['corrects']='Sequential source checker requires observer definition filled before consumer calls'
 catalog=base/(name+'-catalog-v2.json');assert not catalog.exists();catalog.write_text(json.dumps(r,indent=2)+'\n')
 sys.path.insert(0,str(base.parents[0]/'programs'))
 # Canonical maintained module is two directories above phase43.
 sys.path.insert(0,str(base.parents[1]/'programs'))
 from prepare import select,checked_source
 for key in ['fast','core','broad','full']:
  for c in select(r,key,None):checked_source(c,catalog)
 print(catalog, len(r['cases']), 'selector/hash PASS',hashlib.sha256(data).hexdigest())
