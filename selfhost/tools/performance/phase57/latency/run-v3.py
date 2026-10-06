#!/usr/bin/env python3
"""Diagnostic successor with ordered trace markers and bounded signed-delta CPU summary."""
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
p.add_argument('--cases',default='test-evening-program,lexer')
p.add_argument('--roles',default='typescript,raw,source,direct')
p.add_argument('--rounds',type=int,default=3)
p.add_argument('--mode',choices=['cpu','allocation','trace'],default='cpu')
p.add_argument('--preparations',type=Path,help='Reuse a completed Phase57 report with matching prepared roles/cases/images')
p.add_argument('--prepare-only',action='store_true',help='Prepare/check outputs and caches; launch no measurement samples')
p.add_argument('--profile-ms',type=int,default=5000)
p.add_argument('--seconds',type=int,default=1800)
p.add_argument('--child-seconds',type=int,default=180)
a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase57') and not out.exists()
assert 1<=a.rounds<=8 and 100<=a.profile_ms<=10000 and 60<=a.seconds<=3600 and 10<=a.child_seconds<=600
roles=a.roles.split(',');assert roles and len(set(roles))==len(roles) and set(roles)<={'typescript','raw','source','direct'}
names=a.cases.split(',');assert names and len(set(names))==len(names)
def identity(file):
 file=Path(file).resolve(strict=True);h=hashlib.sha256()
 with file.open('rb') as stream:
  for block in iter(lambda:stream.read(2**20),b''):h.update(block)
 return dict(file=str(file),sha256=h.hexdigest())
def read(file):return json.loads(Path(file).read_text())
def verify(items):
 for item in items:assert identity(item['file'])=={k:item[k] for k in ['file','sha256']},item['file']
upstream=a.upstream.resolve();node=a.node.resolve();catalog=HERE.parents[1]/'phase37/catalog.json'
assert subprocess.check_output(['git','-C',str(upstream),'rev-parse','HEAD'],text=True).strip()==PIN
subprocess.run(['git','-C',str(upstream),'diff','--exit-code','HEAD','--','bend2'],check=True,stdout=subprocess.DEVNULL)
cat=read(catalog);assert cat['upstreamCommit']==PIN
cases=[]
for name in names:
 row=next(x for x in cat['cases'] if x['id']==name);assert not row.get('adapter')
 source=identity(catalog.parent/row['source']['path']);assert source['sha256']==row['source']['sha256']
 cases.append(dict(id=name,source=source,point=row['point']))
image_pins=read(a.image_pins);assert image_pins['kind']=='phase56-direct-image-pins'
assert identity(HERE.parent/'profile-v2.mjs')['sha256']=='f472c5e565827e7a8cfc4181e19dffe61f4485c63a3d137c1315c82e388064f6','Unreviewed profiling helper'
inputs=[identity(x) for x in [__file__,HERE/'worker-v3.mjs',HERE/'run.py',HERE/'worker.mjs',HERE/'run-v2.py',HERE/'worker-v2.mjs',HERE/'trace-markers-v2.json',HERE/'profile-successor-v3.json',HERE.parent/'setup.mjs',HERE.parent/'profile-v2.mjs',
 HERE.parents[1]/'phase54/bootstrap/adapter.mjs',ROOT/'selfhost/tools/development/workflow.mjs',
 ROOT/'selfhost/tools/development/process.mjs',ROOT/'selfhost/tools/conformance/inventory.mjs',
 PROGRAMS/'support.py',PROGRAMS/'profile.mjs',catalog,node,a.image_pins,
 *[upstream/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]]]+[x['source'] for x in cases]
reuse=None
if a.preparations:
 assert a.preparations.resolve().is_relative_to(ROOT/'selfhost/build/phase57')
 reuse=read(a.preparations);assert reuse['kind']=='phase57-four-image-library-latency' and reuse['complete'] and reuse['pass']
 inputs.append(identity(a.preparations));verify([reuse['config']]);old=read(reuse['config']['file'])
 assert old['imagePins']==identity(a.image_pins) and old['upstream']==str(upstream) and old['node']==identity(node)
 for row in cases:assert row in old['cases']
 assert set(roles)<=set(old['roles'])
verify(inputs);out.mkdir(parents=True);assert out.resolve().is_relative_to((ROOT/'selfhost/build/phase57').resolve())
config=dict(kind='phase57-four-image-library-plan',roles=roles,rounds=a.rounds,backend='direct',mode=a.mode,
 prepareOnly=a.prepare_only,
 imagePins=identity(a.image_pins),node=identity(node),upstream=str(upstream),upstreamCommit=PIN,cases=cases,inputs=inputs,
 warmRequests=3,profile=dict(targetMs=a.profile_ms,maxRequests=32,samplingIntervalUs=1000,samplingIntervalBytes=131072),
 resources=dict(cpu=3,heapMiB=1024,rssMiB=2048,availableMiB=4096,secondsPerChild=a.child_seconds,totalSeconds=a.seconds),
 protocol='Fresh process per role/case/round. Private Bend Base disk caches primed once outside samples. Explicit ordinary API load then first ordinary library request and three more requests; no persistent inspector. TS imports include its compiler. Cyclic role rotation; three rounds do not fully balance four role positions. Profiles/traces are separate diagnostic processes, never clean timing.')
