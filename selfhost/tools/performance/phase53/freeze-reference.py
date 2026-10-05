#!/usr/bin/env python3
"""Repack exact checked direct and TypeScript modules; no compilation or execution."""
import argparse,gzip,hashlib,json,shutil,sys,tarfile
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
PROGRAMS=HERE.parent/'programs'
sys.path.insert(0,str(PROGRAMS))
from support import identity,save
from run import load_bundle,verify
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--current',type=Path,default=HERE.parent/'phase52/bundles/current/manifest.json')
p.add_argument('--reference',type=Path,default=HERE.parent/'phase52/bundles/baseline/manifest.json')
p.add_argument('--catalog',type=Path,default=HERE.parent/'phase37/catalog.json')
p.add_argument('--out',type=Path,required=True)
p.add_argument('--attempt',type=Path,help='Required when current is a fresh candidate rather than preserved direct06')
p.add_argument('--cases',help='Selected catalog IDs; omission retains all45')
p.add_argument('--label',default='Phase52 selected direct06, exact emitted bytes')
a=p.parse_args();assert not a.out.exists()
inputs=[identity(x) for x in [__file__,PROGRAMS/'run.py',PROGRAMS/'support.py',a.catalog,a.current,a.reference]]
preserved=inputs[-2]['sha256']=='cb084a94c3ff1db33d6de1bd1f30c0d009beed609ad72496ef8d52c3247cb005'
assert preserved or a.attempt is not None, 'New baseline requires exact checked attempt'
assert inputs[-1]['sha256']=='31264f61e39ef80ca105eda58ca8d5447451c53cf7b36055deb21e4524b0d69e'
catalog=json.loads(a.catalog.read_text());catalog_sha=identity(a.catalog)['sha256'];assert len(catalog['cases'])==45
assert len({c['source']['sha256'] for c in catalog['cases']})==23
ids=a.cases.split(',') if a.cases else [c['id'] for c in catalog['cases']]
assert ids and len(ids)==len(set(ids))
selected=[next(c for c in catalog['cases'] if c['id']==name) for name in ids]
a.out.mkdir(parents=True,exist_ok=False)
current=load_bundle(a.current,catalog,catalog_sha,selected,['candidate'],inputs,a.out/'work/current')
reference=load_bundle(a.reference,catalog,catalog_sha,selected,['baseline','typescript'],inputs,a.out/'work/reference')
compiler=current['roles']['candidate']['compiler']
assert compiler['backend']=='direct' and compiler['callingContract']=='upstream-compatible-direct-v1'
assert compiler['kind']=='checked-development-attempt'
if preserved:
 assert compiler['api']['sha256']=='472da578ff9066413f0a2b8e5c0053b5bc26eae8c3cb343b5b0cbb2a62c03a3a'
 assert compiler['directRuntime']['sha256']=='417d2d47f98116d4eae889ff53132d9255c8a0ffaf047dd497b877f2df0c188a'
else:
 attempt_file=a.attempt/'attempt.json';inputs.append(identity(attempt_file));attempt=json.loads(attempt_file.read_text())
 assert attempt['checked'] and attempt['artifactKind']=='derived-b1'
 frozen={Path(r['frozen']['file']).relative_to(attempt['snapshot']['root']).as_posix():r['frozen'] for r in attempt['snapshot']['sources']}
 expected={**{k:attempt[k] for k in ['api','runtime','base']},'driver':frozen['tools/typed-driver.mjs'],'directRuntime':frozen['src/runtime/js/direct.mjs']}
 for key,row in expected.items():
  actual=identity(Path(row.get('canonicalPath',row.get('file',row.get('path')))))
  assert actual['sha256']==row['sha256']==compiler[key]['sha256'];inputs.append(actual)
  assert Path(compiler[key].get('canonicalPath',compiler[key].get('file'))).resolve()==Path(actual['path'])
 bootstrap=Path(attempt['bootstrapReport']['file']);bootstrap_pin=identity(bootstrap)
 assert bootstrap_pin['sha256']==attempt['bootstrapReport']['sha256'];inputs.append(bootstrap_pin)
 assert compiler['sourceSha256']==json.loads(bootstrap.read_text())['sourceSha256']
for manifest in [a.current,a.reference]:
 origin=json.loads(manifest.read_text())
 key='provenance' if 'provenance' in origin else 'preparation'
 inputs.append(verify(manifest.parent/origin[key]['path'],origin[key]))
 assert json.loads((manifest.parent/origin[key]['path']).read_text())['complete']
roles=dict(baseline=dict(current['roles']['candidate'],label=a.label),typescript=reference['roles']['typescript'])
cases=[];members={}
for case in selected:
 modules={}
 for role,bundle,oldrole in [('baseline',current,'candidate'),('typescript',reference,'typescript')]:
  old=bundle['points'][case['id']][oldrole];name=role+'/'+old['sha256']+'.mjs'
  modules[role]=dict(path=name,sha256=old['sha256'],bytes=old['bytes']);members[name]=Path(old['resolved'])
 cases.append(dict(id=case['id'],sourceSha256=case['source']['sha256'],point=case['point'],modules=modules))
archive=a.out/'programs.tar.gz'
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',filename='',mtime=0) as gz,tarfile.open(fileobj=gz,mode='w|') as tar:
 for name,source in sorted(members.items()):
  info=tarfile.TarInfo(name);info.size=source.stat().st_size;info.mode=0o644;info.mtime=0
  with source.open('rb') as stream:tar.addfile(info,stream)
for row in inputs:assert identity(row['path'])==row
provenance=dict(kind='phase53-checked-direct-reference-role-remap',complete=True,dataOnly=True,inputs=inputs,inputsUnchanged=True,
 scope='Exact checked direct candidate bytes become baseline; exact pinned TS bytes remain. No old archive/whole evidence duplication, source change, recompile, execution or historical timing relabel.',roles=roles,cases=len(selected),distinctModules=len(members))
save(a.out/'provenance.json',provenance)
def relative(file):
 row=identity(file);row['path']=file.name;return row
save(a.out/'manifest.json',dict(kind='bend-program-bundle',schemaVersion=1,complete=True,upstreamCommit=catalog['upstreamCommit'],catalogSha256=catalog_sha,
 roles=roles,cases=cases,comparisonContract=compiler['callingContract'],archive=relative(archive),provenance=relative(a.out/'provenance.json')))
checks=[];reopened=load_bundle(a.out/'manifest.json',catalog,catalog_sha,selected,['baseline','typescript'],checks)
assert len(reopened['points'])==len(selected)
for case in cases:
 for role in ['baseline','typescript']:assert reopened['points'][case['id']][role]==case['modules'][role]
for row in inputs+checks:assert identity(row['path'])==row
shutil.rmtree(a.out/'work')
save(a.out/'baseline-binding.json',dict(kind='phase53-baseline-compiler-binding',complete=True,label=a.label,compiler=compiler,manifest=identity(a.out/'manifest.json'),catalogSha256=catalog_sha,provenance=identity(a.out/'provenance.json')))
print(json.dumps(dict(complete=True,cases=len(selected),rolePointMappings=2*len(selected),distinctModules=len(members),archive=identity(archive),manifest=identity(a.out/'manifest.json'))))
