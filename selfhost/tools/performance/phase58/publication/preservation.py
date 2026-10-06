#!/usr/bin/env python3
"""Data-only preservation audit; run outside timing, before raw writer closure."""
import argparse,hashlib,json,subprocess,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];SH=ROOT/'selfhost';RAW=SH/'build/phase58'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--installed',choices=['unchanged','selected'],required=True);p.add_argument('--attempt',type=Path);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();assert out.is_relative_to(RAW)and not out.exists();assert(a.attempt is not None)==(a.installed=='selected')
inputs={}
def identity(file):
 file=Path(file).resolve(strict=True);h=hashlib.sha256()
 with file.open('rb')as f:
  for chunk in iter(lambda:f.read(2**20),b''):h.update(chunk)
 return dict(file=str(file),bytes=file.stat().st_size,sha256=h.hexdigest())
def pin(file,expected=None):
 r=identity(file)
 if expected:
  assert r['sha256']==expected['sha256'],r['file']
  if 'bytes'in expected:assert r['bytes']==expected['bytes'],r['file']
 assert r['file']not in inputs or inputs[r['file']]==r;inputs[r['file']]=r;return r
def read(f):pin(f);return json.loads(Path(f).read_text())
report=dict(kind='phase58-preservation-audit',complete=False,pass_=False,dataOnly=True,targetExecuted=False,installedMode=a.installed,scope='File preservation and selected release identity only. This is not a release CLI, semantic, mathematical-proof or archive-closure gate.')
try:
 pin(__file__);pin(ROOT/'selfhost/tools/performance/phase57/analysis/preservation.py')
 start=read(RAW/'installed-start.json')['files'];history=read(RAW/'closed-inputs-start.json')['files'];assert len(start)==7
 assert len(start)==len({r['file']for r in start});assert len(history)==len({r['file']for r in history})
 report['priorInstalledCopies']=[]
 for old in start:
  source=Path(old['file']);assert source.is_relative_to(SH/'dist');copy=RAW/'prior-release'/source.relative_to(SH/'dist')
  report['priorInstalledCopies'].append(dict(original=old,preserved=pin(copy,old)))
 phases=['phase54','phase55','phase56','phase57'];roots=[SH/'build'/name for name in phases]
 assert all(any(Path(r['file']).is_relative_to(base)for base in roots)for r in history)
 actual={str(f.resolve())for base in roots for f in base.rglob('*')if f.is_file()};expected={r['file']for r in history}
 report['addedHistoricalFiles']=sorted(actual-expected);report['removedHistoricalFiles']=sorted(expected-actual)
 assert actual==expected,(report['addedHistoricalFiles'],report['removedHistoricalFiles'])
 for r in history:assert identity(r['file'])==r,r['file']
 report['closedHistoricalFiles']=len(history);report['closedPhases']=phases
 protected=read(ROOT/'selfhost/build/phase45/protected-start.json')['files'];assert len(protected)==103
 for r in protected:pin(ROOT/r['path'],r)
 staged=set(subprocess.check_output(['git','diff','--cached','--name-only'],cwd=ROOT,text=True).splitlines());assert not staged&{r['path']for r in protected}
 report['protectedFiles']=len(protected);report['protectedStaged']=[]
 if a.installed=='unchanged':
  current=[pin(r['file'],r)for r in start]
 else:
  attempt=read(a.attempt/'attempt.json');assert attempt['checked']and attempt['artifactKind']=='derived-b1'
  boot=read(attempt['bootstrapReport']['file']);pin(attempt['bootstrapReport']['file'],attempt['bootstrapReport'])
  release_file=SH/'dist/release.json';release=read(release_file)
  assert release['artifact']=='equality-derived-b1'and release['sourceSha256']==boot['sourceSha256']
  assert release['runtimeSha256']==attempt['runtime']['sha256'];pin(attempt['runtime']['file'],attempt['runtime'])
  direct=pin(Path(attempt['snapshot']['root'])/'src/runtime/js/direct.mjs');assert release['directRuntimeSha256']==direct['sha256']
  assert release['lineage']['checkedParentSha256']==attempt['checkedApi']['sha256']and release['lineage']['upstreamRevision']==boot['revision']
  rows=release['files'];assert len(rows)==len({r['path']for r in rows});assert {str(SH/r['path'])for r in rows}|{str(release_file)}=={r['file']for r in start}
  current=[pin(release_file)];by_path={}
  for r in rows:
   f=(SH/r['path']).resolve();assert f.is_relative_to(SH/'dist');by_path[r['path']]=pin(f,r);current.append(by_path[r['path']])
  for name,key in [('dist/typed-api.mjs','api'),('dist/base.bend','base'),('dist/release-lineage/checked-api.mjs','checkedApi'),('dist/release-lineage/checked-bootstrap.json','bootstrapReport')]:
   pin(attempt[key]['file'],attempt[key]);assert by_path[name]['sha256']==attempt[key]['sha256']
  pin(attempt['derivationReport']['file'],attempt['derivationReport']);assert by_path['dist/release-lineage/derivation.json']['sha256']==attempt['derivationReport']['sha256']
  derivation=read(SH/'dist/release-lineage/derivation.json');assert derivation['complete']and derivation['output']['sha256']==attempt['api']['sha256']
  assert release['lineage']['derivationSha256']==by_path['dist/release-lineage/derivation.json']['sha256']
  assert derivation['toolSnapshot']['sha256']==by_path['dist/release-lineage/equality.mjs']['sha256']
  assert not(SH/'dist/typed-api.mjs.bootstrap.json').exists()
  report['selectedAttempt']=pin(a.attempt/'attempt.json')
 report['installedFiles']=len(current);report['installedInventory']=current
 for r in list(inputs.values()):assert identity(r['file'])==r
 report.update(complete=True,pass_=True,inputsUnchanged=True)
except Exception as e:
 report['error']=dict(type=type(e).__name__,message=str(e))
report['pass']=report.pop('pass_');report['inputs']=list(inputs.values());out.parent.mkdir(parents=True,exist_ok=True)
with out.open('x')as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps({k:report.get(k)for k in ['complete','pass','installedFiles','closedHistoricalFiles','protectedFiles','error']}));raise SystemExit(0 if report['pass']else 1)
