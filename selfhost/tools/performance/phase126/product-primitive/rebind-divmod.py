"""Data-only binding of checked Nat.divmod candidate emissions to its pinned additive runtime."""
import argparse, copy, hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).resolve().parent
def read(p): return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p): assert pin(p['file'])==p,'Changed input: '+p['file']
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--emission',type=Path,required=True)
p.add_argument('--runtime',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase126') and out.parent.is_dir()
e=read(a.emission);assert e['complete'] and 'runtimeRebind' not in e
authority_file=HERE/'divmod-manifest01.json';authority=read(authority_file)
base_file=ROOT/'selfhost/build/phase125/runtime-verified01/report.json';base=read(base_file)
assert base['complete'] and base['kind']=='phase125-additive-runtime'
r=read(a.runtime)
assert r['complete'] and r['status']==0 and r['kind']=='phase126-nat-divmod-additive-runtime'
assert r['parent']==base['object'] and r['extension']==authority['runtime']
assert pin(authority_file) in r['inputs']
for x in [*base['inputs'],base['source'],base['object'],*r['inputs'],r['source'],r['object'],*e['inputs'],e['api'],e['source']]:verify(x)
assert r['command'][:5]==base['command'][:5] and len(r['command'])==8
assert r['command'][5]==r['source']['file'] and r['command'][6]=='-o' and r['command'][7]==r['object']['file']
assert Path(r['source']['file']).read_bytes()==Path(base['source']['file']).read_bytes()+b'\n'+Path(authority['runtime']['file']).read_bytes()
for name in ['runtime.h','primitives.h']:
 assert (Path(r['source']['file']).parent/name).read_bytes()==(Path(base['source']['file']).parent/name).read_bytes()
assert e['runtime']==base['object']
api_report_file=Path(e['api']['file']).parent/'report.json';api=read(api_report_file)
assert api['complete'] and api['checked'] and api['api']==e['api']
assert e['source'] in api['inputs'] and pin(api_report_file) in e['inputs']
for x in api['inputs']:verify(x)
# Establish exact authority ancestry, allowing later composition overlays.
assert pin(authority_file) in e['inputs'] or pin(authority_file) in api['inputs'],'Missing reviewed helper authority'
for row in e['cases']:
 assert row['verified'] and row['parentVerified'];verify(row['source']);verify(row['qbe'])
result=copy.deepcopy(e);result['runtime']=r['object']
extra=[pin(__file__),pin(a.emission),pin(a.runtime),pin(authority_file),pin(base_file),*r['inputs'],r['source'],r['object']]
for name in ['runtime.h','primitives.h']:extra.append(pin(Path(r['source']['file']).parent/name))
for x in extra:verify(x)
result['inputs']=e['inputs']+extra
result['runtimeRebind']=dict(parentEmission=pin(a.emission),oldRuntimeReport=pin(base_file),newRuntimeReport=pin(a.runtime),authority=pin(authority_file),compilerSource=e['source'],api=e['api'],unchangedQbe=[row['qbe'] for row in e['cases']],targetsRun=False,scope='Exact checked source/API/QBE and verifier results retained. Add only reviewed full-width Nat.divmod two-output helper to exact qualified Phase125 runtime; existing runtime, headers, compiler and flags unchanged. Rebinding is not runtime qualification.')
assert {k:v for k,v in result.items() if k not in ['runtime','inputs','runtimeRebind']}=={k:v for k,v in e.items() if k not in ['runtime','inputs']}
out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,emission=pin(out),runtime=result['runtime'])))
