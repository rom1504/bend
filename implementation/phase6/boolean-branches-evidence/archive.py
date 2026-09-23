import gzip,hashlib,io,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent;RUN=ROOT/'selfhost/build/phase6/boolean-branches';sha=lambda b:hashlib.sha256(b).hexdigest()
run=json.loads((RUN/'pilot-01/report.json').read_text());prep=json.loads((RUN/'pilot-prepared/report.json').read_text());assert run['complete'] and run['material'] and run['inputsVerified'];assert len(run['rows'])==4 and all(x['passed'] for x in run['rows']);assert prep['complete'] and prep['decodedBaseEqual']
files={p for p in RUN.rglob('*') if p.is_file()};external=[];identities=[]
def retain(item):
 p=pathlib.Path(item['file']);assert str(p.resolve())==item['canonicalPath'] and sha(p.read_bytes())==item['sha256'];identities.append(item)
 try:p.relative_to(ROOT)
 except ValueError:external.append(item)
 else:files.add(p)
for item in run['inputs']:retain(item)
for row in run['rows']:
 for key in ['request','result']:retain(row[key])
 retain(row['observation']['emitted'])
for name in ['implementation/phase6/boolean-branches.md','implementation/phase6/boolean-branches-review.md','selfhost/tools/performance/phase6/boolean-branches-controls.mjs','selfhost/tools/performance/phase6/boolean-branches-compare.mjs']:
 files.add(ROOT/name)
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
for item in identities:
 p=pathlib.Path(item['file']);assert str(p.resolve())==item['canonicalPath'] and sha(p.read_bytes())==item['sha256']
manifest={'kind':'phase6-boolean-branches-evidence','complete':True,'newBootstrapForDerivative':False,'archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'sourcesRechecked':True,'members':members,'external':external,'scope':'Failed v1 preserved; v2 checked derivation,438 controls, exact core preflight and four controlled samples. Threshold met; no production/default promotion, whole-source speed claim or public-H validation.','prerequisites':'Recorded Node/Linux executables and upstream Git metadata remain external. Historical absolute paths are preserved, not rewritten into new bootstrap provenance.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:v for k,v in manifest.items() if k not in ['members','external']}))
