#!/usr/bin/env python3
"""Verify full checked acquisitions; plan fresh timing only for changed module bytes."""
import argparse, copy, hashlib, importlib.util, json, sys
from pathlib import Path
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent; TOOLS=HERE.parents[1]; ROOT=HERE.parents[4]
sys.path.insert(0,str(TOOLS/'programs'))
from run import load_bundle,relative_path

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--candidate',type=Path,required=True);p.add_argument('--attempt',type=Path,required=True)
p.add_argument('--out',type=Path,required=True);p.add_argument('--timing-scope',choices=['changed','full'],default='changed')
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase58') and not out.exists()
catalog_file=TOOLS/'phase37/catalog.json'
baseline_file=ROOT/'selfhost/build/phase56/string01-full/manifest.json'
publication_file=TOOLS/'phase56/publication.json';installed_start_file=ROOT/'selfhost/build/phase58/installed-start.json';preserved_release_file=ROOT/'selfhost/build/phase58/prior-release/release.json';reference_file=TOOLS/'phase53/bundles/baseline/manifest.json'
inputs=[]
def pin(file,expected=None):
 file=Path(file).resolve(strict=True);data=file.read_bytes()
 row=dict(file=str(file),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
 if expected:
  assert row['sha256']==expected['sha256'],str(file)
  if 'bytes' in expected:assert row['bytes']==expected['bytes'],str(file)
 inputs.append(row);return row
def read(file,expected=None):pin(file,expected);return json.loads(Path(file).read_text())
def save(file,value):
 file.parent.mkdir(parents=True,exist_ok=True)
 with file.open('x') as stream:json.dump(value,stream,indent=2);stream.write('\n')
def asset(entry):return pin(entry.get('file',entry.get('path')),entry)
def same(a,b):return a['sha256']==b['sha256'] and a['bytes']==b['bytes']
pin(__file__);pin(TOOLS/'programs/run.py');pin(TOOLS/'programs/support.py');pin(TOOLS/'phase56/performance/compare.py',{'sha256':'a7c4f9cf699fe9e8eef4c435f105dd4435088b5c7e88fe6abe26e15cdd1f84ef'})
observer_file=TOOLS/'phase52/prepare-v2.py'
observer_id=pin(observer_file,{'sha256':'7a08af571e14ed0f508d49eb1a8560b76d05cd6cf6438b5f4d119fadc818b017'})
spec=importlib.util.spec_from_file_location('phase58_unchanged_observer',observer_file)
observer=importlib.util.module_from_spec(spec);spec.loader.exec_module(observer)
catalog=read(catalog_file);catalog_id=pin(catalog_file);cases=catalog['cases'];assert len(cases)==45
assert catalog['upstreamCommit']=='018751270e800bc222a93dad7f257083ee53a5f7'
assert len({c['id']for c in cases})==45 and len({c['source']['sha256']for c in cases})==23
for c in cases:pin(relative_path(catalog_file.parent,c['source']['path']),c['source'])
baseline=read(baseline_file,{'sha256':'6fd08b9b05a7c4d3afeb1c05e34e18ca6c1f9501bfb83fe2cfbca4b76af2056c'});candidate=read(a.candidate)
publication=read(publication_file);installed_start=read(installed_start_file);saved_release=read(preserved_release_file)
assert publication['complete'] and publication['selected']['attempt']=='checked-string01'
assert publication['selected']['api']['sha256']=='128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea'
assert publication['selected']['release']['sha256']==pin(preserved_release_file)['sha256']
start_release=[r for r in installed_start['files']if r['file']==str(ROOT/'selfhost/dist/release.json')];assert len(start_release)==1
assert pin(preserved_release_file,start_release[0])['sha256']==publication['selected']['release']['sha256']
saved_api=[r for r in saved_release['files']if r['path']=='dist/typed-api.mjs'];assert len(saved_api)==1
assert saved_api[0]['sha256']==publication['selected']['api']['sha256'] and saved_release['sourceSha256']==publication['selected']['sourceSha256']
assert saved_release['directRuntimeSha256']==publication['selected']['directRuntimeSha256']
reference=read(reference_file,{'sha256':'37be3740c46d98c16342448e5082313a49fdc32da806e10a75ce694934faa3d0'})
assert baseline['roles']['candidate']['compiler']['api']['sha256']=='128619779fb5e29138bd33273bc5de6b81f39bdb54c2cebb93e69f3ca63acaea'
assert reference['roles']['typescript']['compiler']['kind']=='checked-pinned-typescript'
for manifest in [baseline,candidate,reference]:
 assert len(manifest['cases'])==45 and {r['id']for r in manifest['cases']}=={c['id']for c in cases}

def acquisition(file,manifest,attempt_file):
 root=file.resolve().parent;attempt_id=pin(attempt_file);attempt=read(attempt_file)
 assert attempt['checked'] and attempt['kind']=='bend-development-attempt'
 compiler=manifest['roles']['candidate']['compiler'];assert compiler['kind']=='checked-development-attempt'
 assert compiler['backend']=='direct' and compiler['callingContract']=='upstream-compatible-direct-v1'
 for key in ['api','runtime','base']:
  assert compiler[key]['sha256']==attempt[key]['sha256'];asset(compiler[key]);asset(attempt[key])
 frozen={Path(r['frozen']['file']).resolve():r['frozen']['sha256']for r in attempt['snapshot']['sources']}
 for key in ['driver','directRuntime']:
  assert frozen[Path(compiler[key]['file']).resolve()]==compiler[key]['sha256'];asset(compiler[key])
 prep=read(relative_path(root,manifest['preparation']['path']),manifest['preparation'])
 assert prep['complete'] and prep['backend']=='direct' and len(prep['sources'])==23
 assert prep['catalog']['sha256']==catalog_id['sha256'] and prep['producer']['sha256']==observer_id['sha256']
 raw={}
 for source in prep['sources']:
  assert source['process']['complete'] and source['process']['returncode']==0
  receipt=read(relative_path(root,source['emission']['path']),source['emission'])
  assert receipt['kind']=='bend-program-checked-emission' and receipt['complete']
  assert receipt['observation']['checked'] and receipt['observation']['status']=='ok' and receipt['observation']['exitCode']==0
  assert receipt['compiler']==compiler and receipt['attempt']['sha256']==attempt_id['sha256']
  assert receipt['input']['sha256']==source['source']['sha256'];asset(receipt['input'])
  emitted=asset(receipt['output']);assert receipt['input']['sha256'] not in raw
  for r in receipt['emissionInputs']:asset(r)
  raw[receipt['input']['sha256']]=emitted
 assert set(raw)=={c['source']['sha256']for c in cases}
 by_id={r['id']:r for r in manifest['cases']}
 for case in cases:
  source=raw[case['source']['sha256']];row=by_id[case['id']]['modules']['candidate']
  final=pin(relative_path(root,row['path']),row);data=Path(source['file']).read_bytes()
  if case.get('adapter'):
   assert case['adapter']=='generic-row'
   adapters=[r for r in prep['adapters']if r['raw']['sha256']==source['sha256']]
   assert len(adapters)==1 and adapters[0]['producer']['sha256']==observer_id['sha256']
   assert adapters[0]['adapted']['sha256']==final['sha256']
   data=observer.observe_row(data.decode(),typescript=True).encode()
  assert Path(final['file']).read_bytes()==data,'Raw/observer join: '+case['id']
 return raw

old_raw=acquisition(baseline_file,baseline,ROOT/'selfhost/build/phase56/checked-string01/attempt.json')
new_raw=acquisition(a.candidate,candidate,a.attempt/'attempt.json')
for key in old_raw:
 if same(old_raw[key],new_raw[key]):assert Path(old_raw[key]['file']).read_bytes()==Path(new_raw[key]['file']).read_bytes()
out.mkdir(parents=True);copies=out/'baseline'
old=load_bundle(baseline_file,catalog,catalog_id['sha256'],cases,['candidate'],inputs,copies)
new=load_bundle(a.candidate,catalog,catalog_id['sha256'],cases,['candidate'],inputs)
ref=load_bundle(reference_file,catalog,catalog_id['sha256'],cases,['baseline','typescript'],inputs,copies/'reference')
rows=[];timing_cases=[]
for case in cases:
 key=case['id'];left=old['points'][key]['candidate'];right=new['points'][key]['candidate']
 raw_equal=same(old_raw[case['source']['sha256']],new_raw[case['source']['sha256']])
 final_equal=same(left,right);assert raw_equal==final_equal,'Unexpected observer-only difference'
 if final_equal:assert Path(left['resolved']).read_bytes()==relative_path(a.candidate.resolve().parent,right['path']).read_bytes()
 rows.append(dict(id=key,family=case.get('family'),sourceSha256=case['source']['sha256'],point=case['point'],
  rawEqual=raw_equal,finalEqual=final_equal,adapter=case.get('adapter'),baselineRaw=old_raw[case['source']['sha256']],
  candidateRaw=new_raw[case['source']['sha256']],baseline={k:v for k,v in left.items()if k!='resolved'},candidate=right))
 ts=copy.deepcopy(ref['points'][key]['typescript']);ts['path']=str(Path(ts.pop('resolved')).relative_to(copies))
 timing_cases.append(dict(id=key,sourceSha256=case['source']['sha256'],point=case['point'],
  modules={'baseline':{k:v for k,v in left.items()if k!='resolved'},'typescript':ts}))
timing_manifest=dict(kind='bend-program-bundle',schemaVersion=1,complete=True,upstreamCommit=catalog['upstreamCommit'],
 catalogSha256=catalog_id['sha256'],comparisonContract='upstream-compatible-direct-v1',
 roles={'baseline':{**baseline['roles']['candidate'],'label':'Exact Phase56 installed String01 output; whole checked-source modules unchanged by role remap'},
 'typescript':reference['roles']['typescript']},cases=timing_cases)
save(copies/'manifest.json',timing_manifest)
changed=[r['id']for r in rows if not r['finalEqual']];unchanged=[r['id']for r in rows if r['finalEqual']]
selected_timing=[c['id']for c in cases]if a.timing_scope=='full'else changed
commands=[]
for n,start in enumerate(range(0,len(selected_timing),15)):
 commands.append(['python3',str(TOOLS/'programs/run.py'),'--catalog',str(catalog_file),'--baseline',str(copies/'manifest.json'),
  '--candidate',str(a.candidate.resolve()),'--budget','600','--cases',','.join(selected_timing[start:start+15]),
  '--cpu','3','--rss-mib','2048','--available-mib','4096','--node','/home/ai/.nvm/versions/node/v24.18.0/bin/node',
  '--out',str(out/('timing-'+str(n)))])
save(out/'timing-commands.json',dict(executed=False,timingScope=a.timing_scope,selectedIds=selected_timing,commands=commands,guard='Parent unpinned and unlocked; each unchanged programs/run.py command owns the single serial ExecutionGuard. Full45 means 3 batches/669 fresh samples under the retained ray policy.'))
normalized={}
for r in list(inputs):
 file=r.get('file',r.get('path'));actual=pin(file,r);normalized[actual['file']]=actual
report=dict(kind='phase58-performance-retention',complete=True,dataOnly=True,targetExecuted=False,
 baseline=pin(baseline_file),candidate=pin(a.candidate),baselinePublication=pin(publication_file),baselineInstalledStart=pin(installed_start_file),baselinePreservedRelease=pin(preserved_release_file),timingScope=a.timing_scope,selectedTimingIds=selected_timing,
 timingBaseline=pin(copies/'manifest.json'),inputs=list(normalized.values()),inputsUnchanged=True,
 counts=dict(points=45,sources=23,changed=len(changed),unchanged=len(unchanged),
  changedSources=len({r['sourceSha256']for r in rows if not r['finalEqual']})),
 changedIds=changed,unchangedIds=unchanged,
 changedFamilies=sorted({r['family']for r in rows if not r['finalEqual'] and r['family']}),rows=rows,
 scope='Exact checked raw and observer output comparison against the Phase56 installed String01 image. The Phase58 start receipt and retained prior release establish that baseline; no closed raw cache is written. Exact pinned TypeScript modules are reused. Changed-only mode requires fresh timing for each changed module; full mode requests all45 without mixing historical samples. This producer executes no compiler/target, proves no semantic oracle and claims no new speedup.')
save(out/'report.json',report)
print(json.dumps(dict(complete=True,dataOnly=True,counts=report['counts'],changedIds=changed,
 timingBaseline=str(copies/'manifest.json'),commands=str(out/'timing-commands.json'))))
