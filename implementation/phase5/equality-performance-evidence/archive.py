#!/usr/bin/env python3
"""Retain P5-012 consumed bytes, outputs and complete observations."""
import gzip,hashlib,io,json,pathlib,tarfile
ROOT=pathlib.Path(__file__).resolve().parents[3];OUT=pathlib.Path(__file__).resolve().parent
run=ROOT/'selfhost/build/phase5/equality-measurement';report=json.loads((run/'run-01/report.json').read_text());assert report['complete'] and report['inputsUnchanged']
sha=lambda b:hashlib.sha256(b).hexdigest();files={p for p in run.rglob('*') if p.is_file()};external=[]
for item in report['inputs']:
 p=pathlib.Path(item['file']);assert str(p.resolve())==item['canonicalPath'];assert sha(p.read_bytes())==item['sha256']
 try:p.relative_to(ROOT)
 except ValueError:external.append(item)
 else:files.add(p)
# verifyAttempt checks all copied helpers/fixtures too, not just bootstrap inputs.
attempt=pathlib.Path(report['original']['attempt']['file']);metadata=json.loads(attempt.read_text())
for item in metadata['snapshot']['sources']:
 p=pathlib.Path(item['frozen']['file']);assert sha(p.read_bytes())==item['frozen']['sha256'];files.add(p)
files.add(ROOT/'selfhost/tools/performance/phase5/equality-compare.test.mjs')
archive=OUT/'raw.tar.gz';assert not archive.exists();members=[]
with archive.open('xb') as raw,gzip.GzipFile(fileobj=raw,mode='wb',mtime=0) as zipped:
 with tarfile.open(fileobj=zipped,mode='w|') as tar:
  for p in sorted(files):
   data=p.read_bytes();name=str(p.relative_to(ROOT));info=tarfile.TarInfo(name);info.size=len(data);info.mode=0o644;tar.addfile(info,io.BytesIO(data));members.append({'path':name,'bytes':len(data),'sha256':sha(data)})
index={m['path']:m for m in members}
with tarfile.open(archive,'r:gz') as tar:
 actual=tar.getmembers();assert len(actual)==len(index)
 for item in actual:
  assert item.isfile() and not pathlib.PurePosixPath(item.name).is_absolute() and '..' not in pathlib.PurePosixPath(item.name).parts
  data=tar.extractfile(item).read();assert index[item.name]=={'path':item.name,'bytes':len(data),'sha256':sha(data)}
manifest={'kind':'phase5-maintained-equality-performance-evidence','archive':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive.read_bytes()),'membersVerified':True,'members':members,'external':external,'prerequisites':'The recorded Node binary, Linux taskset/git and original pinned upstream Git metadata remain external prerequisites. Restored source files do not fabricate a pinned checkout or a new checked build.'}
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(json.dumps({k:v for k,v in manifest.items() if k not in ['members','external']}))
