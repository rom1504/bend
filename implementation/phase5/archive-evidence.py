#!/usr/bin/env python3
"""Capture completed experiment directories and hash-identified consumed inputs.

Usage: archive-evidence.py NEW_ARCHIVE FINISHED_DIRECTORY [...]
Historical byte versions may be recovered from existing Phase 5 gzip archives.
This is a records archive, not a new compiler build or relocatable replay claim.
"""
import gzip, hashlib, json, pathlib, sys, traceback
out=pathlib.Path(sys.argv[1]).resolve()
roots=[pathlib.Path(x).resolve() for x in sys.argv[2:]]
assert roots and not out.exists()
out.mkdir(); (out/'objects').mkdir()
repo=pathlib.Path(__file__).resolve().parents[2]
known={}
for p in (repo/'implementation/phase5').glob('*/objects/*.gz'):
 known[p.stem]=p
manifest={'kind':'phase5-consumed-evidence','complete':False,'newBootstrap':False,
 'scope':'Finished attempts, raw failures and exact consumed input versions. Absolute paths are historical identities; executable/toolchain prerequisites remain external.',
 'roots':list(map(str,roots)),'files':[],'external':[],'objects':[]}
files={}; objects={}
def sha(b):return hashlib.sha256(b).hexdigest()
def capture(file,expected=None):
 p=pathlib.Path(file).absolute()
 if expected and (str(p),expected) in files:return
 b=p.read_bytes() if p.is_file() else None; source=None
 if expected and (b is None or sha(b)!=expected):
  source=known.get(expected)
  assert source, 'Missing historical bytes: '+str(p)+' '+expected
  b=gzip.decompress(source.read_bytes())
 assert b is not None, 'Missing file: '+str(p)
 h=sha(b)
 if expected:assert expected==h
 key=(str(p),h)
 if key in files:return
 row={'file':str(p),'sha256':h,'bytes':len(b)}
 if source:row['historicalBytesFrom']=str(source)
 files[key]=row
 if len(b)>32*1024*1024:
  manifest['external'].append({**row,'reason':'Large executable prerequisite identified, not embedded'});return
 if h not in objects:
  name='objects/'+h+'.gz';z=gzip.compress(b,compresslevel=6,mtime=0)
  (out/name).write_bytes(z);assert sha(gzip.decompress((out/name).read_bytes()))==h
  objects[h]={'object':name,'sha256':h,'bytes':len(b),'gzipBytes':len(z),'gzipSha256':sha(z)}
 manifest['files'].append({**row,'object':objects[h]['object']})
def records(v):
 if isinstance(v,dict):
  for field in ['file','path','canonicalPath']:
   if isinstance(v.get(field),str) and pathlib.Path(v[field]).is_absolute() and isinstance(v.get('sha256'),str) and len(v['sha256'])==64:
    capture(v[field],v['sha256']);break
  if isinstance(v.get('inputHashes'),dict):
   for file,expected in v['inputHashes'].items():
    if expected:capture(v.get('inputPaths',{}).get(file) or file,expected)
  if isinstance(v.get('adapterSha256'),str):
   pass # adapter path is held by report options; handled below
  if isinstance(v.get('options'),dict) and isinstance(v.get('identity'),dict):
   if v['identity'].get('adapterSha256'):capture(v['options']['adapter'],v['identity']['adapterSha256'])
  for x in v.values():records(x)
 elif isinstance(v,list):
  for x in v:records(x)
try:
 for root in roots:
  for p in sorted(root.rglob('*')) if root.is_dir() else [root]:
   if not p.is_file():continue
   capture(p)
   if p.suffix=='.json':
    try:v=json.loads(p.read_text())
    except (UnicodeDecodeError,json.JSONDecodeError):continue
    records(v)
 capture(__file__)
 capture('/home/ai/.nvm/versions/node/v24.18.0/bin/node')
 manifest['complete']=True
except Exception:manifest['error']=traceback.format_exc()
manifest['objects']=list(objects.values());manifest['gzipBytes']=sum(x['gzipBytes']for x in objects.values())
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(out/'README.md').write_text('# Consumed evidence archive\n\nManifest file rows map historical paths and SHA-256 identities to gzip objects. Every stored object was reopened and hash-verified. Historical versions recovered from another archive are explicitly identified. Reports retain their original outcomes; this archive supplies neither a new bootstrap nor a relocated replay proof. Large executables are external prerequisites.\n')
print(json.dumps({k:manifest.get(k) for k in ['complete','gzipBytes','error']}));print('files',len(manifest['files']),'objects',len(objects))
if not manifest['complete']:sys.exit(1)
