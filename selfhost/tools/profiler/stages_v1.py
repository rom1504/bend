#!/usr/bin/env python3
"""Versioned exact-FID stage specifications and offline sampled-stage reports.

No target execution. 'map' materializes a bounded runtime map; 'observe' pins an
existing sidecar and joins exact captured ordinals, ELF identities and quality.
"""
import argparse,collections,hashlib,json,re,sys
from pathlib import Path
sys.dont_write_bytecode=True
from run import pin,verify,save,all_pins,output_matches
import attribute
MODES={'once':0,'first':1,'optional':2}
CLOCKS=('wallNs','cpuNs','threadNs','sampleOrdinal')

def need(v,s):
 if not v:raise ValueError(s)
def read(p):return json.loads(Path(p).read_text())
def validate_spec(spec,owners):
 need(spec.get('schema')=='bend-native-stage-spec-v1','Expected stage spec v1')
 rows=spec['markers'];need(1<=len(rows)<=32,'1..32 markers required')
 by_fid={r['fid']:r for r in owners['fids']};seen=set();fids=set()
 for row in rows:
  label=row['label'];need(isinstance(label,str) and re.fullmatch(r'[A-Za-z0-9_.$:/+\-]{1,128}',label),'Marker label must be a bounded ASCII identifier')
  need(label not in seen and row['fid'] not in fids,'Duplicate marker label or FID');seen.add(label);fids.add(row['fid'])
  need(type(row['fid']) is int and row['fid']>=0,'Invalid FID')
  need(row['multiplicity'] in MODES,'Unknown multiplicity')
  need(row['fid'] in by_fid and by_fid[row['fid']]['symbol']==row['symbol'],'Marker differs from exact owner map')
  need(by_fid[row['fid']]['role']=='direct_segment','Only exact direct dispatcher segments supported')
 required=[r['label'] for r in rows if r['multiplicity']!='optional']
 need(required and spec['requiredOrder']==required,'Required order must match nonoptional marker order')
 for interval in spec['intervals']:
  need(isinstance(interval['label'],str) and interval['begin'] in seen and interval['end'] in seen|{'@exit'},'Unknown interval endpoint')
  need(interval['begin']!=interval['end'],'Empty interval declaration')
 return rows

def map_header(spec,owners,digest):
 rows=validate_spec(spec,owners);maximum=max(r['fid'] for r in rows);need(maximum<65536 and len(owners['fids'])<65536,'Bounded FID map required')
 required={name:i+1 for i,name in enumerate(spec['requiredOrder'])}
 s=f'#include <stdint.h>\n#define BGS_COUNT {len(rows)}u\n#define BGS_MAX_FID {maximum}u\n#define BGS_SEGMENTS {len(owners["fids"])}u\n#define BGS_REQUIRED {len(required)}u\n#define BGS_SPEC_SHA256 "{digest}"\n'
 s+='static const uint8_t bgs_rank[BGS_MAX_FID+1]={'+','.join(f'[{r["fid"]}]={i+1}' for i,r in enumerate(rows))+'};\n'
 for typ,name,values in [('uint32_t','fids',[r['fid'] for r in rows]),('uint8_t','mode',[MODES[r['multiplicity']] for r in rows]),('uint8_t','order',[required.get(r['label'],0) for r in rows])]:s+=f'static const {typ} bgs_{name}[BGS_COUNT]={{'+','.join(map(str,values))+'};\n'
 for name,values in [('labels',[r['label'] for r in rows]),('modes',[r['multiplicity'] for r in rows])]:s+=f'static const char *const bgs_{name}[BGS_COUNT]={{'+','.join(json.dumps(v) for v in values)+'};\n'
 return s

def normalize(raw,spec,digest,legacy=False):
 """Legacy import is explicit, exact and read-only; no failed capture is repaired."""
 if not legacy:
  need(raw.get('schema')=='bend-native-stage-observations-v1' and raw['specSha256']==digest,'Unknown sidecar/schema/spec identity');return raw
 need(raw.get('schema')=='bend-sampled-dispatch-stages-v1','Expected retained legacy dispatch-stage format')
 by_fid={r['fid']:r for r in spec['markers']};markers=[]
 for r in raw['rows']:
  need(r['fid'] in by_fid and by_fid[r['fid']]['label']==r['label'],'Legacy marker differs from spec')
  mode='first' if r['firstEntryBoundary'] else 'once';need(mode==by_fid[r['fid']]['multiplicity'],'Legacy multiplicity changed')
  markers.append(dict(label=r['label'],fid=r['fid'],address=r['address'],multiplicity=mode,entries=r['entries'],truncated=False,observations=[{k:r[k] for k in CLOCKS}] if r['entries'] else [],legacyFirstOnly=True))
 optional=raw.get('conditionalFinalVerifier')
 if optional is not None:
  need(optional['fid'] in by_fid and by_fid[optional['fid']]['multiplicity']=='optional','Legacy conditional point needs explicit optional spec')
  markers.append(dict(label=by_fid[optional['fid']]['label'],fid=optional['fid'],address=optional['address'],multiplicity='optional',entries=optional['entries'],truncated=optional['truncated'],observations=optional['observations']))
 return dict(schema='bend-native-stage-observations-v1',specSha256=digest,complete=raw['complete'],sequentialOnly=raw['sequentialOnly'],expectedSegments=raw['expectedSegments'],requiredObservedInOrder=raw['observedInOrder'],badOrderOrDuplicate=raw['badOrderOrDuplicate'],clockError=raw['clockError'],finish={k:raw['finish'+k[0].upper()+k[1:]] for k in CLOCKS},markers=markers)

