#!/usr/bin/env python3
"""Read-only streaming Phase59 preservation checks; one fresh receipt only."""
import argparse,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
RAW=ROOT/'selfhost/build/phase59'
PUB_SHA='0338c3a7bb88a0564e692fb09e2b8ede6c0e24352a239525e6d8b892f5f0cf90'
def ident(p):
 p=Path(p).resolve(strict=True);h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1024**2),b''):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
def verify(row):
 p=Path(row.get('file',row.get('path')));p=p if p.is_absolute() else ROOT/p
 actual=ident(p)
 assert actual['sha256']==row['sha256'],str(p)
 if 'bytes' in row:assert actual['bytes']==row['bytes'],str(p)
 return actual
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
report=dict(kind='phase59-preservation-audit',complete=False,pass_=False,producer=ident(__file__))
try:
 closedPath=RAW/'closed-phase58-start.json';installedPath=RAW/'installed-start.json'
 closed=json.loads(closedPath.read_text());installed=json.loads(installedPath.read_text())
 assert closed['complete'] and installed['complete']
 assert len(closed['files'])==30169 and len(installed['files'])==7
 assert len({r['file'] for r in closed['files']})==30169
 for row in closed['files']:verify(row)
 original={str(Path(r['file']).resolve()) for r in closed['files']}
 current={str(p.resolve()) for p in (ROOT/'selfhost/build/phase58').rglob('*') if p.is_file()}
 assert current==original,'Closed Phase58 inventory changed'
 for row in installed['files']:verify(row)
 protectedPath=ROOT/'selfhost/build/phase45/protected-start.json'
 protected=json.loads(protectedPath.read_text())['files'];assert len(protected)==103
 for row in protected:verify(row)
 staged=set(subprocess.check_output(['git','diff','--cached','--name-only'],cwd=ROOT,text=True).splitlines())
 assert not staged & {r['path'] for r in protected},'Protected files staged'
 pubPath=ROOT/'selfhost/tools/performance/phase58/publication.json'
 assert ident(pubPath)['sha256']==PUB_SHA
 pub=json.loads(pubPath.read_text());assert pub['complete'] and pub['inputsUnchanged']
 source=verify(pub['sourceAccounting']);account=json.loads(Path(source['file']).read_text())
 verify(account['live']['manifest'])
 for row in account['live']['files']:verify(row)
 attempt=verify(pub['selected']['attempt']);data=json.loads(Path(attempt['file']).read_text())
 selected=[]
 for pair in data['snapshot']['sources']:
  originalPath=Path(pair['original']['file'])
  if originalPath.is_relative_to(ROOT/'selfhost/src') or originalPath==ROOT/'selfhost/tools/typed-driver.mjs':
   verify(pair['frozen']);selected.append(verify(pair['original']))
 assert any(r['file'].endswith('/typed-driver.mjs') for r in selected)
 assert any(r['file'].endswith('/src/runtime/js/direct.mjs') for r in selected)
 assert any(r['file'].endswith('/src/runtime.mjs') for r in selected)
 report.update(complete=True,pass_=True,closedHistoricalFiles=30169,installedFiles=7,protectedFiles=103,
  protectedStaged=[],compilerRuntimeDriverFiles=len(selected),publication=ident(pubPath),sourceAccounting=source,
  inventories=[ident(closedPath),ident(installedPath),ident(protectedPath)],selectedAttempt=attempt)
except Exception as error:report['error']=repr(error)
report['pass']=report.pop('pass_');out.parent.mkdir(parents=True,exist_ok=True)
with out.open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps({k:report.get(k) for k in ['complete','pass','closedHistoricalFiles','installedFiles','protectedFiles','error']}))
raise SystemExit(0 if report['pass'] else 1)
