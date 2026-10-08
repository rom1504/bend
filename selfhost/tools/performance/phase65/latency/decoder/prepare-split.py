#!/usr/bin/env python3
"""Prepare isolated static-tag frame4 reader experiment; execute no target."""
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
loads='    const a=fields[at],b=fields[at+1],c=fields[at+2],d=fields[at+3],e=fields[at+4],f=fields[at+5],g=fields[at+6],h=fields[at+7],j=fields[at+8];\n';assert body.count(loads)==1
lo=body.index('    switch(tag){')+len('    switch(tag){');hi=body.index('\n    }\n    nodes.push(node);kinds.push(kind);',lo);switch=body[lo:hi]
markers=list(re.finditer(r'^      case (\d+):',switch,re.M));assert [int(m[1]) for m in markers]==list(range(12))
counts=[0,2,8,8,5,9,2,4,5,2,8,4];names=['a','b','c','d','e','f','g','h','j'];tags=['Nil','Con','KTerm','KLambda','KLiteral','KDef','KIndexLeaf','KIndexNode','KBasePrefixState','FFreshPrefixState','KBasePreparedWorld','FReadyPrefixState']
helpers=["// Fixed transport readers keep rare-tag feedback outside the hot record loop.\n",
 "function arenaReadRef(ctx,i,mask){if(i>=ctx.nodes.length||!(ctx.kinds[i]&mask))fail();return ctx.nodes[i];}\n",
 "function arenaReadString(ctx,i){if(i>=ctx.strings.length)fail();return ctx.strings[i];}\n",
 "function arenaReadSpan(ctx,a,b){if(!((a===0&&b===0)||(a>=ctx.range.begin&&b>=a&&b<ctx.range.end)))fail();}\n"]
for i,m in enumerate(markers):
 tail=switch[m.end():markers[i+1].start() if i+1<len(markers) else len(switch)]
 assert tail.count('break;')==1;tail=tail.replace('break;','')
 for oldcall,newcall in [('ref(','arenaReadRef(ctx,'),('str(','arenaReadString(ctx,'),('span(','arenaReadSpan(ctx,')]:tail=tail.replace(oldcall,newcall)
 terms=[]
 for j in range(counts[i]):
  expr='fields[at'+('+'+str(j) if j else '')+']'
  if i==10 and j>=6:expr=f'size>={j+1}?'+expr+':0'
  terms.append(names[j]+'='+expr)
 helper='function arenaRead'+tags[i]+'(ctx,fields,at,size){\n'
 context=[name for name in ['nodes','kinds','termAbi'] if re.search(r'\b'+name+r'\b',tail)]
 if context:helper+='  const {'+','.join(context)+'}=ctx;\n'
 if terms:helper+='  const '+','.join(terms)+';\n'
 helper+='  let node,kind;'+tail+'\n  ctx.kind=kind;return node;\n}\n';helpers.append(helper)
helpers.append('const arenaReaders=['+','.join('arenaRead'+tag for tag in tags)+'];\n\n')
oldLoop=loads+'    let node,kind;\n    switch(tag){'+switch+'\n    }\n    nodes.push(node);kinds.push(kind);'
assert body.count(oldLoop)==1
body=body.replace(oldLoop,'    const node=arenaReaders[tag](state,fields,at,size);\n    nodes.push(node);kinds.push(state.kind);')
for line in ["  const str=i=>{if(i>=strings.length)fail();return strings[i];};\n","  const span=(a,b)=>{if(!((a===0&&b===0)||(a>=range.begin&&b>=a&&b<range.end)))fail();};\n"]:
 assert body.count(line)==1;body=body.replace(line,'')
anchor='  for(let i=0;i<n;i++){';assert body.count(anchor)==1;body=body.replace(anchor,'  const state={nodes,kinds,strings,range,termAbi,kind:0};\n'+anchor)
new=prefix+''.join(helpers)+body
assert new.startswith(prefix)
corpus=ROOT/'selfhost/tools/performance/phase64/cache-artifact/arena-controls-v2.mjs'
prior=ROOT/'selfhost/build/phase64/arena-domain02/report.json';priorReport=json.loads(prior.read_text());assert priorReport['pass'] and len(priorReport['controls'])==87
frames=[x for x in priorReport['inputs'] if x['file'].endswith('-frame3.json')];assert len(frames)==1;frame3=frames[0];verify(frame3)
oldcorpus=next(x for x in priorReport['inputs'] if x['file']==str(corpus));verify(oldcorpus)
node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node');out.mkdir(parents=True)
for name,text in [('baseline-helper.mjs',old),('candidate-helper.mjs',new)]: (out/name).write_text(text)
(out/'static-tags.patch').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='baseline-helper.mjs',tofile='candidate-helper.mjs')))
manifest=dict(kind='phase65-frame4-case-local-probe',complete=True,dataOnly=True,targetExecuted=False,producer=pin(__file__),worker=pin(HERE/'probe.mjs'),node=pin(node),preparation=pin(a.preparation),api=r['image']['api'],driver=r['image']['driver'],originalHelper=sourcepin,baseline=pin(out/'baseline-helper.mjs'),candidate=pin(out/'candidate-helper.mjs'),frame=cache,frame3=frame3,corpus=pin(corpus),previousCorpus=pin(prior),patch=pin(out/'static-tags.patch'),rounds=4,warmDecodes=4,hypothesis='P65-007',candidateLabel='static-tag-readers',parentProbe=pin(ROOT/'selfhost/build/phase65/frame4-case-local01/manifest.json'),parentFactory=pin(Path(__file__).with_name('prepare.py')),sourceLines=dict(before=len(old.splitlines()),after=len(new.splitlines()),delta=len(new.splitlines())-len(old.splitlines())),scope='Small record dispatch loop plus fixed per-tag transport readers and static reference/string/span validation functions. Original constructor/check bodies retained; no encoder/schema/semantic change. Same consumed87-control/eight-worker microprobe controller and immutable frame/API. No live/source/driver/cache edit or compiler execution.')
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
base=['python3','-B',str(ROOT/'selfhost/tools/performance/phase46/job.py'),'--out',str(out/'guard'),'--seconds','90','--',str(node),'--stack-size=4096','--max-old-space-size=1024',str(HERE/'probe.mjs'),'run',str(out/'manifest.json'),str(out/'execution')]
trace=['python3','-B',str(ROOT/'selfhost/tools/performance/phase46/job.py'),'--out',str(out/'trace-guard'),'--seconds','30','--',str(node),'--stack-size=4096','--max-old-space-size=1024','--trace-opt','--trace-deopt',str(HERE/'probe.mjs'),'worker',str(out/'manifest.json'),'candidate',str(out/'trace-worker.json'),'trace']
(out/'commands.json').write_text(json.dumps(dict(targetExecuted=False,probe=base,optionalTrace=trace),indent=2)+'\n');(out/'commands.txt').write_text(shlex.join(base)+'\n'+shlex.join(trace)+'\n');print(json.dumps(dict(manifest=pin(out/'manifest.json'),probe=base,optionalTrace=trace)))
