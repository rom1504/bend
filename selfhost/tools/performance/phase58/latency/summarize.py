#!/usr/bin/env python3
"""Saved-data latency/allocation/emission summary; never executes a compiler."""
import argparse, ast, hashlib, json, math, statistics
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]; TOOLS=HERE.parents[1]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('out',type=Path)
p.add_argument('--latency',type=Path,action='append',default=[])
p.add_argument('--emission',action='append',default=[],help='Unique label=completed own-source report.json')
a=p.parse_args();out=a.out.resolve();assert not out.exists() and (out.is_relative_to(ROOT/'selfhost/build/phase58') or out.is_relative_to(ROOT/'implementation/phase58'))
assert a.latency or a.emission;inputs={}
def digest(file):
 h=hashlib.sha256()
 with file.open('rb') as stream:
  for block in iter(lambda:stream.read(2**20),b''):h.update(block)
 return dict(file=str(file),sha256=h.hexdigest(),bytes=file.stat().st_size)
def pin(value):
 file=Path(value['file'] if isinstance(value,dict) else value).resolve(strict=True)
 row=inputs.get(str(file)) or digest(file)
 if isinstance(value,dict):
  assert row['sha256']==value['sha256'],file
  if 'bytes' in value:assert row['bytes']==value['bytes'],file
 inputs[str(file)]=row;return row
def read(value):
 row=pin(value);assert row['bytes']<=128*2**20,'Bounded JSON input'
 return row,json.loads(Path(row['file']).read_text())
def finite(x):return isinstance(x,(int,float)) and not isinstance(x,bool) and math.isfinite(x) and x>=0
def approx(x,y):assert math.isclose(x,y,rel_tol=1e-10,abs_tol=.001),(x,y)
def stats(xs):
 assert xs and all(finite(x) for x in xs)
 return dict(median=statistics.median(xs),min=min(xs),max=max(xs),samples=xs)
def ratios(values):
 result={}
 if 'baseline' in values and 'candidate' in values:
  b=values['baseline']['median'];c=values['candidate']['median'];assert b>0 and c>0
  result.update(baselineOverCandidate=b/c,candidateTimeChangePercent=100*(c/b-1))
 if 'typescript' in values:
  t=values['typescript']['median'];assert t>0
  result['overTypeScript']={role:value['median']/t for role,value in values.items() if role!='typescript'}
 return result

producer=pin(__file__)
# Reuse only the reviewed pure CPU accounting validator, not its CLI or inventory.
method=pin(TOOLS/'phase57/analysis/profiles-v2.py')
assert method['sha256']=='ab678fb32d51d497009d5e1ffbae3ffbba4fdae27973b47546d2b5859d7c0d19'
node=next(x for x in ast.parse(Path(method['file']).read_text()).body if isinstance(x,ast.FunctionDef) and x.name=='cpu_views')
scope=dict(read=read,finite=finite,approx=approx)
exec(compile(ast.Module(body=[node],type_ignores=[]),method['file'],'exec'),scope);cpu_views=scope['cpu_views']
def profile(inline):
 rid,r=read(inline['receipt']);assert r=={k:v for k,v in inline.items() if k!='receipt'}
 assert r['complete'] and r['pass'] and r['diagnosticOnly'] and r['calls']>0
 assert r['calls']==len(r['requestMs']) and all(finite(x) for x in r['requestMs'])
 for key in ['producer','predecessor','summaryMethod','node']:
  if key in r:pin(r[key])
 raw_id,raw=read(r['raw']);summary_id,s=read(r['summary'])
 assert s['sampleCount']==r['totals']['sampleCount'];approx(s['totalWeight'],r['totals']['totalWeight'])
 if r['mode']=='cpu':cpu_views(raw,s,r)
 else:
  assert r['mode']=='allocation' and s['unit']=='estimated-allocated-bytes'
  assert r['sampling']['includeObjectsCollectedByMajorGC'] and r['sampling']['includeObjectsCollectedByMinorGC']
  assert len(raw['samples'])==s['sampleCount'] and all(finite(x['size']) for x in raw['samples'])
  approx(sum(x['size'] for x in raw['samples']),s['totalWeight'])
 approx(sum(x['selfWeight'] for x in s['frames']),s['totalWeight'])
 account=dict(s.get('accounting',{}));disagreements=account.pop('nodeWeightDisagreements',[])
 if disagreements:account['nodeWeightDisagreementCount']=len(disagreements)
 return dict(receipt=rid,raw=raw_id,summary=summary_id,mode=r['mode'],sampling=r['sampling'],
  calls=r['calls'],requestMs=r['requestMs'],workloadMs=r['workloadMs'],unit=s['unit'],sampleCount=s['sampleCount'],
  totalWeight=s['totalWeight'],estimatedAllocationBytesPerRequest=s['totalWeight']/r['calls'] if r['mode']=='allocation' else None,
  summaryView=r.get('summaryView','allocation'),weightedStatus=r.get('weightedStatus'),accounting=account,
  topSelf=sorted(s['frames'],key=lambda x:-x['selfWeight'])[:12],warnings=s['warnings'])

