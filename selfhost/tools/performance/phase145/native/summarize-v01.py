#!/usr/bin/env python3
"""Offline event/accounting summary; never launches the measured compiler."""
import collections,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256()
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b)
 return dict(file=str(p),bytes=p.stat().st_size,sha256=h.hexdigest())
def verify(x):assert pin(x['file'])==x
src=ROOT/'selfhost/build/phase145/native-observe02/report.json';r=json.loads(src.read_text());assert r['complete'];planpath=ROOT/'selfhost/build/phase145/native-accounting02/plan.json';plan=json.loads(planpath.read_text());inputs=[pin(__file__),pin(src),pin(planpath)];groups=[]
for c in r['cases']:
 assert len(c['runs'])==2 and all(x['exactQbe'] for x in c['runs']);on=c['runs'][1];verify(on['events']);verify(on['ownerSummary']);inputs.extend([on['events'],on['ownerSummary']]);g=json.loads(Path(on['ownerSummary']['file']).read_text());groups.append({x['owner']:x for x in g['rows']})
keys=[x for x in r['cases'][0]['runs'][1]['totals'] if x!='heap_alloc_miss_calls']
names=sorted(n for n,x in groups[0].items() if n and n.startswith(('p88_','p130m_')) and all(n in g and all(x['counts'][k]==g[n]['counts'][k] for k in keys) for g in groups[1:]))
base=plan['base'];verify(base);inputs.append(base);base_lines={}
for number,line in enumerate(Path(base['file']).read_text().splitlines(),1):
 m=re.match(r'def ([^(:\s]+)',line)
 if m:base_lines.setdefault(m[1],number)
rows=[]
for c,g in zip(r['cases'],groups):
 on=c['runs'][1];t=collections.Counter()
 for name in names:t.update(g[name]['counts'])
 tops={}
 for event in ['heap_alloc_calls','heap_alloc_requested_words','ctr_take_calls','term_keep_calls','term_sink_calls','term_drop_calls','register_words_copy_requested']:
  tops[event]=[]
  for row in on['topOwners'][event]:
   row=dict(row)
   if row['sourceLine'] is not None:row['declaration']=dict(source=r['compilerSource'],line=row['sourceLine'])
   elif row['owner'] in base_lines:row['declaration']=dict(source=base,line=base_lines[row['owner']])
   else:row['declaration']=None
   tops[event].append(row)
 rows.append(dict(name=c['name'],source=c['source'],qbeBytes=c['expected']['bytes'],totals=on['totals'],invariantCarrierOwnerFamily=dict(totals=dict(t),allocationFraction=t['heap_alloc_calls']/on['totals']['heap_alloc_calls'],requestedWordFraction=t['heap_alloc_requested_words']/on['totals']['heap_alloc_requested_words'],registerCopyFraction=t['register_words_copy_requested']/on['totals']['register_words_copy_requested']),otherOwnersAndOutside={k:on['totals'][k]-t[k] for k in on['totals']},topOwners=tops,unknown=on['outsideDispatch'],runtime=on['runtimeDispatch']))
summary=dict(kind='phase145-native-operation-summary-v1',complete=True,targetsRun=False,inputs=inputs,compilerSource=r['compilerSource'],programObject=r['programObject'],linkedRuntime=r['linkedCleanRuntime'],cases=rows,invariantOwnerNames=names,invariantRule='All observed p88_/p130m_ owner vectors identical across three cases except allocator refill count; posthoc descriptive subset, not predeclared benchmark or complete phase attribution.',fixedFamilySourceBasis='These exact declarations decode compact prepared-Base words, fields, arrays, records and roots. Other p88 helpers are excluded. Active context does not identify allocation origins.',limitations=['The matching group includes teardown/free operations and reused callees; it is not an exclusive measured phase.','Refill counts differ201/224/246; all other15 channels in the selected family are exact across these three observations.','Counts are operation traffic, not CPU time or peak/live bytes. Do not extrapolate fixed small-request share to the231-second full build.','String/base helpers lack a compiler-source line because their declarations originate in pinned Base; base lines are joined separately.','No complete query-probe or String-character count; private/inlined operations can bypass dispatcher or runtime hooks.'])
out=ROOT/'research/phase145/native-counts.json';assert not out.exists();out.write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(dict(complete=True,summary=pin(out),invariantOwners=len(names),rows=[dict(name=x['name'],allocationCalls=x['totals']['heap_alloc_calls'],fixedAllocationFraction=x['invariantCarrierOwnerFamily']['allocationFraction']) for x in rows])))
