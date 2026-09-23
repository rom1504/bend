#!/usr/bin/env python3
"""Closed metadata preparations and pure tests only; no broad execution evidence."""
import gzip,hashlib,io,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent;RUN=ROOT/'selfhost/build/phase5/final-backends';sha=lambda b:hashlib.sha256(b).hexdigest()
files=set();reports=[]
for n in ['01','02','03']:
 p=RUN/('broad-snapshot-'+n);files.update(f for f in p.rglob('*') if f.is_file());r=json.loads((p/'snapshot.json').read_text());assert r['complete'];reports.append((p/'snapshot.json',r))
for n in ['broad-resource-adjustment.json','broad-tests-03.stdout','broad-tests-03.stderr','broad-prepare-03.stdout','broad-prepare-03.stderr','broad-prelaunch-03.json']:files.add(RUN/n)
for n in ['broad-backends.mjs','broad-backends.test.mjs']:files.add(ROOT/'selfhost/tools/performance/phase5'/n)
files.add(ROOT/'implementation/phase5/broad-backend-validation-plan.md')
originals={sha(p.read_bytes()):p for p in files if p.name.endswith('.source')};external=[];bindings=[]
for report,r in reports:
 for item in r['inputs']:
  p=pathlib.Path(item['file']);actual=sha(p.read_bytes()) if p.is_file() else None
  if actual!=item['sha256']:
   old=originals.get(item['sha256']);assert old is not None,('Unrecovered historical input',item)
   bindings.append({'report':str(report.relative_to(ROOT)),'originalInput':item,'currentSha256':actual,'retainedExactBytes':str(old.relative_to(ROOT))});continue
  assert str(p.resolve())==item['canonicalPath']
  if p.is_relative_to(ROOT):files.add(p)
  else:external.append(item)
pre=json.loads((RUN/'broad-prelaunch-03.json').read_text());assert pre['tests']['passed']==pre['tests']['groups']==3 and pre['tests']['exitCode']==0 and not pre['compilerExecuted'];assert 'tests 3' in (RUN/'broad-tests-03.stdout').read_text()
assert sha((RUN/'broad-snapshot-03/snapshot.json').read_bytes())==pre['preparation']['snapshotSha256']
archive=OUT/'raw.tar.gz';assert not archive.exists();members=[]
with archive.open('xb') as f,gzip.GzipFile(fileobj=f,mode='wb',mtime=0) as gz:
 with tarfile.open(fileobj=gz,mode='w|') as tar:
  for p in sorted(files):
   data=p.read_bytes();name=str(p.relative_to(ROOT));info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644;tar.addfile(info,io.BytesIO(data));members.append({'path':name,'bytes':len(data),'sha256':sha(data)})
index={m['path']:m for m in members}
with tarfile.open(archive,'r:gz') as tar:
 actual=tar.getmembers();assert len(actual)==len(index)
 for i in actual:
  assert i.isfile() and not pathlib.PurePosixPath(i.name).is_absolute() and '..' not in pathlib.PurePosixPath(i.name).parts
  b=tar.extractfile(i).read();assert index[i.name]=={'path':i.name,'bytes':len(b),'sha256':sha(b)}
manifest={'kind':'phase5-broad-backend-preparation-evidence','archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'preparations':3,'pureTestGroups':3,'pureTestGroupsPassed':3,'broadCompilerRuns':0,'historicalBindings':bindings,'members':members,'external':external,'scope':'Three closed metadata preparations, exact historical tool versions, resource/reporting amendments and actual pure tests. No broad backend run or new checked bootstrap is claimed. The test source is retained unchanged with its output; its hash is recorded at archival time.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:v for k,v in manifest.items() if k not in ['members','external','historicalBindings']}))
