import gzip,hashlib,io,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent;RUN=ROOT/'selfhost/build/phase6/boolean-branches';sha=lambda b:hashlib.sha256(b).hexdigest()
failed=json.loads((RUN/'h-gate-01/report.json').read_text());passed=json.loads((RUN/'h-core-only-02/report.json').read_text());assert not failed['complete'] and passed['complete'] and passed['inputsVerified'];assert not passed['originalGraphGatePassed']
files={p for name in ['h-gate-inputs','h-gate-01','h-core-only-02'] for p in (RUN/name).rglob('*') if p.is_file()};external=[];identities=[]
def retain(item):
 p=pathlib.Path(item['file']);assert str(p.resolve())==item['canonicalPath'] and sha(p.read_bytes())==item['sha256'];identities.append(item)
 try:p.relative_to(ROOT)
 except ValueError:external.append(item)
 else:files.add(p)
for report in [failed,passed]:
 for item in report['inputs']:retain(item)
for name in ['h-gate-01.stdout','h-gate-01.stderr','h-core-only-02.stdout','h-core-only-02.stderr']:files.add(RUN/name)
for name in ['implementation/phase6/boolean-branches.md','selfhost/tools/performance/phase6/boolean-branches-h-gate.mjs']:files.add(ROOT/name)
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
manifest={'kind':'phase6-Boolean-H-followup-evidence','archiveComplete':True,'graphGatePassed':False,'realCoreOutputGatePassed':True,'newBootstrap':False,'wholeCompilerFixedPoint':False,'archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'sourcesRechecked':True,'members':members,'external':external,'scope':'Actual Bend-generated seven-worker H capsule. Original malformed-data gate failed and remains failed; separate fully checked core-output gate passed. No H timing comparison, source/default promotion or whole-source fixed point.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:v for k,v in manifest.items() if k not in ['members','external']}))
