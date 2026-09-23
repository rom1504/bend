import gzip,hashlib,io,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent;RUN=ROOT/'selfhost/build/phase6/campaign/import-phase';sha=lambda b:hashlib.sha256(b).hexdigest()
files={p for p in RUN.rglob('*') if p.is_file()};external=[];identities=[]
def gather(value):
 if isinstance(value,dict):
  if all(k in value for k in ['file','canonicalPath','sha256']):
   p=pathlib.Path(value['file']);assert str(p.resolve())==value['canonicalPath'] and sha(p.read_bytes())==value['sha256'];identities.append(value)
   try:p.relative_to(ROOT)
   except ValueError:external.append(value)
   else:files.add(p)
  for v in value.values():gather(v)
 elif isinstance(value,list):
  for v in value:gather(v)
gather(json.loads((RUN/'attempt-01/attempt.json').read_text()))
for name in ['experiments/phase6/P6-011-declared-import-phase.md','implementation/phase6/import-phase.md','implementation/phase6/import-phase-candidate.patch','implementation/phase6/import-phase-independent-review.md','selfhost/tools/performance/phase6/import-phase-controls.mjs','selfhost/build/phase5/integration/attempt-05/validation-001/frontend.json']:files.add(ROOT/name)
files.add(pathlib.Path(__file__).resolve());archive=OUT/'raw.tar.gz';members=[]
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0,filename='') as gz:
 with tarfile.open(fileobj=gz,mode='w|') as tar:
  for p in sorted(files):
   data=p.read_bytes();name=str(p.relative_to(ROOT));info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644;tar.addfile(info,io.BytesIO(data));members.append({'path':name,'bytes':len(data),'sha256':sha(data)})
index={x['path']:x for x in members}
with tarfile.open(archive,'r:gz') as tar:
 actual=tar.getmembers();assert len(actual)==len(index)
 for item in actual:
  assert item.isfile() and not pathlib.PurePosixPath(item.name).is_absolute() and '..' not in pathlib.PurePosixPath(item.name).parts
  data=tar.extractfile(item).read();assert index[item.name]=={'path':item.name,'bytes':len(data),'sha256':sha(data)}
for item in members:assert sha((ROOT/item['path']).read_bytes())==item['sha256']
manifest={'kind':'phase6-import-phase-evidence','preservationComplete':True,'archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'sourcesRechecked':True,'members':members,'external':external,'scope':'Isolated host phase fix; ten phase repairs with all five strict diagnostic failures retained. Eight host groups, two actual preflights and25neighbor observations. No promotion or speed claim.','prerequisites':'Recorded Node/Linux executables and upstream Git metadata external. Original absolute paths retained; no provenance rewriting.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:v for k,v in manifest.items() if k not in ['members','external']}))
