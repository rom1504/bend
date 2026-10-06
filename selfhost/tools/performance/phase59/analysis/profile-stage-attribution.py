#!/usr/bin/env python3
"""Data-only replay of the Phase59 recorded inline exact-ancestor analysis.

Recovered from its recorded executed source. Only output selection and the
entry-point argument check differ from the original inline invocation.
Run from the repository root; supply a fresh output file, including /tmp.
"""
from pathlib import Path
import json,hashlib,collections,sys
assert len(sys.argv)==2, 'profile-stage-attribution.py FRESH_OUTPUT_JSON'
R=Path.cwd();base=R/'selfhost/build/phase59';output=Path(sys.argv[1]).resolve();assert not output.exists();inputs={}
def pin(p,want=None):
 p=Path(p).resolve(strict=True);b=p.read_bytes();i={'file':str(p),'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
 if want:assert i['sha256']==want['sha256']
 assert str(p)not in inputs or inputs[str(p)]==i;inputs[str(p)]=i;return i
burl=(R/'selfhost/.bootstrap/upstream-phase23/bend2/bend.ts').as_uri();curl=(R/'selfhost/.bootstrap/upstream-phase23/bend2/comp.ts').as_uri();pin(R/'selfhost/.bootstrap/upstream-phase23/bend2/bend.ts');pin(R/'selfhost/.bootstrap/upstream-phase23/bend2/comp.ts')
direct={'check_program_diagnostic':'checking-and-completion','annotate_selected':'annotation','reach_book':'source-reach','jd_reach_selected':'emitted-reach','jd_library_selected':'library-render','jd_program_selected':'program-render'}
def enc(name):return '$jd$'+''.join(c if c.isascii() and c.isalnum()else '_'+str(ord(c))+'_' for c in name)
rows=[]
configs=[('first-cpu01',stem,'cpu')for stem in ['lexer-0-direct','lexer-0-typescript','test-evening-program-0-direct','test-evening-program-0-typescript']]+[('first-allocation01',stem,'allocation')for stem in ['lexer-0-direct','lexer-0-typescript','test-evening-program-0-direct','test-evening-program-0-typescript']]+[('first-cpu-evening-ts02','test-evening-program-0-typescript','cpu')]
for directory,stem,mode in configs:
 wp=base/directory/(stem+'.result.json');pin(wp);w=json.loads(wp.read_text());assert w['complete']and w['pass'];rp=base/directory/(stem+'-profile/report.json');rid=pin(rp,w['profile']['receipt']);p=json.loads(rp.read_text());assert p['complete'] and p['pass'] and p['calls']==1 and p['mode']==mode
 rawid=pin(p['raw']['file'],p['raw']);raw=json.loads(Path(p['raw']['file']).read_text());roots={}
 if w['role']=='direct':
  api=pin(w['image']['api']['file'],w['image']['api']);url=Path(api['file']).as_uri();assert p['moduleUrl']==url
  text=Path(api['file']).read_text()
  for n,b in direct.items():
   name=enc(n);assert 'function '+name+'(' in text;roots[(url,name)]=b
  driver=Path(api['file']).parents[1]/'tools/typed-driver.mjs';pin(driver);roots[(driver.as_uri(),'discoverSources')]='source-discovery'
 else:roots={(burl,'book_load'):'typescript-load',(burl,'book_valid'):'checking-and-completion',(curl,'file_book'):'typescript-file-analysis',(curl,'js_lib'):'library-render',(curl,'js_book'):'program-render'}
 if mode=='cpu':
  nodes={n['id']:n for n in raw['nodes']};parents={};
  for n in nodes.values():
   for c in n.get('children',[]):assert c not in parents;parents[c]=n['id']
  samples=[(n,1)for n in raw['samples']];unit='CPU samples';assert len(samples)==p['totals']['sampleCount']
 else:
  nodes={};parents={};todo=[(raw['head'],None)]
  while todo:
   n,parent=todo.pop();assert n['id']not in nodes;nodes[n['id']]=n
   if parent is not None:parents[n['id']]=parent
   todo.extend((c,n['id'])for c in n.get('children',[]))
  samples=[(s['nodeId'],s['size'])for s in raw['samples']];unit='estimated sampled allocated bytes'
 buckets={};rootnodes=collections.Counter()
 def bucket(n):
  trail=[]
  while n not in buckets:
   f=nodes[n]['callFrame'];key=(f['url'],f['functionName'])
   if key in roots:buckets[n]=roots[key];rootnodes[roots[key]]+=1;break
   trail.append(n)
   if n not in parents:buckets[n]='unassigned';break
   n=parents[n]
  b=buckets[n]
  for x in trail:buckets[x]=b
  return b
 mass=collections.Counter();unassigned=collections.Counter()
 for n,size in samples:
  b=bucket(n);mass[b]+=size
  if b=='unassigned':unassigned[nodes[n]['callFrame']['functionName'] or '(anonymous)']+=size
 total=sum(size for _,size in samples);assert sum(mass.values())==total
 rows.append({'campaign':directory,'case':stem.rsplit('-0-',1)[0],'role':w['role'],'mode':mode,'worker':inputs[str(wp.resolve())],'profileReceipt':rid,'raw':rawid,'oneFirstRequest':True,'unit':unit,'total':total,'sampleEvents':len(samples),'weightedStatusReported':p.get('weightedStatus'),'weightedTimeComputed':False,'partitions':[{'stage':k,'mass':v,'percent':v/total*100}for k,v in mass.most_common()],'unassignedLeafNames':[{'name':k,'mass':v}for k,v in unassigned.most_common(5)],'observedBoundaryStackNodes':dict(rootnodes),'rootPolicy':[{'url':u,'functionName':n,'stage':b}for(u,n),b in roots.items()]})
for path,row in list(inputs.items()):assert pin(path)==row
result={'kind':'phase59-first-window-exact-ancestor-attribution','complete':True,'dataOnly':True,'targetExecuted':False,'scope':'Mutually exclusive attribution of individual CPU sample events or allocation samples by nearest exact API/source-driver boundary ancestor. This is sampled contextual attribution, not API call counts, phase wall clocks or causal removable cost. Unassigned mass retained. Anonymous/common helpers and SCC dispatchers are never assigned by their own names. Exact-boundary ancestry may be absent due to inlining or asynchronous stacks.','method':{'cpu':'Each samples[] node contributes exactly 1; timeDeltas not used, including the original refused weighted TS Evening capture. Its healthy count view is kept separately from the fresh TS retry.','allocation':'Each samples[] event contributes its recorded size once. Ancestors classify that sample; neither ancestor selfSize nor inclusive totals are added. Minor/major collected-object inclusion remains the original producer policy.','overlap':'Nearest (deepest) exact matched ancestor wins. Therefore inner file-analysis/checking bins exclude their mass from enclosing library/load bins. A stack missing all exact boundaries is unassigned; no stage inferred from helper/dispatcher names.','crossCompiler':'TS file_book analysis and Bend emitted-reach are distinct bins, not an asserted stage-equivalence. check_program_diagnostic includes completion; discoverSources includes host loading/parsing/completion. Root wall clocks are a separate method.','integrity':'Worker/profile/raw and selected API/source bytes hashed before/after; original receipts retained. No whole transitive image/provenance audit inferred.'},'rows':rows,'inputsUnchanged':True,'inputs':list(inputs.values())}
output.parent.mkdir(parents=True,exist_ok=True);output.write_text(json.dumps(result,indent=2)+'\n')
print('Output',output,'SHA',hashlib.sha256(output.read_bytes()).hexdigest())
for r in rows:print(r['campaign'],r['case'],r['role'],r['mode'],[(p['stage'],round(p['percent'],2))for p in r['partitions']])
