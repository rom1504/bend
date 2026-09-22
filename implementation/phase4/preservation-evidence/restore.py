"""Verify every archived object; optionally restore one group to a fresh overlay."""
from pathlib import Path
import sys,json,gzip,hashlib
here=Path(__file__).resolve().parent;j=json.loads((here/'manifest.json').read_text())
for e in j['entries']:
 packed=(here/e['object']).read_bytes();assert hashlib.sha256(packed).hexdigest()==e['objectSha256']
 data=gzip.decompress(packed);assert len(data)==e['bytes'] and hashlib.sha256(data).hexdigest()==e['sha256']
if len(sys.argv)==3:
 group,destination=sys.argv[1:];target=Path(destination).resolve();target.mkdir(parents=True,exist_ok=False)
 selected=[e for e in j['entries'] if e['group']==group];assert selected,'Unknown group'
 for e in selected:
  relative=Path(e['restoreRelative']);assert not relative.is_absolute() and '..'not in relative.parts
  p=target/relative;p.parent.mkdir(parents=True,exist_ok=True);data=gzip.decompress((here/e['object']).read_bytes())
  if p.exists():assert p.read_bytes()==data
  else:p.write_bytes(data)
 print('Restored',len(selected),'entries to',target)
else:
 assert len(sys.argv)==1,'Usage: restore.py [GROUP NEW_OVERLAY_DIRECTORY]'
 print('Verified',len(j['entries']),'entries;',j['uniqueObjects'],'unique objects')
 print('Groups:',', '.join(sorted({e['group'] for e in j['entries']})))
