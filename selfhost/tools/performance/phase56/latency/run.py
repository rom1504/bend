#!/usr/bin/env python3
"""Two checked sources, three genuine compiler images, three rotated fresh rounds."""
import argparse, hashlib, json, statistics, subprocess, sys, time
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; PROGRAMS=HERE.parents[1]/'programs'
sys.path.insert(0,str(PROGRAMS))
from support import ExecutionGuard,save
PIN='018751270e800bc222a93dad7f257083ee53a5f7'
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('out',type=Path)
p.add_argument('--image-pins',type=Path,default=ROOT/'selfhost/build/phase56/bootstrap-string01-plan/image-pins.json')
p.add_argument('--node',type=Path,default=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node'))
p.add_argument('--upstream',type=Path,default=ROOT/'selfhost/.bootstrap/upstream-phase23')
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase56') and not out.exists()
def identity(file):
 file=Path(file).resolve(strict=True);h=hashlib.sha256()
 with file.open('rb') as stream:
  for block in iter(lambda:stream.read(2**20),b''):h.update(block)
 return dict(file=str(file),sha256=h.hexdigest())
def read(file):return json.loads(Path(file).read_text())
def verify(items):
 for item in items:assert identity(item['file'])==item,item['file']
upstream=a.upstream.resolve();node=a.node.resolve();catalog=HERE.parents[1]/'phase37/catalog.json'
assert subprocess.check_output(['git','-C',str(upstream),'rev-parse','HEAD'],text=True).strip()==PIN
subprocess.run(['git','-C',str(upstream),'diff','--exit-code','HEAD','--','bend2'],check=True,stdout=subprocess.DEVNULL)
cat=read(catalog);assert cat['upstreamCommit']==PIN
cases=[]
for name in ['test-evening-program','lexer']:
 row=next(x for x in cat['cases'] if x['id']==name);assert not row.get('adapter')
 source=identity(catalog.parent/row['source']['path']);assert source['sha256']==row['source']['sha256']
 cases.append(dict(id=name,source=source,point=row['point']))
image_pins=read(a.image_pins);assert image_pins['kind']=='phase56-direct-image-pins'
inputs=[identity(x) for x in [__file__,HERE/'worker.mjs',HERE.parent/'bootstrap/setup-v2.mjs',
 HERE.parents[1]/'phase54/bootstrap/adapter.mjs',ROOT/'selfhost/tools/development/workflow.mjs',
 ROOT/'selfhost/tools/development/process.mjs',ROOT/'selfhost/tools/conformance/inventory.mjs',
 PROGRAMS/'support.py',HERE.parents[1]/'phase30/library-cost-worker.mjs',
 HERE.parents[1]/'phase47/compiler-cost-run.py',catalog,node,a.image_pins,
 *[upstream/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]]]+[x['source'] for x in cases]
verify(inputs);out.mkdir(parents=True);assert out.resolve().is_relative_to((ROOT/'selfhost/build/phase56').resolve())
config=dict(kind='phase56-three-role-library-latency-plan',roles=['typescript','source','direct'],samples=3,backend='direct',
 imagePins=identity(a.image_pins),upstream=str(upstream),upstreamCommit=PIN,cases=cases,inputs=inputs,
 resources=dict(cpu=3,heapMiB=1024,rssMiB=2048,availableMiB=4096,secondsPerChild=180,totalSeconds=1200),
 protocol='Fresh process per checked direct-library request; private Bend Base disk caches primed once outside timing. Import+request is primary; TS imports eagerly, Bend loads its API lazily. Three cyclically rotated rounds per source.')
save(out/'plan.json',config);config_id=identity(out/'plan.json')
report=dict(kind='phase56-three-role-library-latency',complete=False,pass_=False,config=config_id,
 preparations=[],rows=[],statistics={},inputs=inputs)
report['pass']=report.pop('pass_');save(out/'report.json',report);started=time.monotonic()
def launch(guard,request,prefix):
 verify(inputs);request_file=Path(str(prefix)+'.request.json');result_file=Path(str(prefix)+'.result.json')
 save(request_file,{**request,'config':config_id})
 execution=guard.run(['taskset','-c','3',str(node),'--stack-size=4096','--max-old-space-size=1024',
  str(HERE/'worker.mjs'),str(request_file),str(result_file)],Path(str(prefix)+'-process'),min(started+1200,time.monotonic()+180))
 observation=read(result_file) if result_file.exists() else None
 entry=dict(execution=execution,observation=observation,result=identity(result_file) if result_file.exists() else None)
 report['preparations' if request['stage']=='prepare' else 'rows'].append(entry);save(out/'report.json',report)
 assert execution['complete'] and observation and observation['complete'] and observation['pass'],entry
 assert observation['affinity'].split(':',1)[1].strip()=='3'
 verify(inputs);return entry
try:
 with ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
  preparations={}
  for role in config['roles']:
   dest=out/('prepare-'+role);dest.mkdir()
   row=launch(guard,dict(stage='prepare',role=role,out=str(dest)),out/('prepare-'+role))
   preparations[role]=row
  for case in cases:
   outputs=[next(x for x in preparations[r]['observation']['outputs'] if x['id']==case['id'])['output'] for r in ['source','direct']]
   assert outputs[0]['sha256']==outputs[1]['sha256'],'B1/B2 checked output mismatch'
   assert Path(outputs[0]['file']).read_bytes()==Path(outputs[1]['file']).read_bytes()
  report['preparationSeconds']=time.monotonic()-started;timing_start=time.monotonic()
  for case in cases:
   for sample in range(3):
    order=config['roles'][sample:]+config['roles'][:sample]
    for role in order:
     prefix=out/(case['id']+'-'+str(sample)+'-'+role)
     row=launch(guard,dict(stage='sample',role=role,case=case['id'],sample=sample,
      preparation=preparations[role]['result'],output=str(prefix)+'.mjs'),prefix)
     row.update(case=case['id'],sample=sample,role=role);save(out/'report.json',report)
  report['timingSeconds']=time.monotonic()-timing_start
  def stats(xs):return dict(median=statistics.median(xs),min=min(xs),max=max(xs),samples=xs)
  for case in cases:
   report['statistics'][case['id']]={}
   for role in config['roles']:
    rows=[x for x in report['rows'] if x['case']==case['id'] and x['role']==role];assert len(rows)==3
    values={k:stats([r['observation'][k] for r in rows]) for k in ['requestMs','hostImportMs','importAndRequestMs','maxRssKiB']}
    values.update(processWallMs=stats([r['execution']['wallSeconds']*1000 for r in rows]),
      peakTreeRssBytes=stats([r['execution']['peakTreeRssBytes'] for r in rows]),
      outputBytes=stats([r['observation']['output']['bytes'] for r in rows]))
    report['statistics'][case['id']][role]=values
  assert len(report['rows'])==18;verify(inputs);report['complete']=report['pass']=True
except BaseException as error:
 report['error']=repr(error);raise
finally:
 report['wallSeconds']=time.monotonic()-started;save(out/'report.json',report)
print(json.dumps(dict(pass_=True,rows=18,report=str(out/'report.json'))))
