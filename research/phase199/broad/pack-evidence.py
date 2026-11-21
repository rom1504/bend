#!/usr/bin/env python3
"""Preserve integrated source, small receipts and output streams; no target runs."""
import argparse,gzip,hashlib,io,json,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];BUILD=ROOT/'selfhost/build/phase198';HERE=Path(__file__).resolve().parent
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def main():
 p=argparse.ArgumentParser();p.add_argument('--summary',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--placement',action='store_true');a=p.parse_args()
 s=read(a.summary);raw=read(s['report']['file']);assert raw['complete'] and not raw.get('changedInputs') and not raw.get('error')
 assert s['kind'] in ('phase199-integrated-three-role-authenticated-summary','phase199-two-round-native-pair-fallback')
 pair=s['kind']=='phase199-two-round-native-pair-fallback';assert len(raw['cases'])==45 and s['oracleRevalidated']['samples']==(180 if pair else 405)
 config=read(HERE/'integrated-pins.json');assert s['source']==config['source'];out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
 prep_pin=s['sharedPreparation'] if pair else s['preparation'];assert pin(prep_pin['file'])==prep_pin
 prep=read(prep_pin['file']);assert prep['complete'] and prep['source']==s['source']
 assert pin(prep['native']['file'])==prep['native'];native=read(prep['native']['file'])
 image_receipt=native['roles']['candidate']['imageBinding'];assert pin(image_receipt['file'])==image_receipt
 timing_root=Path(s['report']['file']).resolve().parent
 if pair:timing_root=timing_root.parent
 roots=[Path(image_receipt['file']).parent,Path(prep['native']['file']).parent,Path(prep_pin['file']).parent,timing_root]
 assert all(root.resolve().parent==BUILD for root in roots),'Expected declared Phase198 artifact roots'
 files=set();external={}
 def add(path):
  path=Path(path).resolve();assert path.is_file() and ROOT in path.parents,path;assert path.stat().st_size<=32*1024*1024,path;files.add(path)
 def pins(value):
  if isinstance(value,dict):
   if all(k in value for k in ('file','bytes','sha256')):
    f=str(Path(value['file']).resolve());item={k:value[k] for k in ('bytes','sha256')}
    if f in external:assert external[f]==item,'Conflicting pin '+f
    external[f]=item
   for v in value.values():pins(v)
  elif isinstance(value,list):
   for v in value:pins(v)
 def tree(directory):
  for path in directory.rglob('*'):
   if path.is_file() and (path.suffix=='.json' or 'stdout' in path.name or 'stderr' in path.name):add(path)
 source_check=BUILD/'p199-integrated-check01/report.json';checked=read(source_check)
 assert checked['complete'] and checked['checked'] and checked['source']==s['source']
 add(source_check);add(Path(s['source']['file']).with_name('report.json'))
 stages=['p199-integrated-check01',*[root.name for root in roots]]
 if a.placement:stages.append('p199-integrated-placement01')
 for stem in stages:
  process=BUILD/(stem+'-guard/process.json');retention=BUILD/(stem+'-guard/retention.json');closure=ROOT/'selfhost/build-retention/phase198'/(stem+'-close/report.json')
  pr,rt,cl=read(process),read(retention),read(closure)
  assert pr['complete'] and pr['returncode']==0 and rt['closed'] and cl['complete'] and cl['classification']=='completed',stem
  for path in (process,retention,closure):add(path)
  tree(BUILD/stem)
 refusals=[]
 stem='p199-integrated-live-plan01'
 if stem not in stages and (BUILD/(stem+'-guard/retention.json')).exists():
  failed=BUILD/(stem+'-guard');process=read(failed/'process.json');retention=read(failed/'retention.json');closure=ROOT/'selfhost/build-retention/phase198'/(stem+'-close/report.json')
  assert process['returncode']!=0 and retention['closed'] and read(closure)['classification']=='failed'
  tree(failed);add(closure)
  for name in ('stdout.log','stderr.log'):
   if (failed/name).exists():add(failed/name)
  refusals.append(dict(stage=stem,process=pin(failed/'process.json'),retention=pin(failed/'retention.json'),closure=pin(closure),reason='Relative bundle input paths refused strict pin identity before target links; fresh plan02 canonicalizes paths and rechecks all byte hashes.'))
 add(a.summary);md=a.summary.with_suffix('.md')
 if md.exists():add(md)
 for path in HERE.iterdir():
  if path.is_file() and path.suffix in ('.py','.json','.md'):add(path)
 for value in config.values():add(value['file'])
 bundle=read(config['bundle']['file'])
 for value in bundle['inputs']:
  path=Path(value['file'])
  if path.suffix in ('.py','.json','.o'):add(path)
 for path in [BUILD/'progress-live-plan01/report.json',BUILD/'progress-live-plan01/manifest.json',ROOT/'selfhost/build/phase195/references01/manifest.json',ROOT/'research/phase198/runtime-broad/portfolio-pins.json',ROOT/'research/phase198/runtime-broad/partition.json',ROOT/'selfhost/tools/bench/catalogs/native45/catalog.json']:
  add(path)
 for path in sorted(files):
  if path.suffix=='.json':pins(read(path))
 rows=[dict(path=str(path.relative_to(ROOT)),**{k:v for k,v in pin(path).items() if k!='file'}) for path in sorted(files)]
 assert sum(r['bytes'] for r in rows)<90*1024*1024,'Receipt archive input bound exceeded'
 archive=out/'receipts.tar.gz'
 with archive.open('xb') as rawout,gzip.GzipFile(filename='',mode='wb',fileobj=rawout,mtime=0) as gz,tarfile.open(fileobj=gz,mode='w',format=tarfile.PAX_FORMAT) as tar:
  for row in rows:
   data=(ROOT/row['path']).read_bytes();assert len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256'];info=tarfile.TarInfo(row['path']);info.size=len(data);info.mode=0o644;info.mtime=0;tar.addfile(info,io.BytesIO(data))
 with tarfile.open(archive,'r:gz') as tar:
  assert len(tar.getmembers())==len(rows)
  for row in rows:
   data=tar.extractfile(row['path']).read();assert len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256']
 excluded=[dict(file=f,**v) for f,v in sorted(external.items()) if Path(f) not in files]
 index=dict(kind='phase199-integrated-broad-receipts',complete=True,targetsRun=False,method=pin(__file__),summary=pin(a.summary),source=s['source'],archive=pin(archive),files=rows,stages=stages,preparation=prep_pin,retainedRefusals=refusals,externalDependencies=excluded,scope='Exact source, small receipts, guards/closed retention, full measured/preflight output streams and runtime bundle objects. Native compiler/program binaries and program objects remain pinned external dependencies. This archive preserves results; it is not a standalone toolchain, fresh execution, or replacement for original strict artifact authentication. Extract without overwriting into a separate evidence directory; original receipt paths/pins are preserved verbatim.')
 (out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(json.dumps(dict(archive=pin(archive),index=pin(out/'index.json'),files=len(rows),externalDependencies=len(excluded))))
if __name__=='__main__':main()