campaigns=[]
for source in a.latency:
 report_id,r=read(source);assert r['kind']=='phase58-candidate-image-library-latency' and r['complete'] and r['pass']
 pin(r['methodDerivation'])
 config_id,c=read(r['config']);assert c['kind']=='phase58-candidate-image-library-plan' and c['mode']==r['mode'] and not c['prepareOnly']
 for item in c['inputs']:pin(item)
 rows={};diagnostics=[];prepared={}
 expected=[(case['id'],role,n) for case in c['cases'] for n in range(c['rounds']) for role in c['roles'][n%len(c['roles']):]+c['roles'][:n%len(c['roles'])]]
 assert [(x['case'],x['role'],x['sample']) for x in r['rows']]==expected
 for row in r['rows']:
  worker_id,w=read(row['result']);assert w==row['observation'] and row['execution']['complete'] and row['execution']['returncode']==0
  assert w['complete'] and w['pass'] and w['config']==r['config'] and w['role']==row['role'] and w['sample']==row['sample']
  assert w['mode']==r['mode'] and w['cleanTiming']==(r['mode']=='clean')
  _,request=read(w['request']);assert request['config']==w['config'] and request['role']==row['role'] and request['case']==row['case']
  _,prep=read(w['preparation']);assert prep['complete'] and prep['pass'] and prep['role']==row['role']
  _,pc=read(prep['config']);assert pc['imageBindings']==c['imageBindings'] and pc['node']==c['node'] and pc['upstreamCommit']==c['upstreamCommit']
  for item in pc['inputs']+prep.get('inputs',[]):pin(item)
  for item in prep.get('copies',[]):pin(item['before']);pin(item['after'])
  for item in prep.get('verification',{}).get('cacheFiles',[]):pin(item)
  case=next(x for x in c['cases'] if x['id']==row['case']);assert case in pc['cases'] and w['source']==case['source']
  oracle=next(x for x in prep['outputs'] if x['id']==row['case'])
  assert oracle['source']==case['source']
  assert oracle['oracle']['pass'] and oracle['oracle']['point']==case['point'] and oracle['oracle']['value']==case['point']['expected']
  assert w['expected']==oracle['output'];pin(w['expected']);pin(w['output']);assert w['output']['sha256']==w['expected']['sha256']
  assert len(w['warmRequests'])==c['warmRequests']
  for x in w['warmRequests']:assert x['output']=={k:w['expected'][k] for k in ['sha256','bytes']}
  approx(w['importApiAndFirstMs'],sum(w[k] for k in ['hostImportMs','apiLoadMs','firstRequestMs']))
  if row['role']!='typescript':assert w['image']==prep['image']
  prepared[row['role']]=dict(image=prep.get('image'),subject=prep.get('subject'),preparation=w['preparation'])
  rows.setdefault((row['case'],row['role']),[]).append((row,w))
  assert ('profile' in w)==(r['mode'] in ['cpu','allocation'])
  if 'profile' in w:
   assert w['profile']['mode']==r['mode']
   assert any(x['file']==w['profile']['producer']['file'] and x['sha256']==w['profile']['producer']['sha256'] for x in c['inputs'])
   pr=profile(w['profile']);pr.update(case=row['case'],role=row['role'],sample=row['sample'],worker=worker_id)
   expected_url=Path(w['image']['api']['file'] if row['role']!='typescript' else Path(c['upstream'])/'bend2/comp.ts').resolve().as_uri()
   assert w['profile']['moduleUrl']==expected_url;diagnostics.append(pr)
 cases={}
 if r['mode']=='clean':
  for case in c['cases']:
   roles={}
   for role in c['roles']:
    pairs=rows[(case['id'],role)];values={k:stats([w[k] for _,w in pairs]) for k in ['hostImportMs','apiLoadMs','firstRequestMs','importApiAndFirstMs']}
    warm=[[x['requestMs'] for x in w['warmRequests']] for _,w in pairs]
    values.update(warmRequestMedianMs=stats([statistics.median(x) for x in warm]),warmRequestMsByProcess=warm,
     processWallMs=stats([e['execution']['wallSeconds']*1000 for e,_ in pairs]),peakTreeRssBytes=stats([e['execution']['peakTreeRssBytes'] for e,_ in pairs]))
    for key,value in values.items():
     if isinstance(value,dict):
      saved=r['statistics'][case['id']][role][key]
      for field in ['median','min','max']:approx(value[field],saved[field])
      assert value['samples']==saved['samples']
    roles[role]=values
   cases[case['id']]=dict(roles=roles,ratios={key:ratios({role:vals[key] for role,vals in roles.items()}) for key in ['firstRequestMs','importApiAndFirstMs','warmRequestMedianMs','processWallMs']})
 alloc={}
 for case in c['cases']:
  vals={role:stats([x['estimatedAllocationBytesPerRequest'] for x in diagnostics if x['case']==case['id'] and x['role']==role]) for role in c['roles']} if r['mode']=='allocation' else {}
  if vals:alloc[case['id']]=dict(roles=vals,ratios=ratios(vals),scope='Sampled cumulative allocation/request, not retained size, RSS or timing.')
 campaigns.append(dict(report=report_id,config=config_id,mode=r['mode'],comparison=c['comparison'],roles=prepared,
  workers=len(r['rows']),ordinaryRequests=len(r['rows'])*(1+c['warmRequests']),wallSeconds=r['wallSeconds'],
  preparationSeconds=r['preparationSeconds'],cases=cases,profiles=diagnostics,allocation=alloc))

