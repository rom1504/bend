#!/usr/bin/env python3
"""Prepare isolated case-local frame4 load experiment; execute no target."""
import argparse,hashlib,json,re,shlex,difflib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent;RAW=ROOT/'selfhost/build/phase65'
def pin(p):
 p=Path(p).resolve(strict=True);return dict(file=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def verify(x):assert pin(x['file'])=={k:x[k] for k in ['file','sha256']}
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--preparation',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(RAW) and not out.exists()
r=json.loads(a.preparation.read_text());assert r['complete'] and r['pass'] and r['stage']=='prepare' and r['role']=='baseline'
source=Path(r['project'])/'tools/base-cache-graph.mjs';sourcepin=pin(source);assert sourcepin['sha256']=='b58b927ac611f4ead292d4f736cfd427e955b81c1f0efa2f55d1e784755a0119'
helperRows=[x for x in r['copies'] if x['after']['file']==str(source)];assert len(helperRows)==1;verify(helperRows[0]['after']);verify(r['image']['api'])
assert r['image']['api']['sha256']=='b09fe54ad58d105d1c77ccb399f4076660d6109cf2a7f4b21e13933b89c22c2e'
assert len(r['verification']['cacheFiles'])==1;cache=r['verification']['cacheFiles'][0];verify(cache);assert cache['file'].endswith('-frame4.json')
old=source.read_text();start=old.index('export function decodeBaseArena(');prefix,body=old[:start],old[start:]
loads='    const a=fields[at],b=fields[at+1],c=fields[at+2],d=fields[at+3],e=fields[at+4],f=fields[at+5],g=fields[at+6],h=fields[at+7],j=fields[at+8];\n';assert body.count(loads)==1;body=body.replace(loads,'')
lo=body.index('    switch(tag){')+len('    switch(tag){');hi=body.index('\n    }\n    nodes.push(node);kinds.push(kind);',lo);switch=body[lo:hi]
markers=list(re.finditer(r'^      case (\d+):',switch,re.M));assert [int(m[1]) for m in markers]==list(range(12));counts=[0,2,8,8,5,9,2,4,5,2,8,4];names=['a','b','c','d','e','f','g','h','j'];parts=[switch[:markers[0].start()]]
for i,m in enumerate(markers):
 tail=switch[m.end():markers[i+1].start() if i+1<len(markers) else len(switch)]
 if counts[i]==0:parts.append(m[0]+tail);continue
 terms=[]
 for j in range(counts[i]):
  expr='fields[at'+('+'+str(j) if j else '')+']'
  if i==10 and j>=6:expr=f'size>={j+1}?'+expr+':0'
  terms.append(names[j]+'='+expr)
 parts.append(m[0]+' {\n        const '+','.join(terms)+';'+tail+'\n      }\n')
new=prefix+body[:lo]+''.join(parts)+body[hi:]
assert new[:start]==old[:start] and new.count('nodes.push(node);kinds.push(kind);')==old.count('nodes.push(node);kinds.push(kind);')
corpus=ROOT/'selfhost/tools/performance/phase64/cache-artifact/arena-controls-v2.mjs'
prior=ROOT/'selfhost/build/phase64/arena-domain02/report.json';priorReport=json.loads(prior.read_text());assert priorReport['pass'] and len(priorReport['controls'])==87
frames=[x for x in priorReport['inputs'] if x['file'].endswith('-frame3.json')];assert len(frames)==1;frame3=frames[0];verify(frame3)
oldcorpus=next(x for x in priorReport['inputs'] if x['file']==str(corpus));verify(oldcorpus)
node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node');out.mkdir(parents=True)
for name,text in [('baseline-helper.mjs',old),('candidate-helper.mjs',new)]: (out/name).write_text(text)
(out/'case-local.patch').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='baseline-helper.mjs',tofile='candidate-helper.mjs')))
manifest=dict(kind='phase65-frame4-case-local-probe',complete=True,dataOnly=True,targetExecuted=False,producer=pin(__file__),worker=pin(HERE/'probe.mjs'),node=pin(node),preparation=pin(a.preparation),api=r['image']['api'],driver=r['image']['driver'],originalHelper=sourcepin,baseline=pin(out/'baseline-helper.mjs'),candidate=pin(out/'candidate-helper.mjs'),frame=cache,frame3=frame3,corpus=pin(corpus),previousCorpus=pin(prior),patch=pin(out/'case-local.patch'),rounds=4,warmDecodes=4,scope='Only tag-local reads of already validated scalar field positions. All original tag/span/boolean/reference/string/root validation and literal object bodies remain. Same immutable frame/API; no source/driver/cache edit or compiler execution. Each worker measures first3 plus4 later complete eager frame decodes before any oracle decode, retaining results for full graph validation afterward.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
base=['python3','-B',str(ROOT/'selfhost/tools/performance/phase46/job.py'),'--out',str(out/'guard'),'--seconds','90','--',str(node),'--stack-size=4096','--max-old-space-size=1024',str(HERE/'probe.mjs'),'run',str(out/'manifest.json'),str(out/'execution')]
trace=['python3','-B',str(ROOT/'selfhost/tools/performance/phase46/job.py'),'--out',str(out/'trace-guard'),'--seconds','30','--',str(node),'--stack-size=4096','--max-old-space-size=1024','--trace-opt','--trace-deopt',str(HERE/'probe.mjs'),'worker',str(out/'manifest.json'),'candidate',str(out/'trace-worker.json'),'trace']
(out/'commands.json').write_text(json.dumps(dict(targetExecuted=False,probe=base,optionalTrace=trace),indent=2)+'\n');(out/'commands.txt').write_text(shlex.join(base)+'\n'+shlex.join(trace)+'\n');print(json.dumps(dict(manifest=pin(out/'manifest.json'),probe=base,optionalTrace=trace)))
