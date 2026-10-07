#!/usr/bin/env python3
"""Create data-only preservation/publication successors; perform no audit or archive."""
import argparse,ast,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
TOOLS=ROOT/'selfhost/tools/performance'
RAW=ROOT/'selfhost/build/phase61'
PARENTS={
 'phase58/publication/preservation.py':'4420958a1a0059066bfe163a130e87fd977e40df4610684b8d2f5ca050dbffb5',
 'phase60/publication/preservation-v1.py':'44502fcf7c5129c7fcfb72d0bdc2be7ae99d1d0397b12722f8361404d7b33ad8',
 'phase60/publication/publish-parts-v1.py':'44a55044a6ab7316fc571238a47926e3c5fca3102e0dc598bf0a5979dcd76fc1'}

def identity(p):
 p=Path(p).resolve(strict=True)
 return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())

ARCHIVE_CHECK='''
 closed=read(RAW/'closed-inventories.json');assert closed['complete'] and len(closed['archives'])==3
 roots={SH/'build'/name for name in ['phase58','phase59','phase60']};seen=set();closedCount=0
 archiveInputs=[]
 for row in closed['archives']:
  raw=Path(row['rawRoot']).resolve();assert raw in roots and raw not in seen;seen.add(raw)
  assert row['phase']==raw.name
  metadata=pin(row['archiveMetadata']['file'],row['archiveMetadata']);archiveInputs.append(metadata)
  capsule=read(metadata['file'])
  assert capsule['complete'] and capsule['reopenedVerified'] and capsule['inputStabilityVerified']
  assert Path(capsule['rawRoot']).resolve()==raw
  members=capsule['files'];assert capsule['members']==row['files']==len(members)>0
  expected=set()
  for name,fact in members.items():
   rel=Path(name);assert not rel.is_absolute() and '..' not in rel.parts
   target=raw/rel;assert not target.is_symlink();actual=identity(target)
   assert actual['sha256']==fact['sha256'] and actual['bytes']==fact['bytes'],str(target)
   expected.add(name)
  current=set()
  for target in raw.rglob('*'):
   assert not target.is_symlink(),'Closed tree symlink: '+str(target)
   if target.is_file():current.add(target.relative_to(raw).as_posix())
  assert current==expected,'Closed archive inventory changed: '+str(raw)
  assert identity(metadata['file'])==metadata
  closedCount+=len(members)
 assert seen==roots
 report['closedHistoricalFiles']=closedCount;report['closedPhases']=sorted(r.name for r in roots)
 report['closedArchives']=archiveInputs
'''.strip('\n')+'\n'

CAPTURE='''#!/usr/bin/env python3
"""Preserve the seven starting installed files before an admitted replacement."""
import hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5];RAW=ROOT/'selfhost/build/phase61';DIST=ROOT/'selfhost/dist'
def identity(p):
 p=Path(p).resolve(strict=True);h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024**2),b''):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
start=RAW/'installed-start.json';data=json.loads(start.read_text());rows=data['files']
assert data['complete'] and len(rows)==len({r['file'] for r in rows})==7
dest=RAW/'prior-release';assert not dest.exists();report=RAW/'installed-retention.json';assert not report.exists()
for row in rows:assert identity(row['file'])==row
copies=[];dest.mkdir()
for row in rows:
 src=Path(row['file']);assert src.is_relative_to(DIST)
 target=dest/src.relative_to(DIST);target.parent.mkdir(parents=True,exist_ok=True)
 with src.open('rb') as inp,target.open('xb') as out:shutil.copyfileobj(inp,out,1024**2)
 copy=identity(target);assert (copy['bytes'],copy['sha256'])==(row['bytes'],row['sha256'])
 copies.append(dict(original=row,preserved=copy))
for row in rows:assert identity(row['file'])==row
with report.open('x') as out:json.dump(dict(kind='phase61-prior-installed-retention',complete=True,producer=identity(__file__),start=identity(start),copies=copies,installedUnchanged=True),out,indent=2);out.write('\\n')
print(json.dumps(identity(report)))
'''

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 out=a.out.resolve();assert out.parent==RAW.resolve() and not out.exists()
 pins={name:identity(TOOLS/name) for name in PARENTS}
 for name,expected in PARENTS.items():assert pins[name]['sha256']==expected,name
 original=(TOOLS/'phase58/publication/preservation.py').read_text();text=original;edits=[]
 def change(old,new):
  nonlocal text
  assert text.count(old)==1,old
  text=text.replace(old,new);edits.append(dict(old=old,new=new))
 change("RAW=SH/'build/phase58'","RAW=SH/'build/phase61'")
 change("kind='phase58-preservation-audit'","kind='phase61-preservation-audit'")
 change("start=read(RAW/'installed-start.json')['files'];history=read(RAW/'closed-inputs-start.json')['files'];assert len(start)==7", "start=read(RAW/'installed-start.json')['files'];assert len(start)==7")
 change("assert len(start)==len({r['file']for r in start});assert len(history)==len({r['file']for r in history})", "assert len(start)==len({r['file']for r in start})")
 begin=text.index(" phases=['phase54'");end=text.index(" protected=read(",begin)
 change(text[begin:end],ARCHIVE_CHECK)
 publisher=(TOOLS/'phase60/publication/publish-parts-v1.py').read_text()
 pub=publisher.replace('Phase60','Phase61').replace('phase60','phase61')
 outputs={'preservation.py':text,'publish-parts.py':pub,'capture-installed.py':CAPTURE}
 for name,body in outputs.items():ast.parse(body,filename=name)
 (out/'publication').mkdir(parents=True)
 rows=[]
 for name,body in outputs.items():
  dest=out/'publication'/name
  with dest.open('x') as f:f.write(body)
  rows.append(dict(name=name,output=identity(dest)))
 for name,pin in pins.items():assert identity(pin['file'])==pin
 result=dict(kind='phase61-preservation-methods',complete=True,targetsExecuted=False,auditExecuted=False,
  producer=identity(__file__),parents=pins,outputs=rows,preservationEdits=edits,
  publisherEdits=[dict(old='Phase60',new='Phase61'),dict(old='phase60',new='phase61')],
  scope='Phase58 exact selected-release/installed7/protected103 checks with Phase60 streaming archive inventory checks for closed58–60. Live editable compiler sources are not an unchanged-baseline claim. Root alone captures/audits/publishes outside timing.')
 with (out/'methods.json').open('x') as f:json.dump(result,f,indent=2);f.write('\n')
 print(json.dumps(identity(out/'methods.json')))

if __name__=='__main__':main()
