"""Build/seal the identical fused selector under baseline versus wide producer."""
import argparse,copy,hashlib,json,os,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6]
ORACLE=ROOT/'selfhost/tools/performance/phase131/regions/selector-ceiling/expected.stdout'
EMIT=ROOT/'selfhost/build/phase118/p131-wide-selector-emit01/report.json'
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);p.add_argument('--seal',action='store_true');a=p.parse_args()
out=a.out.resolve();assert not out.exists()and out.is_relative_to(ROOT/'selfhost/build/phase131')
emission=read(EMIT);assert emission['complete']
out.mkdir();inputs=[pin(__file__),pin(EMIT),pin(ORACLE),*emission['inputs']]
if not a.seal:
 assert sorted(os.sched_getaffinity(0))==[5]
 r=dict(complete=False,inputs=inputs,rows=[])
 def save():(out/'report.json').write_text(json.dumps(r,indent=2)+'\n')
 save()
 try:
  for case in emission['cases']:
   assert case['name']in['selector-fused','selector-fused-short']and case['verified']and case['parentVerified']
   build=ROOT/f'selfhost/build/phase111/p131-wide-{case["name"]}01'
   cmd=['python3',str(ROOT/'selfhost/tools/performance/phase123/build-aligned.py'),'--source',case['qbe']['file'],'--runtime',emission['runtime']['file'],'--out',str(build),'--expected',str(ORACLE),'--seconds','20']
   row=dict(case=case['name'],command=cmd);r['rows'].append(row);save()
   child=subprocess.run(cmd,capture_output=True,timeout=30);row.update(exitCode=child.returncode,stdout=child.stdout.decode(),stderr=child.stderr.decode());save();assert child.returncode==0
   b=read(build/'report.json');assert b['complete']and b['outputExact'];row['build']=pin(build/'report.json');row['binary']=b['binary'];save()
  r['complete']=True;save()
 except BaseException as e:r['error']=repr(e);save();raise
else:
 basepath=ROOT/'selfhost/build/phase131/selector-ceiling-timing02/manifest.json';base=read(basepath);inputs += [pin(basepath),*base['inputs']]
 workloads=[]
 for old in base['workloads']:
  fused=copy.deepcopy(next(x for x in old['variants']if x['name']=='fused'))
  name='selector-fused-short'if old['name']=='selector-bucket1'else'selector-fused'
  path=ROOT/f'selfhost/build/phase111/p131-wide-{name}01/report.json';b=read(path);assert b['complete']and b['outputExact']
  case=next(x for x in emission['cases']if x['name']==name);assert case['qbe']in b['inputs']and emission['runtime']in b['inputs']
  oldemit=read(ROOT/'selfhost/build/phase118/p131-selector-ceiling03/report.json')
  assert next(x['source']for x in oldemit['cases']if x['name']==name)==case['source']
  inputs += [pin(path),*b['inputs'],b['binary']]
  fused['name']='baseline';candidate=copy.deepcopy(fused);candidate.update(name='candidate',binary=b['binary']);candidate['command'][0]=b['binary']['file']
  workloads.append(dict(name=old['name'],timeoutSeconds=old['timeoutSeconds'],variants=[fused,candidate]))
 for x in inputs:assert pin(x['file'])==x,x['file']
 manifest=dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),inputs=inputs,workloads=workloads,repetitions=base['repetitions'],scope='Identical independently checked fused scalar selector source; final frozen producer vs four-bound wider-record producer. Same runtime and34line oracle, one-entry and64collision regimes. Three rotating pairs. No source algorithm changes, no whole compiler claim.')
 (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
 cmd=['python3',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),'--out',str(out/'guard'),'--seconds','90','--rss-mib','512','--available-mib','16384','--file-mib','64','--cpu','3','--','python3',str(ROOT/'selfhost/tools/profiler/run.py'),'--manifest',str(out/'manifest.json'),'--out',str(out/'timing'),'--modes','clean','--rounds','3']
 (out/'jobs.json').write_text(json.dumps(dict(complete=True,targetsRun=False,command=cmd),indent=2)+'\n')
print(json.dumps(dict(complete=True,out=str(out),sealed=a.seal)))
