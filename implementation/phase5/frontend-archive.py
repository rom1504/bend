#!/usr/bin/env python3
"""Preserve a finished frontend workstream, including failed attempts. No builds."""
import gzip, hashlib, json, os, pathlib, sys, traceback
root=pathlib.Path(sys.argv[1]).resolve(); out=pathlib.Path(sys.argv[2]).resolve()
out.mkdir();(out/'objects').mkdir()
manifest={'kind':'phase5-frontend-evidence','complete':False,'newBootstrap':False,'scope':'Checked isolated source overlays and selected differential observations; failed setup/semantic attempts retained; not full conformance.','files':[],'objects':[],'external':[]}
files={};objects={}
version_file=root/'source-versions.json'
versions={}
if version_file.exists():
 for item in json.loads(version_file.read_text())['versions']:
  assert pathlib.Path(item['file']).name=='README.md', 'Historical override restricted to auxiliary README'
  versions[(item['file'],item['sha256'])]=item['saved']
def sha(b):return hashlib.sha256(b).hexdigest()
def capture(file,expected=None):
 p=pathlib.Path(file).absolute();b=p.read_bytes();h=sha(b);saved=None
 if expected is not None and h!=expected:
  saved=versions.get((str(p),expected));assert saved, 'Recorded input changed: '+str(p)
  b=pathlib.Path(saved).read_bytes();h=sha(b)
 if expected is not None:assert h==expected, 'Historical bytes differ: '+str(p)
 i={'file':str(p),'canonicalPath':str(p.resolve()),'sha256':h,'bytes':len(b)}
 if saved:i['archivedFrom']=saved;i['historicalAuxiliaryVersion']=True
 key=(str(p),h)
 if key in files:assert files[key]==i;return
 files[key]=i
 if len(b)>32*1024*1024:manifest['external'].append({**i,'reason':'Large executable identified, not embedded'});return
 if h not in objects:
  obj='objects/'+h+'.gz';z=gzip.compress(b,compresslevel=6,mtime=0);(out/obj).write_bytes(z)
  assert gzip.decompress((out/obj).read_bytes())==b
  objects[h]={'object':obj,'sha256':h,'bytes':len(b),'gzipBytes':len(z),'gzipSha256':sha(z)}
 manifest['files'].append({**i,'object':objects[h]['object']})
def records(value):
 if isinstance(value,dict):
  if isinstance(value.get('file'),str) and isinstance(value.get('sha256'),str) and len(value['sha256'])==64:
   p=pathlib.Path(value['file'])
   if p.is_absolute():capture(p,value['sha256'])
  if isinstance(value.get('inputPaths'),dict) and isinstance(value.get('inputHashes'),dict):
   for name,file in value['inputPaths'].items():
    expected=value['inputHashes'].get(name)
    if expected:capture(file,expected)
  for v in value.values():records(v)
 elif isinstance(value,list):
  for v in value:records(v)
try:
 for p in sorted(root.rglob('*')):
  if p.is_file():
   capture(p)
   if p.suffix=='.json':
    try:value=json.loads(p.read_text())
    except (UnicodeDecodeError,json.JSONDecodeError):continue
    records(value)
 repo=pathlib.Path(__file__).resolve().parents[2]
 for folder in ['phase5-bindings','phase5-scopes']:
  for p in (repo/'selfhost/tests/frontend'/folder).rglob('*'):
   if p.is_file():capture(p)
 for file in ['selfhost/tests/frontend/phase5-overlay-adapter.mjs','selfhost/tests/frontend/phase5-binding-audit.mjs']:
  capture(repo/file)
 capture(__file__)
 for i in files.values():assert str(pathlib.Path(i['file']).resolve())==i['canonicalPath'] and sha(pathlib.Path(i.get('archivedFrom',i['file'])).read_bytes())==i['sha256'], 'Input drift during archive: '+i['file']
 manifest['inputsUnchanged']=True;manifest['complete']=True
except Exception:manifest['error']=traceback.format_exc()
manifest['objects']=list(objects.values());manifest['gzipBytes']=sum(x['gzipBytes']for x in objects.values())
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(out/'README.md').write_text('# Frontend evidence archive\n\nThe manifest maps historical file paths to content-addressed gzip objects. Each object was reopened and byte-compared, with all files rehashed after archival. The archive preserves failed and successful attempts without relabeling them, checked source/API provenance and consumed fixtures/tools. Historical auxiliary README versions use explicit archivedFrom mappings to exact retained bytes; no compiler/fixture override is allowed. Large executable identities are external prerequisites. It is not a new bootstrap or proof that historical absolute paths are relocatable. See the separate focused audit and implementation report for what actually passed.\n')
print(json.dumps({k:manifest.get(k)for k in ['complete','gzipBytes','error']},indent=2));print('files',len(manifest['files']),'objects',len(objects))
if not manifest['complete']:sys.exit(1)
