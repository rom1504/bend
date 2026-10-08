#!/usr/bin/env python3
"""Read-only exact named ancestry census; shared SCC workers are never member claims."""
import argparse, collections, hashlib, importlib.util, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6]
METHOD=ROOT/'selfhost/tools/performance/phase62/analysis/profiles-v2.py'
TARGETS=['subst_node','subst_terms','core_apply_span','core_beta','jd_calls_named','jd_arity','jd_live_arity','rawarity','jd_rawarity','jd_raw_arity','jd_calls_row_arity','jd_text_scan','jd_text_marker','jd_ordered_bindings','String.contains']
def pin(p):
 p=Path(p).resolve(strict=True);h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return dict(file=str(p),sha256=h.hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(p):assert pin(p['file'])=={k:p[k] for k in ['file','sha256']}
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--cpu',type=Path,required=True);p.add_argument('--allocation',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();assert not a.out.exists()
 assert pin(METHOD)['sha256']=='4fb715bddc5262f6c7b53d869840f46d225cd3eed2b9ae3b53cdb0ee00bb3679'
 spec=importlib.util.spec_from_file_location('reviewed_names',METHOD);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 rows=[];inputs=[pin(a.cpu),pin(a.allocation),pin(METHOD)]
 for mode,evidence in [('cpu',a.cpu),('allocation',a.allocation)]:
  prior=read(evidence);assert prior['complete'] and prior['pass']
  for row in prior['rows']:
   if row['role']!='baseline':continue
   verify(row['raw']);verify(row['worker']);raw=read(row['raw']['file']);worker=read(row['worker']['file']);image=worker['image'];verify(image['api']);api=Path(image['api']['file']).as_uri()
   nodes={};parents={}
   if mode=='cpu':
    nodes={n['id']:n for n in raw['nodes']}
    for n in nodes.values():
     for child in n.get('children',[]):assert child not in parents;parents[child]=n['id']
    admitted=row['weightedStatus']=='admitted';weights=[max(v,0) for v in raw['timeDeltas']] if admitted else [None]*len(raw['samples'])
    if admitted:assert sum(weights)==row['weightedAccounting']['admittedWeightedUs']
    samples=list(zip(raw['samples'],weights));unit='microseconds' if admitted else None
   else:
    todo=[(raw['head'],None)]
    while todo:
     n,parent=todo.pop();assert n['id'] not in nodes;nodes[n['id']]=n;parents[n['id']]=parent;todo.extend((c,n['id']) for c in n.get('children',[]))
    samples=[(s['nodeId'],s['size']) for s in raw['samples']];unit='sampled-allocation-bytes';assert sum(w for _,w in samples)==row['sampleBytes']
   stats={name:dict(inclusiveCount=0,selfCount=0,inclusiveWeight=0,selfWeight=0,nearestNamedCallers=collections.Counter(),callerWeights=collections.Counter()) for name in TARGETS};shared=collections.Counter();sharedWeight=collections.Counter();absent=0;cache={}
   for nid,weight in samples:
    if nid not in nodes:absent+=1;continue
    if nid not in cache:
     stack=[];seen=set();cursor=nid
     while cursor is not None:
      assert cursor not in seen;seen.add(cursor);frame=nodes[cursor]['callFrame'];name=m.decoded(frame['functionName']) if frame.get('url')==api else None;stack.append((frame,name));cursor=parents.get(cursor)
     cache[nid]=stack
    stack=cache[nid]
    sharedNames={f['functionName'] for f,n in stack if f.get('url')==api and f['functionName'].endswith('$scc') and any(x in (m.decoded(f['functionName'][:-4]) or '') for x in ['subst','arity','jd_calls','jd_text','jd_ordered','String.contains'])}
    for name in sharedNames:shared[name]+=1;sharedWeight[name]+=weight or 0
    for target in TARGETS:
     indexes=[i for i,(_,n) in enumerate(stack) if n==target]
     if not indexes:continue
     s=stats[target];s['inclusiveCount']+=1;s['inclusiveWeight']+=weight or 0
     if indexes[0]==0:s['selfCount']+=1;s['selfWeight']+=weight or 0
     # Innermost matching frame once per sample; skip recursion/anonymous/SCC
     # to name the nearest exact generated caller, not an asserted direct call.
     caller=next((n for _,n in stack[indexes[0]+1:] if n and n!=target and (target!='String.contains' or not n.startswith('String.'))),'[no exact generated ancestor]')
     s['nearestNamedCallers'][caller]+=1;s['callerWeights'][caller]+=weight or 0
   total=len(samples);totalWeight=sum(w or 0 for _,w in samples)
   targets=[]
   for target,s in stats.items():
    item=dict(name=target,inclusiveSamples=s['inclusiveCount'],selfSamples=s['selfCount'],inclusivePercent=100*s['inclusiveCount']/total if total else 0,nearestExactGeneratedAncestors=[dict(name=k,samples=v,**({'weight':s['callerWeights'][k]} if unit else {})) for k,v in s['nearestNamedCallers'].most_common(5)])
    if unit:item.update(inclusiveWeight=s['inclusiveWeight'],selfWeight=s['selfWeight'],inclusiveWeightPercent=100*s['inclusiveWeight']/totalWeight if totalWeight else 0)
    targets.append(item)
   out=dict(mode=mode,case=row['case'],role='baseline',worker=row['worker'],raw=row['raw'],api=image['api'],sampleEvents=total,absentTreeSamples=absent,weightUnit=unit,targets=targets,sharedWorkerAncestorUnions=[dict(functionName=k,samples=v,**({'weight':sharedWeight[k]} if unit else {})) for k,v in shared.most_common(10)])
   if unit:out['totalWeight']=totalWeight
   if mode=='cpu':out['weightedStatus']=row['weightedStatus']
   else:out.update(treeSelfBytes=row['treeSelfBytes'],accountingMismatchNodes=row['accountingMismatchNodes'])
   rows.append(out)
 assert len(rows)==8 and all({r['case'] for r in rows if r['mode']==mode}=={'numeric-recurrence','lexer','test-map-set-ops','raytrace-active'} for mode in ['cpu','allocation'])
 result=dict(kind='phase65-target-function-ancestry',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,producer=pin(__file__),inputs=inputs,rows=rows,scope='Raw profiles remain unchanged. CPU sample counts always retained; weighted view only where prior reviewed accounting admits timeDeltas. Allocation uses samples[].size exclusively and retains tree-self mismatch metadata. Exact API URL plus decoded non-SCC names identify wrappers. Inclusive target unions overlap. Nearest exact generated ancestor skips anonymous/shared-worker/recursive frames and is not an asserted direct caller. String.contains additionally skips every String.* ancestor. Shared SCC labels name dispatchers, never attribute cost to one member; absent exact names mean unobserved names, not zero execution. First windows include import/API load and instrumentation overhead; no clean-speed or removable-cost claim.')
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(output=pin(a.out),rows=len(rows))))
if __name__=='__main__':main()