def check_observations(spec,owners,side,linked,sample_count,legacy=False):
 rows=validate_spec(spec,owners);need(side['complete'] and side['sequentialOnly'] and not side['badOrderOrDuplicate'] and not side['clockError'],'Stage capture rejected its order/count/clocks')
 need(side['expectedSegments']==len(owners['fids']) and side['requiredObservedInOrder']==len(spec['requiredOrder']),'Stage object/order mismatch')
 got={r['label']:r for r in side['markers']};need(len(got)==len(side['markers'])==len(rows),'Duplicate or missing observed marker')
 finish=side['finish'];need(all(type(finish[k]) is int and finish[k]>=0 for k in CLOCKS) and finish['sampleOrdinal']<=sample_count,'Invalid finish clock/ordinal')
 for want in rows:
  r=got[want['label']];n=r['entries'];need(r['fid']==want['fid'] and r['multiplicity']==want['multiplicity'] and int(r['address'],16)==linked[want['fid']]['elfAddress'],'Observed FID/mode/address mismatch')
  need(type(n) is int and n>=0,'Invalid invocation count')
  if want['multiplicity']=='once':need(n==1,'Required unique stage missing or repeated')
  if want['multiplicity']=='first':need(n>=1,'Required first-entry stage missing')
  expected=min(n,8)
  if legacy and r.get('legacyFirstOnly'):expected=min(n,1)
  need(len(r['observations'])==expected,'Incomplete invocation observations')
  need(r['truncated']==(n>8) or legacy and r.get('legacyFirstOnly') and not r['truncated'],'Invalid truncation evidence')
  previous=None
  for ob in r['observations']:
   need(all(type(ob[k]) is int and 0<=ob[k]<=finish[k] for k in CLOCKS),'Invalid observation clock/ordinal')
   if previous:need(all(previous[k]<=ob[k] for k in CLOCKS),'Nonmonotonic repeated observations')
   previous=ob
 ordered=[got[name]['observations'][0] for name in spec['requiredOrder']]
 need(all(all(a[k]<=b[k] for k in CLOCKS) for a,b in zip(ordered,ordered[1:])),'Required first entries reordered')
 return got

def summarize_intervals(spec,observed,finish,events,quality):
 admitted=all(quality.get(k) for k in ['zero_loss','handler_intact','main_thread_shutdown','thread_lifecycle_complete','near_complete_process_cpu_coverage','delivery_plausible'])
 result=[]
 for interval in spec['intervals']:
  def endpoint(label):
   if label=='@exit':return finish
   r=observed[label]
   return r['observations'][0] if r['entries']==1 or r['multiplicity']=='first' else None
  left,right=endpoint(interval['begin']),endpoint(interval['end']);row={**interval,'available':False}
  if left is None or right is None:row['reason']='Optional endpoint absent or repeated; no single interval inferred';result.append(row);continue
  need(all(left[k]<=right[k] for k in CLOCKS),'Declared interval endpoints reversed')
  first,last=left['sampleOrdinal'],right['sampleOrdinal'];start=min(first+1,last);stop=max(start,last-1);chunk=events[start:stop];n=len(chunk)
  owners=collections.Counter((e.get('dispatchContext')or{}).get('loweredOwner') for e in chunk);leaves=collections.Counter(e['leaf'].get('decoded')or e['leaf'].get('symbol') for e in chunk)
  def top(c):return [dict(name=k,samples=v,fractionOfAllSamples=v/n) for k,v in c.most_common(12)] if n else []
  row.update(available=True,wallSeconds=(right['wallNs']-left['wallNs'])/1e9,processCpuSeconds=(right['cpuNs']-left['cpuNs'])/1e9,threadCpuSeconds=(right['threadNs']-left['threadNs'])/1e9,sampleStartInclusive=start,sampleEndExclusive=stop,samples=n,boundarySamplesExcluded=last-first-n,quantitativeProfileAdmitted=admitted and n>=500,topActiveOwners=top(owners),topPhysicalLeaves=top(leaves));result.append(row)
 return result

