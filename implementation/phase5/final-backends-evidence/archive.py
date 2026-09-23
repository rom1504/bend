#!/usr/bin/env python3
import gzip,hashlib,io,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent;RUN=ROOT/'selfhost/build/phase5/final-backends'
sha=lambda b:hashlib.sha256(b).hexdigest()
report=json.loads((RUN/'run-01/report.json').read_text());assert report['complete'] and report['selectedComplete'] and report['inputsVerified']
files={p for p in RUN.rglob('*') if p.is_file()};external=[]
def retain(item):
 p=pathlib.Path(item['file']);assert sha(p.read_bytes())==item['sha256'],p
 if item.get('canonicalPath'):assert str(p.resolve())==item['canonicalPath']
 if p==pathlib.Path(report['toolchain']['compiler']['file']) or not p.is_relative_to(ROOT):external.append(item)
 else:files.add(p)
for item in report['inputs']:
 retain(item)
 if item['file'].endswith('.bootstrap.json'):
  proof=json.loads(pathlib.Path(item['file']).read_text());assert proof['provenance']['verifiedAfterBuild']
  for i in proof['provenance']['inputs']:retain(i)
  retain({'file':proof['source'],'sha256':proof['sourceSha256']})
  for m in proof['modules']:retain({'file':str(pathlib.Path(proof['source']).parent/m['file']),'sha256':m['sha256']})
native=[]
for name in ['reference','candidate']:
 raw=json.loads((RUN/f'run-01/paired/{name}.json').read_text());assert len(raw['results'])==42 and raw['selectedComplete'];assert not raw['changedInputs'] and not raw['identity']['changedArtifacts']
 for item in raw['identity']['artifacts'].values():retain(item)
 for file,digest in raw['inputHashes'].items():
  if digest:retain({'file':file,'sha256':digest,'canonicalPath':raw['inputPaths'][file]})
 for row in raw['results']:
  assert row['status']=='pass'
  if row['lane']=='native' and not row['negative']:
   d=pathlib.Path(row['artifacts']);source=d/'program.c';binary=d/'program';assert source.is_file() and binary.is_file()
   native.append({'compiler':name,'id':row['id'],'source':{'file':str(source),'sha256':sha(source.read_bytes())},'binary':{'file':str(binary),'sha256':sha(binary.read_bytes())},'build':json.loads((d/'native-build.json').read_text()) if (d/'native-build.json').exists() else row['result']['nativeBuild'],'result':row['result']})
assert len(native)==18
(RUN/'native-inputs.json').write_text(json.dumps(native,indent=2)+'\n');files.add(RUN/'native-inputs.json')
# Preserve the two invalid original fixture sources at separate historical paths.
old=json.loads((RUN/'fresh-controls-01.json').read_text())
for row in old['rows']:
 p=RUN/'historical-fixtures'/pathlib.Path(row['input']['file']).name;p.parent.mkdir(exist_ok=True);p.write_text(row['source']);assert sha(p.read_bytes())==row['input']['sha256'];files.add(p)
archive=OUT/'raw.tar.gz';assert not archive.exists();members=[]
with archive.open('xb') as stream,gzip.GzipFile(fileobj=stream,mode='wb',mtime=0) as zipped:
 with tarfile.open(fileobj=zipped,mode='w|') as tar:
  for p in sorted(files):
   data=p.read_bytes();name=str(p.relative_to(ROOT));info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o755 if p.name=='program' else 0o644;tar.addfile(info,io.BytesIO(data));members.append({'path':name,'bytes':len(data),'sha256':sha(data)})
index={m['path']:m for m in members}
with tarfile.open(archive,'r:gz') as tar:
 actual=tar.getmembers();assert len(actual)==len(index)
 for i in actual:
  assert i.isfile() and not pathlib.PurePosixPath(i.name).is_absolute() and '..' not in pathlib.PurePosixPath(i.name).parts
  b=tar.extractfile(i).read();assert index[i.name]=={'path':i.name,'bytes':len(b),'sha256':sha(b)}
manifest={'kind':'phase5-selected-final-backends-evidence','archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'members':members,'external':external,'scope':'84 selected observations,18 actual native C inputs and binaries, both fixture-author failures and corrected controls. Ten exact diagnostic differences remain; selected acceptance/phase pass is not exact conformance. Node/Clang/system libraries and headers remain external prerequisites.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:v for k,v in manifest.items() if k not in ['members','external']}))
