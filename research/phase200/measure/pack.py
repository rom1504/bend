#!/usr/bin/env python3
"""Compress completed physical screen receipts without retaining duplicate binaries."""
import argparse,gzip,hashlib,io,json,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent

def pin(path):
 path=Path(path).resolve();data=path.read_bytes();return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def read(path):return json.loads(Path(path).read_text())
def main():
 p=argparse.ArgumentParser();p.add_argument('--run',required=True,type=Path);p.add_argument('--acquisition-plan',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--recovery',type=Path);a=p.parse_args()
 run=a.run.resolve();summary_path=a.recovery/'summary.json' if a.recovery else run/'summary.json';s=read(summary_path)
 if a.recovery:assert s['completeObservedEvidence'] and not s['executionGuardSucceeded'] and s['kind']=='phase200-recovered-observations-summary' and s['recovery']['originalReport']==pin(run/'timing/report.json')
 else:assert s['complete'] and s['kind']=='phase200-authenticated-runtime-screen'
 assert pin(s['plan']['file'])==s['plan'];plan=read(s['plan']['file'])
 raw=read(s['report']['file']);assert raw['complete'] and not raw.get('changedInputs') and not raw.get('error');assert s['oracleRevalidated']['samples']==9*len(plan['cases'])
 acquisition=read(a.acquisition_plan);native=Path(plan['nativeManifest']['file']).parent;nr=read(native/'report.json');assert nr['complete'] and nr['programManifest']==pin(plan['nativeManifest']['file'])
 native_manifest=read(plan['nativeManifest']['file']);assert native_manifest['roles'][plan['nativeRole']]['compilerSource']==acquisition['source']
 out=a.out.resolve();assert not out.exists();out.mkdir(parents=True);files=set();external={}
 def add(path):
  path=Path(path).resolve();assert path.is_file() and ROOT in path.parents;assert path.stat().st_size<32*1024*1024;files.add(path)
 def tree(path):
  for item in Path(path).rglob('*'):
   if item.is_file() and (item.suffix=='.json' or 'stdout' in item.name or 'stderr' in item.name):add(item)
 def pins(value):
  if isinstance(value,dict):
   if all(k in value for k in ('file','bytes','sha256')):
    file=str(Path(value['file']).resolve());row={k:value[k] for k in ('bytes','sha256')}
    external[(file,row['sha256'],row['bytes'])]=row
   for item in value.values():pins(item)
  elif isinstance(value,list):
   for item in value:pins(item)
 for stage in (native,run):
  assert stage.parent==ROOT/'selfhost/build/phase200';guard=stage.with_name(stage.name+'-guard');process=read(guard/'process.json');retention=read(guard/'retention.json');closure=ROOT/'selfhost/build-retention/phase200'/(stage.name+'-close/report.json')
  assert retention['closed'] and read(closure)['complete']
  if a.recovery and stage==run:assert not process['complete'] and process['stoppedFor']=='disk-budget' and pin(guard/'process.json')==s['recovery']['guard']
  else:assert process['complete'] and process['returncode']==0
  tree(stage);tree(guard);add(closure)
 if a.recovery:tree(a.recovery)
 failure=run.parent/'candidate-broad01'
 if a.recovery and failure!=run and failure.with_name(failure.name+'-guard').exists():
  tree(failure);tree(failure.with_name(failure.name+'-guard'));add(ROOT/'selfhost/build-retention/phase200/candidate-broad01-close/report.json');add(HERE/'plans/candidate-broad01.json');add(HERE/'plans/candidate-broad01-argv.json');add(HERE/'refusals/broad01-screen.py')
 for path in (a.acquisition_plan,s['plan']['file'],s['runtime']['file'],plan['runtimeReceipt']['file'],plan['baseline']['file'],plan['baselinePreparation']['file'],acquisition['source']['file'],acquisition['sourceCheck']['file'],acquisition['imageReceipt']['file'],acquisition['assets']['file']):add(path)
 for item in HERE.iterdir():
  if item.is_file() and item.suffix in ('.py','.md'):add(item)
 for value in plan['inputs']:add(value['file']) if Path(value['file']).suffix in ('.py','.json') else None
 add(summary_path.with_suffix('.md'))
 if (HERE/'campaign-summary01.json').exists():add(HERE/'campaign-summary01.json')
 for path in files:
  if path.suffix=='.json':pins(read(path))
 rows=[dict(path=str(path.relative_to(ROOT)),**{k:v for k,v in pin(path).items() if k!='file'}) for path in sorted(files)];assert sum(r['bytes'] for r in rows)<90*1024*1024
 archive=out/'receipts.tar.gz'
 with archive.open('xb') as rawout,gzip.GzipFile(filename='',mode='wb',fileobj=rawout,mtime=0) as gz,tarfile.open(fileobj=gz,mode='w',format=tarfile.PAX_FORMAT) as tar:
  for row in rows:
   data=(ROOT/row['path']).read_bytes();assert len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256'];info=tarfile.TarInfo(row['path']);info.size=len(data);info.mode=0o644;info.mtime=0;tar.addfile(info,io.BytesIO(data))
 with tarfile.open(archive,'r:gz') as tar:
  assert len(tar.getmembers())==len(rows)
  for row in rows:
   data=tar.extractfile(row['path']).read();assert len(data)==row['bytes'] and hashlib.sha256(data).hexdigest()==row['sha256']
 index=dict(kind='phase200-physical-screen-receipts',complete=True,targetsRun=False,method=pin(__file__),summary=pin(summary_path),recoveredAfterFailedGuard=bool(a.recovery),archive=pin(archive),files=rows,externalDependencies=[dict(file=key[0],**row) for key,row in sorted(external.items()) if Path(key[0]) not in files or pin(key[0])['sha256']!=row['sha256']],scope='Exact source/recipe/guard/closed-retention and complete pilot/timed/preflight streams. Recovery explicitly retains original failed guards; complete archive does not mean successful physical guard. Multiple historical hashes of one method path remain separately identified; refused broad01 screen bytes are preserved under refusals/. Native compiler/program binaries and program objects remain external pinned dependencies; not a standalone toolchain or a claim of newly executed evidence.')
 (out/'index.json').write_text(json.dumps(index,indent=2)+'\n');print(json.dumps(dict(archive=pin(archive),index=pin(out/'index.json'),files=len(rows))))
if __name__=='__main__':main()
