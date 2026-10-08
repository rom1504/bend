#!/usr/bin/env python3
"""Count missing constructor callers without inventing ancestry beyond captured frames."""
import collections,importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6]
helper=Path(__file__).with_name('target-ancestry.py');s=importlib.util.spec_from_file_location('h',helper);h=importlib.util.module_from_spec(s);s.loader.exec_module(h)
s=importlib.util.spec_from_file_location('m',h.METHOD);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
assert h.pin(h.METHOD)['sha256']=='4fb715bddc5262f6c7b53d869840f46d225cd3eed2b9ae3b53cdb0ee00bb3679'
rows=[];inputs=[h.pin(helper),h.pin(h.METHOD)]
for mode in ['cpu','allocation']:
 f=ROOT/f'implementation/phase65/evidence/baseline-state09-{mode}.json';inputs.append(h.pin(f))
 for row in h.read(f)['rows']:
  if row['role']!='baseline':continue
  h.verify(row['raw']);h.verify(row['worker']);worker=h.read(row['worker']['file']);api=Path(worker['image']['api']['file']).as_uri();raw=h.read(row['raw']['file']);nodes={};parents={}
  if mode=='cpu':
   nodes={n['id']:n for n in raw['nodes']}
   for n in nodes.values():
    for c in n.get('children',[]):parents[c]=n['id']
   weights=[max(v,0) for v in raw['timeDeltas']] if row['weightedStatus']=='admitted' else [0]*len(raw['samples']);samples=list(zip(raw['samples'],weights))
  else:
   todo=[(raw['head'],None)]
   while todo:
    n,parent=todo.pop();nodes[n['id']]=n;parents[n['id']]=parent;todo.extend((c,n['id']) for c in n.get('children',[]))
   samples=[(s['nodeId'],s['size']) for s in raw['samples']]
  count=collections.Counter();weighted=collections.Counter()
  for nid,w in samples:
   if nid not in nodes:continue
   stack=[];cursor=nid
   while cursor is not None:stack.append(nodes[cursor]['callFrame']);cursor=parents.get(cursor)
   names=[m.decoded(f['functionName']) if f.get('url')==api else None for f in stack]
   if 'constructor_exists' not in names:continue
   after=names[names.index('constructor_exists')+1:]
   if any(n and not n.startswith('constructor_') for n in after):continue
   key=(len(stack),sum(n=='constructor_exists' for n in names),stack[-2]['functionName'],stack[-1]['functionName']);count[key]+=1;weighted[key]+=w
  rows.append(dict(case=row['case'],mode=mode,raw=row['raw'],missingExactNonConstructorCaller=[dict(stackFrames=k[0],constructorExistsFrames=k[1],oldestNonRootFrame=k[2],rootFrame=k[3],samples=v,weight=weighted[k]) for k,v in count.most_common()],weightUnit='sampled-allocation-bytes' if mode=='allocation' else ('admitted-microseconds' if row['weightedStatus']=='admitted' else 'unavailable')))
S=ROOT/'selfhost/build/phase64/checked-state09/snapshot';inputs.extend(h.pin(S/p) for p in ['src/check/prefix-state.bend','src/check/kernel.bend']);apiFile=Path(worker['image']['api']['file']);inputs.append(h.pin(apiFile))
out=ROOT/'implementation/phase65/evidence/baseline-state09-constructor-depth.json';assert not out.exists();result=dict(kind='phase65-constructor-captured-depth',complete=True,dataOnly=True,targetExecuted=False,producer=h.pin(__file__),inputs=inputs,rows=rows,sourceFindings=[dict(file='src/check/prefix-state.bend',line=135,finding='Each suffix definition and its nested definitions queries constructor_exists against the same context argument.'),dict(file='src/check/prefix-state.bend',line=343,finding='Prepared world admission calls base_prefix_ctor_disjoint(suffix,final).'),dict(file='src/check/prefix-state.bend',line=429,finding='Backend book context construction repeats prepared world admission.'),dict(file='src/check/kernel.bend',line=981,finding='constructor_exists recursively scans definitions and performs lookup over each definition constructor list.'),dict(file=str(apiFile),line=7315,finding='Selected B2 computes recursive constructor_exists into $ord1 before Bool.or: strict recursive evaluation, not a JavaScript short-circuit exit.')],scope='Observed captured-depth census only. A 129-frame stack whose oldest non-root frame is still recursive constructor_exists is consistent with profiler depth truncation; no unseen caller is assigned. Counts are samples, not function invocations. No summation with inclusive ancestor unions and no direct speed-gain claim.');out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(output=h.pin(out),rows=rows)))