emissions=[];labels=set()
for arg in a.emission:
 label,file=arg.split('=',1);assert label and label not in labels;labels.add(label)
 rid,r=read(file);assert r['kind'] in ['phase58-b2-own-source-emission','phase56-direct-self-emission-v2']
 assert r['complete'] and r['pass'] and r['byteEquality']
 for item in r['inputs']:pin(item)
 for item in r['copies']:pin(item['before']);pin(item['after'])
 b2,b3=pin(r['b2']),pin(r['b3']);assert b2['sha256']==b3['sha256'] and b2['bytes']==b3['bytes']
 pin(r['subject']['source']);pin(r['progress']);pin(r['producer'])
 _,original=read(r['image']['emission']);assert original['complete'] and original['pass'] and original['subject']==r['subject']
 assert original['module']['sha256']==b2['sha256'] and original['selected']==r['selected'] and original['roots']==r['roots']
 clean=r.get('mode','clean')=='clean';phases=[];seen=set()
 for row in r['phases']:
  assert row['name'] not in seen and finite(row['seconds']);seen.add(row['name'])
  item=dict(name=row['name'],seconds=row['seconds'],captureSeconds=row.get('captureSeconds'))
  if row.get('profile'):
   assert not clean and row['profile']['calls']==1
   assert row['profile']['moduleUrl']==Path(r['image']['api']['file']).resolve().as_uri()
   item['profile']=profile(row['profile'])
  phases.append(item)
 assert {'emitted-reachability','unsplit-library'}<=seen
 emissions.append(dict(label=label,report=rid,clean=clean,subject=r['subject'],image=r['image'],selected=r['selected'],
  b2=b2,b3=b3,roots=r['roots'],seconds=r['seconds'],stageSecondsSum=sum(x['seconds'] for x in phases),phases=phases,
  scope='One own-source emission with exact per-image bytes. Inspector ratios excluded; different source/driver/setup clocks prevent isolated lookup attribution. Worker receipts are checked; external supervisor status is not inferred.'))

for row in list(inputs.values()):assert digest(Path(row['file']))==row,'Input changed during read'
result=dict(kind='phase58-latency-emission-analysis',complete=True,dataOnly=True,targetExecuted=False,
 producer=producer,cpuValidationMethod=method,campaigns=campaigns,emissions=emissions,
 inputs=list(inputs.values()),scope='Independent saved-data medians and ratios. Later-request statistic is the median of per-process medians, not a stationary rate. Observed ranges are not confidence intervals. Profiles and own-source observations are separate; no pooling of campaigns or guessed time attribution.')
result['pass']=True
out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(output=pin(out),campaigns=len(campaigns),emissions=len(emissions))))
