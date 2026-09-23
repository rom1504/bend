import gzip,hashlib,io,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent;RUN=ROOT/'selfhost/build/phase5/default-release';sha=lambda x:hashlib.sha256(x).hexdigest()
files={p for p in RUN.rglob('*') if p.is_file()};release=json.loads((ROOT/'selfhost/dist/release.json').read_text())
for item in release['files']+release['checkout']:
 p=ROOT/'selfhost'/item['path'];assert sha(p.read_bytes())==item['sha256'];files.add(p)
for p in (ROOT/'selfhost/dist/release-history').rglob('*'):
 if p.is_file():files.add(p)
for name in ['selfhost/dist/release.json','selfhost/package.json','selfhost/tools/development/release.mjs','implementation/phase5/consolidated-release.md']:
 files.add(ROOT/name)
files.add(pathlib.Path(__file__).resolve());archive=OUT/'raw.tar.gz';members=[]
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0,filename='') as gz:
 with tarfile.open(fileobj=gz,mode='w|') as tar:
  for p in sorted(files):
   data=p.read_bytes();name=str(p.relative_to(ROOT));info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644;tar.addfile(info,io.BytesIO(data));members.append({'path':name,'bytes':len(data),'sha256':sha(data)})
index={x['path']:x for x in members}
with tarfile.open(archive,'r:gz') as tar:
 actual=tar.getmembers();assert len(actual)==len(index)
 for m in actual:
  assert m.isfile() and not pathlib.PurePosixPath(m.name).is_absolute() and '..' not in pathlib.PurePosixPath(m.name).parts
  data=tar.extractfile(m).read();assert index[m.name]=={'path':m.name,'bytes':len(data),'sha256':sha(data)}
for m in members:assert sha((ROOT/m['path']).read_bytes())==m['sha256']
manifest={'kind':'phase5-consolidated-default-release-evidence','complete':True,'newBootstrapForDerivative':False,'archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'sourcesRechecked':True,'members':members,'scope':'Actual fresh checked parent build, maintained derivative and focused validation, ordinary CLI controls, preserved sandbox failure, installed release lineage. No full conformance or new self-host proof claim.','prerequisites':'Recorded Node/Clang/Linux executables and pinned upstream Git metadata remain external; historical report paths are preserved.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:v for k,v in manifest.items() if k!='members'}))
