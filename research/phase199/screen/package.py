"""Compact immutable screen evidence; no target execution."""
import gzip,hashlib,io,json,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).parent;B=ROOT/'selfhost/build/phase199'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
r=read(HERE/'results.json');assert r['complete'];files=set()
def add(p):
 p=Path(p).resolve();assert p.is_file() and ROOT in p.parents,p;files.add(p)
for p in HERE.glob('*'):
 if p.is_file():add(p)
commands=[]
for gate in r['gates']:
 name=gate['name'];g=read(gate['guard']['file']);commands.append(dict(name=name,recordedCommand=g['command'],rssLimitBytes=g['rssLimitBytes'],diskBudgetBytes=g['diskBudgetBytes'],guard=gate['guard']))
 for folder in [B/name,B/(name+'-guard'),ROOT/'selfhost/build-retention/phase199'/(name+'-close')]:
  for p in folder.rglob('*'):
   if p.is_file() and (p.suffix in ['.json','.o','.s'] or p.name.endswith(('.stdout','.stderr','.log'))):add(p)
for name in ['baseline-source01','scan-source02','focused-plan01']:
 for p in (B/name).rglob('*'):
  if p.is_file() and p.suffix in ['.json','.bend']:add(p)
for p in [B/'scan-api01/report.json',ROOT/'selfhost/build/phase198/p199-scan-runtime01/report.json',ROOT/'selfhost/build/phase198/p199-scan-runtime01/scan.o',ROOT/'research/phase199/scan-runtime/scan.c',ROOT/'research/phase199/scan-runtime/scan.h']:add(p)
products=read(r['products']['file'])
for case in products['cases'].values():
 add(case['baselineObject']['file']);add(case['source']['file'])
 for arm in case['arms'].values():add(arm['products']['c']['artifact']['file'])
cp=HERE/'commands.json';cp.write_text(json.dumps(dict(targetsRun=False,commands=commands,replay='Use existing Phase199 job.py with fresh artifact names and consistent dependent paths. Commands below record the exact guarded process argv, including CPU and file limits.'),indent=2)+'\n');add(cp)
out=HERE/'evidence';out.mkdir(exist_ok=True);archive=out/'receipts.tar.gz';assert not archive.exists()
rows=[dict(path=str(p.relative_to(ROOT)),**{k:v for k,v in pin(p).items() if k!='file'}) for p in sorted(files)]
with archive.open('wb') as raw,gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as gz,tarfile.open(fileobj=gz,mode='w',format=tarfile.PAX_FORMAT) as tar:
 for row in rows:
  data=(ROOT/row['path']).read_bytes();info=tarfile.TarInfo(row['path']);info.size=len(data);info.mode=0o644;info.mtime=0;tar.addfile(info,io.BytesIO(data))
with tarfile.open(archive,'r:gz') as tar:
 for row in rows:
  data=tar.extractfile(row['path']).read();assert len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256']
index=dict(complete=True,targetsRun=False,method=pin(__file__),summary=pin(HERE/'results.json'),archive=pin(archive),contents=rows,scope='All retained physical timing stdout/count observations and fresh oracle observations are in report.json records. Empty stderr and zero exit were required by the original validator; timed stderr was not separately stored. Includes emitted object/assembly, baseline objects and mature C binaries. Linked variant binaries, engines, upstream API transports and original/live runtime objects remain separately content-pinned dependencies.')
(out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(json.dumps(dict(archive=pin(archive),members=len(rows))))
