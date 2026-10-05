#!/usr/bin/env python3
"""Freeze array06 cost inputs and a narrowly relabeled runner; execute no targets."""
import argparse, ast, copy, hashlib, json
from pathlib import Path

HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[3]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--out',type=Path,required=True)
p.add_argument('--cases',default='test-rle-roundtrip,lexer')
a=p.parse_args();out=a.out.resolve();assert not out.exists()
assert out.is_relative_to(ROOT/'selfhost/build/phase48')
pins={}
def pin(file,want=None):
 file=Path(file).resolve(strict=True);digest=hashlib.sha256()
 with file.open('rb') as stream:
  for block in iter(lambda:stream.read(2**20),b''):digest.update(block)
 row=dict(file=str(file),sha256=digest.hexdigest(),bytes=file.stat().st_size)
 if want:
  for k in ['sha256','bytes']:
   if k in want:assert row[k]==want[k],str(file)
 if str(file) in pins:assert row==pins[str(file)],str(file)
 pins[str(file)]=row;return row
def read(file):pin(file);return json.loads(Path(file).read_text())
def write(file,value):
 file.parent.mkdir(parents=True,exist_ok=True)
 with file.open('x') as stream:json.dump(value,stream,indent=2);stream.write('\n')
def retain(source,target,want=None):
 target=Path(target);row=pin(source,want);target.parent.mkdir(parents=True,exist_ok=True)
 with target.open('xb') as stream:stream.write(Path(row['file']).read_bytes())
 assert pin(target)['sha256']==row['sha256'];return row
pin(__file__)
catalogFile=HERE.parent/'phase37/catalog.json';catalog=read(catalogFile)
ids=a.cases.split(',');assert len(ids) in [2,3] and len(ids)==len(set(ids))
cases=[next(c for c in catalog['cases'] if c['id']==i) for i in ids]
assert all(not c.get('adapter') for c in cases)
source=ROOT/'selfhost/build/phase47/array06-full/manifest.json';manifest=read(source)
assert manifest['complete'] and set(manifest['roles'])=={'candidate'}
assert manifest['catalogSha256']==pin(catalogFile)['sha256']
compiler=manifest['roles']['candidate']['compiler']
assert compiler['api']['sha256']=='28f9eb983b2ba3603a9af703d832d4a301efe32182b468e090db6b728a47d12f'
assert compiler['runtime']['sha256']=='880bce50e3194b9ee9d99bd57c18ef88bcb8925d9d1668dec6765040a4d3219b'
for key in ['api','runtime','base','driver']:pin(compiler[key]['file'],compiler[key])
planner=ROOT/'selfhost/build/phase47/compiler-cost-final-producer01/planner.py'
pin(planner,{'sha256':'57e85b5b8170ecb30039eee6a8b1b8414a75ff726f9bb9aa7744e0c314798142'})
runner=HERE.parent/'phase47/compiler-cost-run.py'
pin(runner,{'sha256':'557a6600f25d1bf63f5c1ee973458f3bfc345bdd9afae0fa57ce735d283f2ca4'})
text=runner.read_text();changes=[
 ("HERE=Path(__file__).resolve().parent;PROGRAMS=HERE.parent/'programs'",f"HERE=Path({str(runner.parent)!r});PROGRAMS=HERE.parent/'programs'"),
 ('e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c',compiler['api']['sha256']),
 ('4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26',compiler['runtime']['sha256']),
 ('"""Phase47 serial cost screen; exact historical worker/timing, 4GiB headroom."""','"""Phase48 array06 comparison; unchanged Phase47 worker, timing and bounds."""'),
 ("kind='phase47-normal-checked-library-cost'","kind='phase48-normal-checked-library-cost'"),
 ('Worker23 versus selected Phase47 checked candidate','Array06 versus selected Phase48 checked candidate'),
 ("identity(HERE.parent/'phase35/compiler-cost-run.py')","identity(HERE/'compiler-cost-run.py')")]
for old,new in changes:
 expected=2 if old=="identity(HERE.parent/'phase35/compiler-cost-run.py')" else 1
 assert text.count(old)==expected,old;text=text.replace(old,new)
ast.parse(text);out.mkdir(parents=True);(out/'baseline').mkdir()
retain(source,out/'baseline/original-manifest.json')
prep=manifest['preparation'];assert prep['path']=='preparation.json'
retain(source.parent/prep['path'],out/'baseline'/prep['path'],prep)
baseline=copy.deepcopy(manifest);baseline['roles']={'baseline':copy.deepcopy(manifest['roles']['candidate'])}
baseline['roles']['baseline']['label']='Phase47 array06 checked acquisition reused as baseline; no new compilation'
baseline['cases']=[]
for c in cases:
 row=copy.deepcopy(next(r for r in manifest['cases'] if r['id']==c['id']))
 assert row['sourceSha256']==c['source']['sha256'] and row['point']==c['point']
 module=row['modules']['candidate'];relative=Path(module['path'])
 assert not relative.is_absolute() and '..' not in relative.parts
 target=out/'baseline'/relative
 if not target.exists():
  retain(source.parent/relative,target,module)
  receipt=read(str(source.parent/relative)+'.json')
  assert receipt['complete'] and receipt['observation']['checked'] and receipt['compiler']==compiler
  assert receipt['output']['sha256']==module['sha256'] and receipt['input']['sha256']==c['source']['sha256']
  retain(str(source.parent/relative)+'.json',str(target)+'.json')
 row['modules']={'baseline':module};baseline['cases'].append(row)
write(out/'baseline/manifest.json',baseline)
retain(planner,out/'planner.py');retain(runner,out/'runner-parent.py')
with (out/'runner.py').open('x') as stream:stream.write(text)
for row in list(pins.values()):pin(row['file'],row)
write(out/'derivation.json',dict(kind='phase48-compiler-cost-method',complete=True,executed=False,
 cases=ids,inputs=list(pins.values()),runner=pin(out/'runner.py'),manifest=pin(out/'baseline/manifest.json'),
 changes=changes,scope='Byte-preserved old acquisition and planner. Runner changes only dependency anchor, exact baseline pins, labels and immediate parent identity. Phase30 worker, samples, checks, timing boundaries and resource bounds unchanged.'))
print(json.dumps(dict(complete=True,executed=False,out=str(out),cases=ids)))
