"""Data-only raw-generic-to-fixed2 runtime trial; preserve exact compiler/API/QBE evidence."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
HELPERS={
 'old':'a7728974516c3aa8da194082b1608b5cdc3d290ee1ea6e0b45f4dd940ecea4b9',
 'new':'8d317bc318721fb6fe3f99fd89ffbd8ab21866c785432c790885d01bbd92cecd'}
def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p):assert pin(p['file'])==p,'Changed input: '+p['file']
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--emission',type=Path,required=True)
p.add_argument('--old-runtime',type=Path,required=True)
p.add_argument('--new-runtime',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126') and out.parent.is_dir()
emission=read(a.emission);assert emission['complete'] and 'runtimeRebind' not in emission
old_file=HERE/'manifest04.json';new_file=HERE/'manifest06.json'
old_authority=read(old_file);new_authority=read(new_file)
assert old_authority['modules']==new_authority['modules'] and old_authority['overrides']==new_authority['overrides']
verify(new_authority['compilerIdentity']);source_manifest=read(new_authority['compilerIdentity']['file'])
assert source_manifest['complete'] and emission['source']==source_manifest['source']
for x in [*emission['inputs'],emission['api'],emission['source']]:verify(x)
api_receipt_file=Path(emission['api']['file']).parent/'report.json';api_receipt=read(api_receipt_file)
assert api_receipt['complete'] and api_receipt['checked'] and api_receipt['api']==emission['api']
assert emission['source'] in api_receipt['inputs'] and pin(api_receipt_file) in emission['inputs']
for x in api_receipt['inputs']:verify(x)
base_file=ROOT/'selfhost/build/phase125/runtime-verified01/report.json';base=read(base_file)
assert base['complete'] and base['kind']=='phase125-additive-runtime'
for x in [*base['inputs'],base['source'],base['object']]:verify(x)
runtimes={};runtime_paths={'old':a.old_runtime,'new':a.new_runtime};authorities={'old':old_authority,'new':new_authority}
for role in ['old','new']:
 r=read(runtime_paths[role]);authority=authorities[role]
 assert r['complete'] and r['status']==0 and r['kind']=='phase126-local-reshape-additive-runtime'
 assert r['parent']==base['object'] and r['extension']==authority['runtime'] and r['extension']['sha256']==HELPERS[role]
 assert pin(old_file if role=='old' else new_file) in r['inputs']
 for x in [*r['inputs'],r['source'],r['object']]:verify(x)
 assert r['command'][0:5]==base['command'][0:5] and len(r['command'])==8
 assert r['command'][5]==r['source']['file'] and r['command'][6]=='-o' and r['command'][7]==r['object']['file']
 assert Path(r['source']['file']).read_bytes()==Path(base['source']['file']).read_bytes()+b'\n'+Path(r['extension']['file']).read_bytes(),'Unreviewed runtime source change'
 for name in ['runtime.h','primitives.h']:
  header=Path(r['source']['file']).parent/name;expected=Path(base['source']['file']).parent/name
  assert header.read_bytes()==expected.read_bytes(),'Header change: '+name
 runtimes[role]=r
assert emission['runtime']==runtimes['old']['object']
assert pin(a.old_runtime) in emission['inputs'],'Original emission lacks full old runtime report'
for row in emission['cases']:
 assert row['verified'] and row['parentVerified'];verify(row['source']);verify(row['qbe'])
result=copy.deepcopy(emission);result['runtime']=runtimes['new']['object']
appended=[pin(__file__),pin(a.emission),pin(a.old_runtime),pin(a.new_runtime),pin(old_file),pin(new_file),new_authority['compilerIdentity'],pin(base_file),*runtimes['old']['inputs'],runtimes['old']['source'],runtimes['old']['object'],*runtimes['new']['inputs'],runtimes['new']['source'],runtimes['new']['object']]
for role in ['old','new']:
 for name in ['runtime.h','primitives.h']:appended.append(pin(Path(runtimes[role]['source']['file']).parent/name))
for x in appended:verify(x)
result['inputs']=emission['inputs']+appended
result['runtimeRebind']=dict(parentEmission=pin(a.emission),oldRuntimeReport=pin(a.old_runtime),newRuntimeReport=pin(a.new_runtime),oldAuthority=pin(old_file),newAuthority=pin(new_file),compilerSource=emission['source'],api=emission['api'],unchangedQbe=[row['qbe'] for row in emission['cases']],targetsRun=False,
 scope='Exact compiler24/API/source/QBE and original verifier results reused. Only the reviewed p126_rt_transpose2 runtime implementation changes from generic outer construction to the existing exact fixed-arity-two outer constructor; ownership acceptance is unchanged; exact ABI, qualified Phase125 base, headers, native compiler and flags unchanged. This data-only rebind does not qualify the new runtime or rerun semantic/timing tests.')
assert {k:v for k,v in result.items() if k not in ['runtime','inputs','runtimeRebind']}=={k:v for k,v in emission.items() if k not in ['runtime','inputs']}
out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,emission=pin(out),runtime=result['runtime'])))
