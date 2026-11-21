#!/usr/bin/env python3
"""Package a completed composed native chain's source and small receipts."""
import argparse,gzip,hashlib,io,json,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];BUILD=ROOT/'selfhost/build/phase198'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
p=argparse.ArgumentParser();p.add_argument('--summary',required=True);p.add_argument('--out',required=True);a=p.parse_args()
s=read(a.summary);assert s['complete'];plan=read(s['plan']['file']);prefix=plan['prefix'];out=Path(a.out);assert not out.exists();out.mkdir()
files=set()
def add(p):
 p=Path(p).resolve();assert p.is_file() and ROOT in p.parents,p;files.add(p)
for p in Path(plan['selectedSource']['file']).parent.rglob('*'):
 if p.is_file():add(p)
add(a.summary);add(s['method']['file']);add(s['plan']['file']);add(plan['sourceCheck']['file']);add(__file__)
for k in ['method','templates']:add(plan[k]['file'])
for row in plan['argv']:add(row['file'])
for gate in s['gates']:
 stem=gate['name'];add(gate['report']['file']);add(gate['guard']['file'])
 for p in [BUILD/(stem+'-guard')/'retention.json',ROOT/'selfhost/build-retention/phase198'/(stem+'-close')/'report.json']:
  add(p)
 for name in ['request.json','build-request.json']:
  p=BUILD/stem/name
  if p.exists():add(p)
for stem in [prefix+'-source-check01',prefix+'-live-plan01',prefix+'-live-broad01',prefix+'-live-gates01',prefix+'-native-heldout01',prefix+'-compare-orbit01',prefix+'-compare-live01']:
 for p in [BUILD/stem/'report.json',BUILD/(stem+'-guard')/'process.json',BUILD/(stem+'-guard')/'retention.json',ROOT/'selfhost/build-retention/phase198'/(stem+'-close')/'report.json']:
  if p.exists():add(p)
for stem in [prefix+'-native-heldout01',prefix+'-live-plan01']:
 for p in (BUILD/stem).rglob('*'):
  if p.is_file() and (p.suffix=='.json' or 'stdout' in p.name or 'stderr' in p.name):add(p)
for name in ['run-frozen.py','native-heldout.py','compare-source-products.py']:
 add(ROOT/'research/phase198/qualification'/name)
for p in [ROOT/'research/phase198/runtime-broad/compare-live.py',ROOT/'research/phase198/runtime-broad/portfolio.py',ROOT/'research/phase198/composition/live-gates.py']:
 if p.exists():add(p)
for p in (BUILD/(prefix+'-live-argv01')).glob('*.json'):add(p)
for name in ['native-heldout01','compare-orbit01','compare-live01']:
 p=BUILD/(prefix+'-'+name+'-argv.json')
 if p.exists():add(p)
for name in [prefix+'-performance-journal01.json',prefix+'-acquisition-journal01.json',prefix+'-boundary-journal01.json',prefix+'-boundary-run-argv01.json',prefix+'-reproduction-journal01.json',prefix+'-reproduction-run-argv01.json',prefix+'-remainder-run-argv01.json',prefix+'-self-journal01.json',prefix+'-live-gates01-argv.json']:
 p=BUILD/name
 if p.exists():add(p)
p=BUILD/'cross-source-comparison-controls01.json'
if p.exists():add(p)
for name in ['assets.json'] :add(ROOT/'selfhost/build/phase194'/name)
for p in [ROOT/'selfhost/build/phase186/release-qbe-chain01/n2/report.json',ROOT/'research/phase198/runtime-broad'/(prefix+'-summary.json')]:
 if p.exists():add(p)
rows=[dict(path=str(p.relative_to(ROOT)),**{k:v for k,v in pin(p).items() if k!='file'}) for p in sorted(files)]
archive=out/'receipts.tar.gz'
with archive.open('wb') as raw,gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as gz,tarfile.open(fileobj=gz,mode='w',format=tarfile.PAX_FORMAT) as tar:
 for row in rows:
  data=(ROOT/row['path']).read_bytes();info=tarfile.TarInfo(row['path']);info.size=len(data);info.mode=0o644;info.mtime=0;tar.addfile(info,io.BytesIO(data))
with tarfile.open(archive,'r:gz') as tar:
 for row in rows:
  b=tar.extractfile(row['path']).read();assert len(b)==row['bytes'] and hashlib.sha256(b).hexdigest()==row['sha256']
index=dict(kind='phase198-composed-native-replay-bundle',complete=True,targetsRun=False,method=pin(__file__),archive=pin(archive),summary=pin(a.summary),selectedSource=s['selectedSource'],contents=rows,scope='Source and exact argv/receipts. Large compiler/program binaries, toolchains and API transport assets remain separate pinned dependencies; no claim this small archive alone is an executable toolchain. Extract into a fresh checkout/evidence directory and replay with fresh output names and consistent dependent paths.')
(out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(json.dumps(dict(archive=pin(archive),index=pin(out/'index.json'),files=len(rows))))
