#!/usr/bin/env python3
import gzip,hashlib,io,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent;RUN=ROOT/'selfhost/build/phase6/native-scaling';sha=lambda b:hashlib.sha256(b).hexdigest();r=json.loads((RUN/'report.json').read_text());assert r['complete'] and r['inputsVerified'];files={p for p in RUN.rglob('*')if p.is_file()};external=[]
for item in r['inputs']:
 p=pathlib.Path(item['file']);assert sha(p.read_bytes())==item['sha256'];assert str(p.resolve())==item['canonicalPath']
 if p.is_relative_to(ROOT):files.add(p)
 else:external.append(item)
for n in ['reference','candidate']:
 p=ROOT/'selfhost/build/phase5/final-backends/broad-run-01/paired'/f'{n}.json.artifacts/1520'
 files.update(x for x in p.rglob('*')if x.is_file())
for p in [ROOT/'implementation/phase6/native-arity-wall.py',ROOT/'implementation/phase6/native-arity-wall.json',ROOT/'implementation/phase6/native-scaling-audit.py',ROOT/'selfhost/build/phase5/final-backends/broad-run-01/arity-wall-inspection.json']:files.add(p)
archive=OUT/'raw.tar.gz';assert not archive.exists();members=[]
with archive.open('xb')as stream,gzip.GzipFile(fileobj=stream,mode='wb',mtime=0)as gz,tarfile.open(fileobj=gz,mode='w|')as tar:
 for p in sorted(files):
  data=p.read_bytes();name=str(p.relative_to(ROOT));i=tarfile.TarInfo(name);i.size=len(data);i.mode=0o755 if p.name=='program'else 0o644;tar.addfile(i,io.BytesIO(data));members.append({'path':name,'bytes':len(data),'sha256':sha(data)})
index={x['path']:x for x in members};seen=set()
with tarfile.open(archive,'r|gz')as tar:
 for i in tar:
  assert i.isfile()and not pathlib.PurePosixPath(i.name).is_absolute()and '..'not in pathlib.PurePosixPath(i.name).parts;b=tar.extractfile(i).read();assert index[i.name]=={'path':i.name,'bytes':len(b),'sha256':sha(b)};seen.add(i.name)
assert seen==set(index)
m={'kind':'phase6-native-scaling-evidence','archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'members':members,'external':external,'scope':'Three checked emit-only cases32/64/128 plus retained255 broad C/referencebinary anchor. No freshClang or runtime gate, no performance claim. Full checked/derived lineage also retained in Phase5 broad archive; original absolute paths remain historical.'};(OUT/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(json.dumps({k:v for k,v in m.items()if k not in ['members','external']}))
