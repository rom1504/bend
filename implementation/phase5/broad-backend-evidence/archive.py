#!/usr/bin/env python3
"""Retain closed broad execution, actual repro artifacts and verified lineage."""
import gzip,hashlib,io,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent;BASE=ROOT/'selfhost/build/phase5/final-backends';RUN=BASE/'broad-run-01';SNAP=BASE/'broad-snapshot-04'
assert not (OUT/'manifest.json').exists() and not list(OUT.glob('raw.tar.gz.part*')), 'Use a fresh archive directory'
sha=lambda b:hashlib.sha256(b).hexdigest()
r=json.loads((RUN/'report.json').read_text());assert r.get('finished'),'Run must be closed before archival'
files={p for directory in [RUN,SNAP] for p in directory.rglob('*') if p.is_file()};external={};checked={}
def retain(item):
 p=pathlib.Path(item['file']);digest=sha(p.read_bytes());assert digest==item['sha256'],str(p)
 if item.get('canonicalPath'):assert str(p.resolve())==item['canonicalPath'],str(p)
 checked[str(p)]=digest
 if not p.is_relative_to(ROOT) or p.resolve()==pathlib.Path(r['toolchain']['CC']).resolve():external[str(p)]=item
 else:files.add(p)
def walk(v):
 if isinstance(v,dict):
  if isinstance(v.get('file'),str) and isinstance(v.get('sha256'),str) and len(v['sha256'])==64:retain(v)
  for x in v.values():walk(x)
 elif isinstance(v,list):
  for x in v:walk(x)
walk(r);s=json.loads((SNAP/'snapshot.json').read_text());walk(s)
for name in ['broad-run-01.stdout','broad-run-01.stderr','broad-tests-04.stdout','broad-tests-04.stderr','broad-prepare-04.stdout','broad-prepare-04.stderr']:
 p=BASE/name
 if p.exists():files.add(p)
for p in [ROOT/'selfhost/tools/performance/phase5/broad-backends.mjs',ROOT/'selfhost/tools/performance/phase5/broad-backends.test.mjs',ROOT/'implementation/phase5/broad-backend-validation-plan.md']:
 files.add(p)
proof=json.loads(pathlib.Path(s['bootstrap']['file']).read_text());assert proof['provenance']['verifiedAfterBuild'];walk(proof['provenance']);retain({'file':proof['source'],'sha256':proof['sourceSha256']})
for m in proof['modules']:retain({'file':str(pathlib.Path(proof['source']).parent/m['file']),'sha256':m['sha256']})
if s.get('derivation'):walk(json.loads(pathlib.Path(s['derivation']['file']).read_text()))
rawCounts={};native=[]
for name in ['reference','candidate']:
 p=RUN/'paired'/(name+'.json')
 if not p.exists():continue
 raw=json.loads(p.read_text());rawCounts[name]=len(raw['results']);walk(raw['identity'].get('artifacts',{}))
 for file,digest in raw['inputHashes'].items():
  if digest:retain({'file':file,'sha256':digest,'canonicalPath':raw['inputPaths'][file]})
 for row in raw['results']:
  if row['lane']!='native':continue
  d=pathlib.Path(row['artifacts']);artifacts={}
  for n in ['program.c','program','native-build.json']:
   p=d/n
   if p.is_file():artifacts[n]={'file':str(p),'bytes':p.stat().st_size,'sha256':sha(p.read_bytes())}
  native.append({'compiler':name,'id':row['id'],'status':row['status'],'result':row['result'],'artifacts':artifacts})
(RUN/'native-inputs.json').write_text(json.dumps(native,indent=2)+'\n');files.add(RUN/'native-inputs.json')
archive=OUT/'raw.tar.gz';assert not archive.exists();members=[]
with archive.open('xb') as stream,gzip.GzipFile(fileobj=stream,mode='wb',mtime=0,compresslevel=1) as zipped:
 with tarfile.open(fileobj=zipped,mode='w|') as tar:
  for p in sorted(files):
   data=p.read_bytes();name=str(p.relative_to(ROOT));info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o755 if p.name=='program' else 0o644;tar.addfile(info,io.BytesIO(data));members.append({'path':name,'bytes':len(data),'sha256':sha(data)})
index={m['path']:m for m in members};seen=set()
with tarfile.open(archive,'r|gz') as tar:
 for i in tar:
  assert i.isfile() and not pathlib.PurePosixPath(i.name).is_absolute() and '..' not in pathlib.PurePosixPath(i.name).parts
  b=tar.extractfile(i).read();assert index[i.name]=={'path':i.name,'bytes':len(b),'sha256':sha(b)};seen.add(i.name)
assert seen==set(index)
manifest={'kind':'phase5-broad-backend-evidence','archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'members':members,'external':list(external.values()),'observations':rawCounts,'coverageComplete':r['complete'],'infrastructureHealthy':r.get('infrastructureHealthy',False),'scope':'Fresh paired eligible JS/native inventory; retained failures, unsupported cases, emitted code and actual native binaries. Derived artifact retains genuine checked parent and separate derivation, newBootstrap:false. No timing or whole-language conformance claim. Node/Clang/system headers and libraries remain external prerequisites.'}
parts=[];joined=hashlib.sha256()
with archive.open('rb') as stream:
 for number in range(10000):
  block=stream.read(48*1024*1024)
  if not block:break
  piece=OUT/(archive.name+f'.part{number:03d}');assert not piece.exists();piece.write_bytes(block);readback=piece.read_bytes();assert readback==block;joined.update(readback);parts.append({'file':piece.name,'bytes':len(block),'sha256':sha(block)})
assert joined.hexdigest()==manifest['sha256'];manifest['parts']=parts;manifest['archiveStorage']='Concatenate listed parts in order to recover the verified logical archive.'
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');archive.unlink();print(json.dumps({k:v for k,v in manifest.items() if k not in ['members','external']}))
