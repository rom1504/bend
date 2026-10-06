#!/usr/bin/env python3
"""Map two measured emission dispatcher frames to emitted metadata and allocation callers."""
import argparse, collections, hashlib, json, re
from pathlib import Path
HERE=Path(__file__).resolve().parent; ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('summary',type=Path);p.add_argument('out',type=Path)
a=p.parse_args();out=a.out.resolve()
assert not out.exists() and any(out.is_relative_to(ROOT/x) for x in ['selfhost/build/phase58','implementation/phase58'])
inputs={}
def pin(value):
 file=Path(value['file'] if isinstance(value,dict) else value).resolve(strict=True);b=file.read_bytes()
 row=dict(file=str(file),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
 if isinstance(value,dict):assert row['sha256']==value['sha256']
 inputs[str(file)]=row;return row
def read(value):return json.loads(Path(pin(value)['file']).read_text())
s=read(a.summary);assert s['complete'] and s['pass'] and s['kind']=='phase58-latency-emission-analysis'
assert pin(s['producer'])['sha256']=='200f9daae7217af9e1450b7ca01aacd006859c943f42d1d56a83868ec9d6d73d'
matches=[e for e in s['emissions'] if any(x.get('profile',{}).get('mode')=='allocation' for x in e['phases'])]
assert len(matches)==1;e=matches[0];api=pin(e['image']['api']);text=Path(api['file']).read_text();url=Path(api['file']).as_uri()
targets={
 '$jd$String_46_contains_46_if$scc':['$jd$String_46_contains_46_if','$jd$String_46_contains'],
 '$jd$jd_95_reach_95_refs_95_unique$scc':['$jd$jd_95_reach_95_refs_95_unique','$jd$jd_95_reach_95_marker','$jd$jd_95_reach_95_marker_95_done']}
components=[]
for name,members in targets.items():
 start=text.index('function '+name+'(');assert text.count('function '+name+'(')==1
 end=text.index('for(;;)switch($pc)',start);header=text[start:end]
 assert 'function ' not in header[len('function '):]
 actual=re.findall(r'/\*JD_REF:([^*]+)\*/',header);assert actual==members
 components.append(dict(functionName=name,line=text.count('\n',0,start)+1,
  orderedMembers=actual,header=header,scope='Emitter-owned ordered member metadata, not an AST allocation-site proof.'))
profiles=[]
for phase in e['phases']:
 if 'profile' not in phase:continue
 q=phase['profile'];assert q['mode']=='allocation' and q['calls']==1
 raw=read(q['raw']);saved=read(q['summary']);nodes={};parents={};todo=[(raw['head'],None)]
 while todo:
  node,parent=todo.pop();assert node['id'] not in nodes
  nodes[node['id']]=node;parents[node['id']]=parent
  todo.extend((child,node['id']) for child in node.get('children',[]))
 weights=collections.Counter()
 for sample in raw['samples']:weights[sample['nodeId']]+=sample['size']
 assert sum(weights.values())==q['totalWeight'];assert all(key in nodes for key in weights),'Retain unknown paths; do not guess callers'
 def frame_key(node):
  f=node['callFrame'];return (f['functionName'],f['url'],f['lineNumber']+1,f['columnNumber']+1)
 rows=[]
 for name in targets:
  selected={n for n,node in nodes.items() if node['callFrame']['functionName']==name and node['callFrame']['url']==url}
  exclusive=sum(weights[n] for n in selected)
  assert exclusive==sum(f['selfWeight'] for f in saved['frames'] if f['functionName']==name and f['url']==url)
  chains=collections.Counter();inclusive=0
  for n,weight in weights.items():
   lineage=[];current=n
   while current is not None:
    lineage.append(current);current=parents[current]
   if any(x in selected for x in lineage):inclusive+=weight
   if n in selected:chains[tuple(frame_key(nodes[x]) for x in lineage[1:9])]+=weight
  assert sum(chains.values())==exclusive
  rows.append(dict(functionName=name,exclusiveEstimatedBytes=exclusive,
   inclusiveUnionEstimatedBytes=inclusive,
   topExclusiveCallerChains=[dict(estimatedBytes=weight,nearestCallerFirst=[dict(functionName=f[0],url=f[1],line=f[2],column=f[3]) for f in chain])
    for chain,weight in chains.most_common(8)],
   scope='Exclusive samples grouped by nearest eight recorded callers. Each inclusive union counts a raw sample once; unions for different components may overlap and must not be summed.'))
 profiles.append(dict(phase=phase['name'],raw=q['raw'],summary=q['summary'],sampleEstimatedBytes=q['totalWeight'],components=rows))
producer=pin(__file__)
for item in list(inputs.values()):assert pin(item)==item
result=dict(kind='phase58-emission-allocation-callers',complete=True,dataOnly=True,targetExecuted=False,
 producer=producer,summary=pin(a.summary),api=api,components=components,profiles=profiles,inputs=list(inputs.values()),
 scope='Recorded sampled allocation paths and exact emitted member metadata only. No unique SCC-member, V8 object-kind, operation, or baseline speed attribution.')
result['pass']=True;out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(pin(out)))
