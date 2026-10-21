"""Recompute matched timings and physical sample categories, without target execution."""
from pathlib import Path
import collections,hashlib,json,math,statistics
ROOT=Path(__file__).resolve().parents[4];BASE=ROOT/'selfhost/build/phase116';OUT=ROOT/'implementation/phase116/results.json'
def read(p):return json.loads(Path(p).read_text())
def pin(p):
 p=Path(p).resolve();return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
def gm(xs):return math.exp(statistics.mean(math.log(x) for x in xs))
def cat(n):
 if n.startswith('<mapping:'):return 'library'
 if n in ['p111_rt_take','p111_rt_ctor']:return 'constructor_take'
 if n.startswith(('term_drop','rfc_','heap_')) or n in ['p111_rt_keep','p111_rt_sink']:return 'ownership_heap'
 if n in ['work_loop','p111_set_regs','p111_rt_jump','p111_rt_return','p111_rt_frame','p111_rt_apply','p111_rt_resume']:return 'dispatch_transport'
 if n=='p111_rt_op':return 'generic_primitive'
 if n.startswith(('p113d_','p114r_','p112w_')):return 'private_worker'
 return 'other'
clean=read(BASE/'clean01/report.json');native=read(BASE/'native01/report.json');assert clean['complete'] and native['complete'];assert len(clean['rows'])==120 and len(native['rows'])==48
results=dict(kind='phase116-backend-survey',complete=True,inputs=[pin(__file__),pin(BASE/'manifest01.json'),pin(BASE/'clean01/report.json'),pin(BASE/'native01/report.json')],cases=[],nativeProfiles=[],scope='Eight selected diagnostic programs. Different qualified backend producers; matched source, workload and outputs. No new broad45 performance score; profile clocks excluded from timings.')
roles=sorted({r['role'] for r in clean['rows']})
for n in clean['cases']:
 rows=[r for r in clean['rows'] if r['case']==n];assert all(r['correct'] for r in rows)
 med={role:statistics.median(r['elapsedMs'] for r in rows if r['role']==role) for role in roles}
 results['cases'].append(dict(name=n,mediansMs=med,ratiosToUpstreamC={k:v/med['upstream_c'] for k,v in med.items()},selfhostJsOverUpstreamJs=med['selfhost_js']/med['upstream_js'],qbeOverSelfhostC=med['qbe']/med['selfhost_c'],samples=rows))
 for role in ['upstream_c','selfhost_c','qbe']:
  captures=[r for r in native['rows'] if r['case']==n and r['role']==role];assert len(captures)==2;counts=collections.Counter();caps=[];total=0
  for r in captures:
   assert r['correct'];verify(r['analysis']);a=read(r['analysis']['file']);caps.append(dict(periodUs=r['round'],samples=a['header']['samples'],overruns=a['header']['overruns'],usable=a['usable'],coverage=a['coverage']['sampled_thread_cpu_fraction'],analysis=r['analysis']))
   if a['usable']:
    total+=a['header']['samples']
    for s in a['symbols']:counts[(s['name'],s['decoded'])]+=s['samples']
  cats=collections.Counter()
  for (name,_),v in counts.items():cats[cat(name)]+=v
  results['nativeProfiles'].append(dict(case=n,role=role,captures=caps,samples=total,adequate=total>=500 and all(x['usable'] for x in caps),categories={k:dict(samples=v,fraction=v/total) for k,v in cats.items()},symbols=[dict(name=k[0],decoded=k[1],samples=v,fraction=v/total) for k,v in counts.most_common()]))
results['diagnosticSubsetGeomeanRatiosToUpstreamC']={r:gm([c['ratiosToUpstreamC'][r] for c in results['cases']]) for r in roles}
results['totalNativeSamples']=sum(r['samples'] for r in results['nativeProfiles']);results['nativeQualifiedCaptures']=sum(c['usable'] for r in results['nativeProfiles'] for c in r['captures'])
jsPath=BASE/'js-profile01/report.json'
if jsPath.exists() and read(jsPath)['complete']:
 jr=read(jsPath);results['inputs'].append(pin(jsPath));results['jsProfiles']=[]
 for r in jr['rows']:
  assert r['correct'];verify(r['profile']);p=read(r['profile']['file']);nodes={n['id']:n for n in p['nodes']};counts=collections.Counter();dur=collections.Counter()
  for idx,node in enumerate(p.get('samples',[])):
   c=nodes[node]['callFrame'];key=(c['functionName'],c['url'],c['lineNumber']);counts[key]+=1;dur[key]+=p['timeDeltas'][idx]
  total=sum(dur.values());results['jsProfiles'].append(dict(case=r['case'],role=r['role'],profile=r['profile'],sampledMicroseconds=total,scope='V8 CPU sample ticks include startup/JIT/GC; source functions are leaves, not inclusive costs.',leaves=[dict(function=k[0],url=k[1],line=k[2]+1,microseconds=v,fraction=v/total,samples=counts[k]) for k,v in dur.most_common(25)]))
cp=BASE/'compiler01/report.json'
if cp.exists() and read(cp)['complete']:
 cr=read(cp);results['inputs'].append(pin(cp));counts=collections.Counter();total=0;captures=[]
 for r in cr['rows']:
  assert r['correct']
  if not r['periodUs']:continue
  a=read(r['analysis']['file']);captures.append(dict(samples=a['header']['samples'],overruns=a['header']['overruns'],usable=a['usable'],profile=r['analysis']))
  if a['usable']:
   total+=a['header']['samples']
   for s in a['symbols']:counts[(s['name'],s['decoded'])]+=s['samples']
 results['compilerProfile']=dict(samples=total,captures=captures,cleanRequestSeconds=[r['seconds'] for r in cr['rows'] if not r['periodUs']],leaves=[dict(name=k[0],decoded=k[1],samples=v,fraction=v/total) for k,v in counts.most_common(30)])
OUT.write_text(json.dumps(results,indent=2)+'\n');print(json.dumps(dict(geomeans=results['diagnosticSubsetGeomeanRatiosToUpstreamC'],nativeSamples=results['totalNativeSamples'],usableCaptures=results['nativeQualifiedCaptures'])))
for c in results['cases']:print(c['name'],{k:round(v,2) for k,v in c['ratiosToUpstreamC'].items()})