save(out/'plan.json',config);config_id=identity(out/'plan.json')
report=dict(kind='phase57-four-image-library-latency',complete=False,config=config_id,mode=a.mode,
 preparations=[],rows=[],statistics={},inputs=inputs)
report['pass']=False;save(out/'report.json',report);started=time.monotonic()
def launch(guard,request,prefix):
 verify(inputs);request_file=Path(str(prefix)+'.request.json');result_file=Path(str(prefix)+'.result.json')
 save(request_file,{**request,'config':config_id})
 flags=['--trace-opt','--trace-deopt','--trace-gc-nvp'] if a.mode=='trace' and request['stage']=='sample' else []
 execution=guard.run(['taskset','-c','3',str(node),'--stack-size=4096','--max-old-space-size=1024',*flags,
  str(HERE/'worker-v3.mjs'),str(request_file),str(result_file)],Path(str(prefix)+'-process'),min(started+a.seconds,time.monotonic()+a.child_seconds))
 observation=read(result_file) if result_file.exists() else None
 entry=dict(execution=execution,observation=observation,result=identity(result_file) if result_file.exists() else None)
 report['preparations' if request['stage']=='prepare' else 'rows'].append(entry);save(out/'report.json',report)
 assert execution['complete'] and execution.get('returncode')==0 and observation and observation['complete'] and observation['pass'],entry
 assert observation['affinity'].split(':',1)[1].strip()=='3'
 verify(inputs);return entry
try:
 with ExecutionGuard(rss_mib=2048,available_mib=4096) as guard:
  preparations={}
  for role in roles:
   if reuse:
    row=next(x for x in reuse['preparations'] if x['observation']['role']==role)
    verify([row['result']]);assert row['observation']==read(row['result']['file'])
    report['preparations'].append(row)
   else:
    dest=out/('prepare-'+role);dest.mkdir()
    row=launch(guard,dict(stage='prepare',role=role,out=str(dest)),out/('prepare-'+role))
   preparations[role]=row
  report['preparationsReusedFrom']=identity(a.preparations) if reuse else None
  report['exactBendOutputComparisons']=[]
  for case in cases:
   bend_roles=[r for r in roles if r!='typescript']
   outputs=[next(x for x in preparations[r]['observation']['outputs'] if x['id']==case['id'])['output'] for r in bend_roles]
   verify(outputs)
   if outputs:
    for x in outputs[1:]:assert Path(outputs[0]['file']).read_bytes()==Path(x['file']).read_bytes(),'Bend compiler outputs differ'
   report['exactBendOutputComparisons'].append(dict(case=case['id'],roles=bend_roles,outputs=outputs,compared=len(outputs)>1))
  report['preparationSeconds']=time.monotonic()-started;timing_start=time.monotonic()
  for case in ([] if a.prepare_only else cases):
   for sample in range(a.rounds):
    offset=sample%len(roles);order=roles[offset:]+roles[:offset]
    for role in order:
     prefix=out/(case['id']+'-'+str(sample)+'-'+role)
     row=launch(guard,dict(stage='sample',role=role,case=case['id'],sample=sample,
      preparation=preparations[role]['result'],output=str(prefix)+'.mjs',profileOut=str(prefix)+'-profile'),prefix)
     row.update(case=case['id'],sample=sample,role=role);save(out/'report.json',report)
  report['measurementStageSeconds']=time.monotonic()-timing_start
  def stats(xs):return dict(median=statistics.median(xs),min=min(xs),max=max(xs),samples=xs)
  if a.mode=='clean' and not a.prepare_only:
   for case in cases:
    report['statistics'][case['id']]={}
    for role in roles:
     rows=[x for x in report['rows'] if x['case']==case['id'] and x['role']==role];assert len(rows)==a.rounds
     values={k:stats([r['observation'][k] for r in rows]) for k in ['firstRequestMs','hostImportMs','apiLoadMs','importApiAndFirstMs','maxRssKiB']}
     warm=[[x['requestMs'] for x in r['observation']['warmRequests']] for r in rows];assert all(len(x)==3 for x in warm)
     values.update(warmRequestMedianMs=stats([statistics.median(x) for x in warm]),warmRequestMsByProcess=warm,
       processWallMs=stats([r['execution']['wallSeconds']*1000 for r in rows]),
       peakTreeRssBytes=stats([r['execution']['peakTreeRssBytes'] for r in rows]),
       outputBytes=stats([r['observation']['output']['bytes'] for r in rows]))
     report['statistics'][case['id']][role]=values
  assert len(report['rows'])==(0 if a.prepare_only else len(cases)*len(roles)*a.rounds)
  verify(inputs);report['complete']=report['pass']=True
except BaseException as error:
 report['error']=repr(error);raise
finally:
 report['wallSeconds']=time.monotonic()-started;save(out/'report.json',report)
print(json.dumps(dict(pass_=True,rows=len(report['rows']),mode=a.mode,report=str(out/'report.json'))))
