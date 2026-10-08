#!/usr/bin/env python3
"""Exact constructor_exists ancestry from existing Phase65 CPU/allocation evidence."""
import collections, importlib.util, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6]
HELPER=Path(__file__).with_name('target-ancestry.py')
spec=importlib.util.spec_from_file_location('target_helpers',HELPER);h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
assert h.pin(HELPER)['sha256']=="d53d33bbd8647b1b67994da43e0182dce279bc720685f969fa2cc1cb25bd2961"
spec=importlib.util.spec_from_file_location('profile_names',h.METHOD);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
assert h.pin(h.METHOD)['sha256']=='4fb715bddc5262f6c7b53d869840f46d225cd3eed2b9ae3b53cdb0ee00bb3679'
m.GENERATED_BOUNDARIES.update({'jd_plan_selected':'plan-selection','jd_plan_library':'final-library','book_context_world':'book-context-world','f_prefix_complete_ready_seed':'source-completion'})
rows=[];inputs=[h.pin(HELPER),h.pin(h.METHOD)]
for mode in ['cpu','allocation']:
 f=ROOT/f'implementation/phase65/evidence/baseline-state09-{mode}.json';inputs.append(h.pin(f));e=h.read(f);assert e['complete'] and e['pass']
 for row in e['rows']:
  if row['role']!='baseline':continue
  for k in ['raw','worker']:h.verify(row[k])
  raw=h.read(row['raw']['file']);worker=h.read(row['worker']['file']);api=Path(worker['image']['api']['file']).as_uri();driver=Path(worker['image']['driver']['file']).as_uri();nodes={};parents={}
  if mode=='cpu':
   nodes={n['id']:n for n in raw['nodes']}
   for n in nodes.values():
    for child in n.get('children',[]):assert child not in parents;parents[child]=n['id']
   admitted=row['weightedStatus']=='admitted';weights=[max(x,0) for x in raw['timeDeltas']] if admitted else [0]*len(raw['samples']);samples=list(zip(raw['samples'],weights));unit='microseconds' if admitted else None
  else:
   todo=[(raw['head'],None)]
   while todo:
    n,parent=todo.pop();nodes[n['id']]=n;parents[n['id']]=parent;todo.extend((c,n['id']) for c in n.get('children',[]))
   samples=[(s['nodeId'],s['size']) for s in raw['samples']];unit='sampled-allocation-bytes'
  total=0;weight=0;selfcount=0;selfweight=0;callers=collections.Counter();callerweights=collections.Counter();stages=collections.Counter();stageweights=collections.Counter();unions=collections.Counter();unionweights=collections.Counter();cache={}
  for nid,w in samples:
   if nid not in nodes:continue
   if nid not in cache:
    stack=[];cursor=nid;seen=set()
    while cursor is not None:
     assert cursor not in seen;seen.add(cursor);stack.append(nodes[cursor]['callFrame']);cursor=parents.get(cursor)
    cache[nid]=stack
   stack=cache[nid];names=[m.decoded(f['functionName']) if f.get('url')==api else None for f in stack]
   matches=[i for i,n in enumerate(names) if n=='constructor_exists']
   if not matches:continue
   i=matches[0];total+=1;weight+=w;selfcount+=int(i==0);selfweight+=w if i==0 else 0
   caller=next((n for n in names[i+1:] if n and not n.startswith('constructor_')),'[no exact generated ancestor]');callers[caller]+=1;callerweights[caller]+=w
   stage=m.classify(stack,api,driver,ROOT/'selfhost/.bootstrap/upstream-phase23');stages[stage]+=1;stageweights[stage]+=w
   for name in ['base_prefix_ctor_disjoint','base_prefix_world_admitted','book_context_world','check_program_diagnostic_world','constructor_names','check_book']:
    if name in names:unions[name]+=1;unionweights[name]+=w
  def table(counts,weights):return [dict(name=k,samples=v,**({'weight':weights[k]} if unit else {})) for k,v in counts.most_common()]
  out=dict(mode=mode,case=row['case'],raw=row['raw'],worker=row['worker'],totalProfileSamples=len(samples),weightUnit=unit,constructorExistsInclusiveSamples=total,constructorExistsSelfSamples=selfcount,inclusiveSamplePercent=100*total/len(samples),nearestExactNonConstructorAncestors=table(callers,callerweights),disjointNearestStages=table(stages,stageweights),overlappingAncestorUnions=table(unions,unionweights))
  if unit:out.update(totalProfileWeight=sum(w for _,w in samples),constructorExistsInclusiveWeight=weight,constructorExistsSelfWeight=selfweight,inclusiveWeightPercent=100*weight/sum(w for _,w in samples))
  if mode=='allocation':out.update(treeSelfBytes=row['treeSelfBytes'],accountingMismatchNodes=row['accountingMismatchNodes'])
  else:out['weightedStatus']=row['weightedStatus']
  rows.append(out)
assert len(rows)==8
snapshot=ROOT/'selfhost/build/phase64/checked-state09/snapshot';sources=[snapshot/'src/check/prefix-state.bend',snapshot/'src/check/kernel.bend'];inputs.extend(h.pin(p) for p in sources)
result=dict(kind='phase65-constructor-exists-ancestry',complete=True,**{'pass':True},dataOnly=True,targetExecuted=False,producer=h.pin(__file__),inputs=inputs,rows=rows,scope='Exact non-SCC constructor_exists frame and exact API URL only. Each matching sample counted once. Disjoint stage partition uses nearest named boundary; ancestor unions overlap and must not be summed. Caller table skips constructor_* and unnamed/shared SCC frames, so is nearest exact generated ancestor rather than necessarily direct caller. CPU weights only admitted; allocation uses samples[].size, never tree selfSize. Profiles do not measure call counts or prove equal runtime arguments; source evidence establishes repeated call structure separately.')
out=ROOT/'implementation/phase65/evidence/baseline-state09-constructor-ancestry.json';assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(output=h.pin(out),rows=rows)))
