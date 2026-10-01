#!/usr/bin/env python3
"""Freeze normal checked-library cost inputs; run only read-only attempt verification."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys
import time
import tarfile

HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[3];PROGRAMS=HERE.parent/'programs'
PARENT=HERE.parent/'phase37/compiler-cost-plan.py'
assert hashlib.sha256(PARENT.read_bytes()).hexdigest()=='ad23d89730293ed97a8e39f9603255fe9d04d10822cd47d670b30fa0dcc51e04'
sys.path.insert(0,str(PROGRAMS))
from support import ExecutionGuard,identity,save
from run import load_bundle,relative_path,require
ap=argparse.ArgumentParser(description=__doc__)
ap.add_argument('attempt',type=Path);ap.add_argument('candidate_preparation',type=Path);ap.add_argument('out',type=Path)
ap.add_argument('--baseline-preparation',type=Path,required=True)
ap.add_argument('--baseline-attempt',type=Path,required=True)
ap.add_argument('--typescript-preparation',type=Path)
ap.add_argument('--cases',default='local-pair,tree-bitonic,coverage-numeric-recurrence-1024')
ap.add_argument('--catalog',type=Path,default=HERE.parent/'phase37/catalog.json')
a=ap.parse_args();attempt=a.attempt.resolve();candidate=a.candidate_preparation.resolve();out=a.out.resolve()
assert not out.exists();out.mkdir(parents=True);(out/'consumed').mkdir()
node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node');baseline=a.baseline_attempt.resolve()
worker=HERE.parent/'phase30/library-cost-worker.mjs'
assert hashlib.sha256(worker.read_bytes()).hexdigest()=='f0dea569bdb02df60ed1156b0cead389e197291f1c3a3c6775102c7a03790f42'
shutil.copyfile(worker,out/'worker.mjs')
def old_identity(file):
 file=Path(file).resolve();h=hashlib.sha256()
 with file.open('rb') as stream:
  for part in iter(lambda:stream.read(2**20),b''):h.update(part)
 return dict(file=str(file),canonicalPath=str(file.resolve()),sha256=h.hexdigest())
tracked=[];catalogfile=a.catalog.resolve();catalog=json.loads(catalogfile.read_text());ids=a.cases.split(',')
assert ids and len(set(ids))==len(ids) and set(ids)<={c['id'] for c in catalog['cases']}
cases=[next(c for c in catalog['cases'] if c['id']==name) for name in ids]
assert all(not c.get('adapter') for c in cases), 'Normal emission cost needs unadapted output'
report=dict(kind='phase39-normal-library-cost-preparation',complete=False,executed=False,cases=ids,inputs=[],bindings=[],
 derivation=dict(parent=old_identity(HERE.parent/'phase37/compiler-cost-plan.py'),
 changes='Uses the Phase39 retained checked03 bundle, verifies original candidate-role acquisition and checked receipts before treating it as the new baseline, and separately follows the nested pinned-TypeScript archive. Worker, bindings, runner, samples and timing boundaries are unchanged.'),retainedLineage=[])
save(out/'preparation.json',report)
archive_members={};retained={}
def archive_copy(archive,name,label,expected=None):
 # Copy only explicitly requested regular members. Validate the entire name,
 # duplication and expansion envelope, even for members we do not consume.
 archive=Path(archive).resolve();key=str(archive)
 if key not in archive_members:
  sizes={};total=0
  with tarfile.open(archive,'r:gz') as stream:
   members=stream.getmembers();require(len(members)<=10000,'Too many archive members')
   for m in members:
    relative_path(out/'retained',m.name)
    require(m.isfile() and m.name not in sizes,'Unsafe or duplicate archive member')
    total+=m.size;require(0<=m.size<=64*1024**2 and total<=512*1024**2,'Archive expansion exceeds bound')
    sizes[m.name]=m.size
  archive_members[key]=sizes;tracked.append(identity(archive))
 require(name in archive_members[key],'Missing retained member: '+name)
 target=relative_path(out/'retained'/label,name)
 if not target.exists():
  with tarfile.open(archive,'r:gz') as stream:data=stream.extractfile(name).read()
  require(len(data)==archive_members[key][name],'Retained member size changed')
  target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
 if expected:
  got=identity(target);require(got['sha256']==expected['sha256'],'Retained identity mismatch: '+name)
  if 'bytes' in expected:require(got['bytes']==expected['bytes'],'Retained bytes mismatch: '+name)
 tracked.append(identity(target));return target

def retained_origin(file,role):
 key=(str(file),role)
 if key in retained:return retained[key]
 bundle=json.loads(file.read_text());archive=relative_path(file.parent,bundle['archive']['path'])
 got=identity(archive);require(got['sha256']==bundle['archive']['sha256'] and got['bytes']==bundle['archive']['bytes'],'Changed retained archive')
 provenance_file=archive_copy(archive,'provenance.json','outer',bundle['provenance'])
 provenance=json.loads(provenance_file.read_text())
 require(provenance['complete'] and provenance['kind']=='phase39-retained-checked-reference','Unexpected retained provenance')
 require(provenance['baselineApi']==bundle['roles']['baseline']['compiler']['api']['sha256'],'Wrong retained baseline API')
 if role=='baseline':
  original_role='candidate';prefix='acquisition/current/';label='outer';origin_archive=archive
 else:
  require(role=='typescript','Unsupported archived role')
  reference_file=archive_copy(archive,'acquisition/reference/manifest.json','outer')
  reference=json.loads(reference_file.read_text())
  require(reference['complete'] and reference['catalogSha256']==bundle['catalogSha256'],'Wrong historical reference')
  require(reference['roles']['typescript']['compiler']==bundle['roles']['typescript']['compiler'],'Wrong historical TypeScript identity')
  origin_archive=archive_copy(archive,'acquisition/reference/'+reference['archive']['path'],'outer',reference['archive'])
  reference_provenance=archive_copy(archive,'acquisition/reference/'+reference['provenance']['path'],'outer',reference['provenance'])
  inner_provenance=archive_copy(origin_archive,'provenance.json','reference',reference['provenance'])
  require(inner_provenance.read_bytes()==reference_provenance.read_bytes(),'Nested provenance differs')
  original_role='typescript';prefix='typescript/';label='reference'
 manifest_file=archive_copy(origin_archive,prefix+'manifest.json',label)
 original=json.loads(manifest_file.read_text())
 require(original['complete'] and set(original['roles'])=={original_role},'Wrong original acquisition roles')
 require(original['catalogSha256']==bundle['catalogSha256'] and original['upstreamCommit']==bundle['upstreamCommit'],'Wrong original acquisition target')
 require(original['roles'][original_role]['compiler']==bundle['roles'][role]['compiler'],'Relabeled role has different compiler')
 preparation_file=archive_copy(origin_archive,prefix+original['preparation']['path'],label,original['preparation'])
 preparation=json.loads(preparation_file.read_text())
 require(preparation['complete'] and preparation['kind']=='bend-program-preparation','Incomplete original checked acquisition')
 require(preparation['catalog']['sha256']==bundle['catalogSha256'],'Wrong original preparation catalog')
 origin=dict(originalRole=original_role,manifest=original,preparation=preparation,archive=origin_archive,prefix=prefix,label=label)
 report['retainedLineage'].append(dict(role=role,originalRole=original_role,
  bundle=old_identity(file),manifest=old_identity(manifest_file),preparation=old_identity(preparation_file),
  scope='Original role names and original receipt content are preserved; baseline maps only to retained checked03 candidate, never to the nested older baseline.'))
 retained[key]=origin;return origin

def retained_receipt(file,role,case,expected,binding):
 origin=retained_origin(file,role);original_role=origin['originalRole'];original=origin['manifest']
 rows=[r for r in original['cases'] if r['id']==case['id']];require(len(rows)==1,'Missing original point')
 row=rows[0];require(row['sourceSha256']==case['source']['sha256'] and row['point']==case['point'],'Changed original point')
 module=row['modules'][original_role];require(module['sha256']==expected['sha256'],'Relabeled output differs from original emission')
 sources=[r for r in origin['preparation']['sources'] if r['source']['sha256']==case['source']['sha256']]
 require(len(sources)==1 and sources[0]['process']['complete'],'Missing original successful source acquisition')
 receipt_entry=sources[0]['emission'];require(receipt_entry['path']==module['path']+'.json','Wrong original receipt path')
 receipt_file=archive_copy(origin['archive'],origin['prefix']+receipt_entry['path'],origin['label'],receipt_entry)
 receipt=json.loads(receipt_file.read_text())
 require(receipt['kind']=='bend-program-checked-emission' and receipt['complete'] and receipt['observation']['checked'],'Unchecked original emission')
 require(receipt['input']['sha256']==case['source']['sha256'] and receipt['output']['sha256']==expected['sha256'],'Original receipt identity differs')
 require(receipt['catalog']['sha256']==identity(catalogfile)['sha256'],'Wrong original receipt catalog')
 observed=receipt['compiler'];require(observed==original['roles'][original_role]['compiler'],'Original receipt compiler differs')
 if role=='baseline':
  require(receipt['attempt']['sha256']==binding['manifest']['sha256'],'Original baseline receipt is from a different checked attempt')
  for k in ['api','runtime','base','driver']:
   require(observed[k]['sha256']==binding[k]['sha256'],'Original baseline '+k+' differs from verified attempt')
 else:
  require(observed['kind']=='checked-pinned-typescript' and observed['upstreamCommit']==catalog['upstreamCommit'],'Wrong original TypeScript pin')
  for recorded in observed['sources']:
   live=Path(binding['upstream'])/'bend2'/Path(recorded['file']).name
   require(old_identity(live)['sha256']==recorded['sha256'],'Changed pinned TypeScript source')
 return old_identity(receipt_file)

try:
 with ExecutionGuard(rss_mib=2048,available_mib=2048) as guard:
  bindings={}
  for role,image in [('baseline',baseline),('candidate',attempt)]:
   target=out/(role+'-bindings.json')
   proc=guard.run(['taskset','-c','3',str(node),'--stack-size=4096','--max-old-space-size=1024',str(HERE.parent/'phase35/compiler-cost-bindings.mjs'),str(image),str(target)],out/('verify-'+role),time.monotonic()+120)
   report['bindings'].append(dict(role=role,process=proc));save(out/'preparation.json',report)
   require(proc['complete'],'Attempt/cache verification failed: '+role)
   bindings[role]=json.loads(target.read_text());require(bindings[role]['complete'],'Incomplete binding')
  bindings['typescript']={**bindings['baseline'],'cache':None}
  for role,v in bindings.items():v['typescript']=role=='typescript'
  require(bindings['baseline']['base']['sha256']==bindings['candidate']['base']['sha256'],'Different Base sources')
  require(bindings['baseline']['upstream']==bindings['candidate']['upstream'],'Different upstream checkouts')
  reference=HERE/'baseline/manifest.json'
  sources={'candidate':candidate,'baseline':a.baseline_preparation.resolve() if a.baseline_preparation else reference,
           'typescript':a.typescript_preparation.resolve() if a.typescript_preparation else reference}
  bundles={};by_source={}
  for role,file in sources.items():
   key=str(file)
   if key not in by_source:
    roles=list(json.loads(file.read_text())['roles'])
    require(set(roles)<=set(['baseline','typescript','candidate']),'Unexpected prepared roles')
    by_source[key]=load_bundle(file,catalog,identity(catalogfile)['sha256'],cases,roles,tracked,out/('bundle-'+role))
   bundles[role]=by_source[key]
   compiler=json.loads(file.read_text())['roles'][role]['compiler']
   require(compiler['upstreamCommit']==catalog['upstreamCommit'],'Wrong upstream pin')
   if role!='typescript':
    for k in ['api','runtime','base','driver']:
     require(compiler[k]['sha256']==bindings[role][k]['sha256'],'Wrong '+role+' '+k+' identity')
  output_cases=[]
  for case in cases:
   source=(catalogfile.parent/case['source']['path']).resolve();require(identity(source)['sha256']==case['source']['sha256'],'Changed source')
   expected={};receipts={}
   for role,bundle in bundles.items():
    entry=bundle['points'][case['id']][role];module=Path(entry['resolved']);expected[role]=old_identity(module)
    # New prepare.py receipts differ from the historical Phase26 format. Bind
    # their checked observation, source, output, final API and attempt explicitly.
    manifest=json.loads(sources[role].read_text())
    if 'archive' not in manifest:
     original=relative_path(sources[role].parent,entry['path']);receipt_file=Path(str(original)+'.json')
     receipt=json.loads(receipt_file.read_text())
     require(receipt['complete'] and receipt['observation']['checked'],'Unchecked emission')
     require(receipt['input']['sha256']==case['source']['sha256'] and receipt['output']['sha256']==expected[role]['sha256'],'Emission identity mismatch')
     observed=receipt.get('compiler',receipt)
     require(observed==manifest['roles'][role]['compiler'],'Prepared receipt compiler differs from role')
     require(receipt['catalog']['sha256']==identity(catalogfile)['sha256'],'Prepared receipt uses different catalog')
     if role=='typescript':
      require(observed['upstreamCommit']==catalog['upstreamCommit'],'Wrong TypeScript emission pin')
     else:
      require(receipt['attempt']['sha256']==bindings[role]['manifest']['sha256'],'Wrong emission attempt')
      require(observed['api']['sha256']==bindings[role]['api']['sha256'],'Wrong emission API')
     receipts[role]=old_identity(receipt_file);tracked.append(identity(receipt_file))
    else:
     require(sources[role]==reference and role in ['baseline','typescript'],'Unsupported retained archive')
     receipts[role]=retained_receipt(sources[role],role,case,expected[role],bindings[role])
   output_cases.append(dict(id=case['id'],source=old_identity(source),expected=expected,receipts=receipts))
  files=[Path(__file__),HERE.parent/'phase35/compiler-cost-bindings.mjs',HERE.parent/'phase35/compiler-cost-run.py',worker,out/'worker.mjs',node,catalogfile,
      PROGRAMS/'run.py',PROGRAMS/'support.py',ROOT/'design/phase39/countdown.md',HERE.parent/'phase37/compiler-cost-plan.py',HERE/'freeze-baseline.py',*sources.values(),*[Path(x['source']['file']) for x in output_cases]]
  files += [Path(x['file']) for v in bindings.values() for x in v['inputs']]
  files += [Path(x.get('path',x.get('file'))) for x in tracked]
  files += [Path(e['file']) for c in output_cases for e in c['expected'].values()]
  upstream=Path(bindings['typescript']['upstream'])/'bend2'
  files += [p for p in upstream.rglob('*') if p.is_file() and p.suffix in ['.ts','.bend','.mjs','.js']]
  inputs=[old_identity(p) for p in dict.fromkeys(files)]
  config=dict(kind='phase35-normal-checked-library-cost-plan',complete=True,cpu='3',samples=3,timeoutMs=180000,
      heapMiB=1024,rssMiB=2048,availableMiB=2048,node=old_identity(node),worker=old_identity(out/'worker.mjs'),
      variants=bindings,cases=output_cases,order=['typescript','baseline','candidate'],inputs=inputs,
      derivation=report['derivation'],retainedLineage=report['retainedLineage'],
      scope='Unchanged Phase30 checked-library worker. Fresh rotated3 CPU3 processes; normal inspect/Base pipeline against explicit retained Phase37 checked03 attempt, versus TS book_load/valid/js_lib. Exact independently acquired output required; host import/request/process boundaries separate.')
  for item in inputs:require(old_identity(item['file'])==item,'Input changed during planning')
  save(out/'config.json',config)
  for p in [Path(__file__),HERE.parent/'phase35/compiler-cost-bindings.mjs',HERE.parent/'phase35/compiler-cost-run.py',worker]:shutil.copyfile(p,out/'consumed'/p.name)
  report['inputs']=inputs;report['complete']=True
except Exception as error:
 report['error']=repr(error);raise
finally:save(out/'preparation.json',report)
print(json.dumps(dict(complete=True,executed=False,config=str(out/'config.json'),cases=ids,workerSha256=config['worker']['sha256'])))
