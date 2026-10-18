#!/usr/bin/env python3
"""Archive bounded Phase109 evidence and verify every archived byte."""
import argparse,hashlib,json,shutil,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve()
assert out.is_relative_to(ROOT/'implementation/phase109/evidence') and not out.exists()
roots=[ROOT/'selfhost/build/phase109',ROOT/'selfhost/build/phase108/p109-native-source01',ROOT/'selfhost/build/phase108/p109-native-source02']
files=sorted({f for r in roots if r.exists() for f in r.rglob('*') if f.is_file()})
files += [ROOT/'selfhost/build/phase90/runtime-accessor-transport02/runtime.c']
files += sorted(f for f in (ROOT/'selfhost/tools/performance/phase109').rglob('*') if f.is_file() and '__pycache__' not in f.parts)
assert len(files)==len(set(files)) and not any(f.is_symlink() for f in files)
raw=sum(f.stat().st_size for f in files);assert raw<180*1024**2 and shutil.disk_usage(ROOT).free>32*1024**2
pin=lambda f:dict(file=str(f.relative_to(ROOT)),bytes=f.stat().st_size,sha256=hashlib.sha256(f.read_bytes()).hexdigest())
entries=[pin(f) for f in files];out.parent.mkdir(parents=True,exist_ok=True)
with tarfile.open(out,'w:gz',compresslevel=6) as t:
 for f in files:t.add(f,arcname=str(f.relative_to(ROOT)),recursive=False)
expected={x['file']:x for x in entries}
with tarfile.open(out,'r:gz') as t:
 assert len(t.getmembers())==len(entries)
 for m in t:
  assert m.isfile() and m.name in expected and not Path(m.name).is_absolute() and '..' not in Path(m.name).parts
  data=t.extractfile(m).read();e=expected[m.name];assert len(data)==e['bytes'] and hashlib.sha256(data).hexdigest()==e['sha256']
assert entries==[pin(f) for f in files], 'input changed during sealing'
report=dict(kind='phase109-evidence-capsule',complete=True,method=pin(Path(__file__)),archive=pin(out),uncompressedBytes=raw,members=len(entries),allMembersVerified=True,entries=entries,restore='Inspect manifest, then extract from repository root only into absent build destinations; do not overwrite live source/tool files.')
(out.parent/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:v for k,v in report.items() if k not in ['entries','restore']}))