def main():
 ap=argparse.ArgumentParser(description=__doc__);sp=ap.add_subparsers(dest='action',required=True)
 m=sp.add_parser('map');m.add_argument('--spec',type=Path,required=True);m.add_argument('--out',type=Path,required=True)
 o=sp.add_parser('observe');o.add_argument('--spec',type=Path,required=True);o.add_argument('--run',type=Path,required=True);o.add_argument('--row',type=int,default=0);o.add_argument('--out',type=Path,required=True);o.add_argument('--legacy-dispatch-v1',action='store_true')
 a=ap.parse_args();need(not a.out.exists(),'Fresh output required');spec=read(a.spec);owners=read(verify(spec['ownerMap']));digest=pin(a.spec)['sha256'];validate_spec(spec,owners)
 if a.action=='map':
  a.out.mkdir(parents=True);(a.out/'stages-map-v1.h').write_text(map_header(spec,owners,digest));support=Path(__file__).with_name('stages-runtime-v1.inc.c');(a.out/support.name).write_bytes(support.read_bytes());save(a.out/'receipt.json',dict(schema='bend-native-stage-map-v1',complete=True,targetsRun=False,inputs=[pin(__file__),pin(a.spec),spec['ownerMap'],pin(support)],outputs=[pin(a.out/'stages-map-v1.h'),pin(a.out/support.name)]));return
 result=dict(schema='bend-native-stage-report-v1',complete=False,targetsRun=False,inputs=[pin(__file__),pin(a.spec),spec['ownerMap'],pin(a.run)])
 try:
  run=read(a.run);need(run['complete'] and run['passed'] and not run['changedInputs'],'Successful immutable exact-output run required');row=run['rows'][a.row]
  need(row['correct'] and row['mode']=='sample' and row['diagnosticRuntime'] and row['timingKind']=='diagnostic','Sampled diagnostic row required')
  for item in run['inputs']:verify(item)
  for key in ['profile','analysis','contexts','callers','stdout','stderr']:verify(row[key])
  matching=[]
  for item in run['inputs']:
   path=Path(item['file'])
   if path.suffix!='.json' or item['bytes']>2000000:continue
   try:candidate=read(path)
   except (UnicodeDecodeError,json.JSONDecodeError):continue
   if not isinstance(candidate,dict) or candidate.get('schema')!='bend-native-profile-workloads-v1':continue
   for workload in candidate['workloads']:
    for variant in workload['variants']:
     if workload['name']==row['workload'] and variant['name']==row['variant'] and variant['command']==row['command']:matching.append((item,variant['expected']))
  need(len(matching)==1,'Unique actual workload oracle manifest required')
  manifest_pin,expected=matching[0]
  need(output_matches(row['stdout']['file'],expected['stdout']) and output_matches(row['stderr']['file'],expected['stderr']),'Independent output contract changed')
  result['outputContract']=dict(manifest=manifest_pin,expected=expected,passed=True)
  if not a.legacy_dispatch_v1:need(pin(a.spec) in run['inputs'],'Native stage spec must be pinned by capture manifest')
  suffix='.stages.json' if a.legacy_dispatch_v1 else '.stages-v1.json';path=Path(row['profile']['file']+suffix);raw=read(path);side=normalize(raw,spec,digest,a.legacy_dispatch_v1)
  result['sidecar']=dict(schema='bend-native-stage-sidecar-binding-v1',identity=pin(path),profile=row['profile'],run=pin(a.run),row=a.row,legacyFormat=a.legacy_dispatch_v1,originalSchema=raw['schema']);result['inputs'].append(pin(path))
  doc,events=attribute.attribute(row['analysis']['file'],row['callers']['file'],verify(spec['unwindTable']),row['contexts']['file'],spec['ownerMap']['file']);need(doc['pairing']['verified'],'Capture pairing failed')
  _,linked,binding=attribute.bind_owners(owners,row['command'][0]);need(binding['elfType']==2,'Exact non-PIE dispatch addresses required')
  observed=check_observations(spec,owners,side,linked,len(events),a.legacy_dispatch_v1)
  result.update(complete=True,requestExact=all(expected[k]['kind']=='exact' for k in ['stdout','stderr']),stageAttributionValid=True,samples=len(events),ownerBinding=binding,quality=doc['quality'],markers=side['markers'],intervals=summarize_intervals(spec,observed,side['finish'],events,doc['quality']),diagnosticWallSeconds=row['wallSeconds'],limits=['Single main-thread sample stream; no concurrent or logical-call-stack claim.','First-entry intervals include continuation/ownership work; optional repeated endpoints do not define a single interval.','Nested/overlapping declared intervals must not be summed.','One sample at either edge excluded for non-atomic clock/ordinal observations. Unknown contexts remain in denominators.','Less than500 samples or failed quality checks allow descriptive distributions only; diagnostic clocks are not clean timings.'])
 except BaseException as error:result['error']=type(error).__name__+': '+str(error)[:500]
 save(a.out,result);print(json.dumps({k:result.get(k) for k in ['complete','samples','error']}));return 0 if result['complete'] else 1
if __name__=='__main__':sys.exit(main())
