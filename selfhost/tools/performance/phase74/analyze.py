#!/usr/bin/env python3
"""Data-only analysis. Lexical reachability is a screen, not a deletion proof."""
import hashlib,json,re,statistics
from pathlib import Path

ROOT=Path(__file__).resolve().parents[4]
RAW=ROOT/'selfhost/build/phase74';OUT=ROOT/'implementation/phase74'
OUT.mkdir(exist_ok=True)
def read(p):return json.loads(p.read_text())
def pin(p):return dict(file=str(p.relative_to(ROOT)),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
plan=read(RAW/'parity-plan01/plan.json')
result=dict(scope='Three-source diagnostic screen; no promotion, implementation or speedup claim.',cases={},inputs=[])
for case in ['numeric','array','lexer']:
 row=result['cases'][case]={};row['warm']={}
 for role in ['b1','b2','typescript']:
  p=RAW/'warm01'/f'{case}-{role}'/'report.json';d=read(p);result['inputs'].append(pin(p))
  assert d['complete'] and d['pass'] and all(r['exactC'] for r in d['records'])
  times=[r['requestMs'] for r in d['records']]
  row['warm'][role]=dict(requestMs=times,firstMs=times[0],warmFiveMedianMs=statistics.median(times[1:]),lastThreeMedianMs=statistics.median(times[-3:]))
 cp=RAW/'counts02'/f'{case}-b2'/'report.json';d=read(cp);result['inputs'].append(pin(cp))
 assert d['complete'] and d['pass'] and d['records'][0]['exactC']
 counters=d['counters'];notes={n['stage']:n for n in counters['notes']}
 row['compiledDefinitionNames']=sorted(counters['rows']['nc_compile_def']['names'])
 row['counterRows']={k:{**{field:value for field,value in v.items() if field!='names'},'distinctFunctionNames':len(v['names'])} for k,v in counters['rows'].items()}
 row['lowering']={
  'genericSegments':len(notes['nc_finish']['segments']),
  'finalSegments':len(notes['ne_program']['segments']),
  'genericBodyBytes':sum(s['bytes'] for s in notes['nc_finish']['segments']),
  'candidateWorkers':len(notes['nf_finish_ready']['workers']),
  'admittedBeforeObservers':len(notes['nf_finish_ready']['ready']),
  'admittedAfterObservers':len(notes['no_route']['ready']),
  'declarationsBytes':notes['ne_program']['declarationsBytes']}
 generic={s['name'] for s in notes['nc_finish']['segments']}
 row['cShape']={}
 for role in ['b2','typescript']:
  p=Path(plan['cases'][case]['expected'][role]['file']);s=p.read_text();result['inputs'].append(pin(p))
  ids={}
  def short(m):
   ids.setdefault(m[0],'id'+str(len(ids)));return ids[m[0]]
  normalized=re.sub(r'\b(?:FID|NF|CID)_[A-Za-z_0-9]+',short,s)
  start=s.index('// Segments');end=s.index('// Requests',start);section=s[start:end]
  matches=list(re.finditer(r'\bWL_CASE\(([^)]+)\)',section));graph={}
  for i,m in enumerate(matches):
   body=section[m.end():matches[i+1].start() if i+1<len(matches) else len(section)]
   graph[m[1]]=set(re.findall(r'\bFID_[A-Za-z_0-9]+',body))
  roots=set(re.findall(r'\bFID_[A-Za-z_0-9]+',s[s.index('// Spins'):start]))
  roots.add(re.search(r'^#define MAIN_FID (\S+)',s,re.M)[1])
  # Root all fixed runtime cases too, including indirect apply and IO entries.
  if role=='b2':
   owned={'FID_'+''.join(str(ord(c))+'_' for c in name) for name in generic}
   roots.update(set(graph)-owned)
  else:roots.update(k for k in graph if k in ['FID_CLO_APPLY','FID_IO_EMIT'])
  seen=set();todo=list(roots)
  while todo:
   n=todo.pop()
   if n not in seen:seen.add(n);todo.extend(graph.get(n,[]))
  row['cShape'][role]=dict(bytes=p.stat().st_size,shortIdentifierBytes=len(normalized.encode()),
   caseLabels=len(graph),lexicallyReachedCases=len(set(graph)&seen),lexicallyUnreachedCases=len(set(graph)-seen),
   caveat='Both preprocessor branches retained; every private-worker FID is rooted. Text scan cannot establish dynamic/device reachability or authorize deletion.')
 upstream=[]
 for p in sorted((ROOT/'selfhost/build/phase73/paired-compilation/runs').glob(f'clean-*-{case}-typescript/report.json')):
  d=read(p);assert d['complete'] and d['pass'];upstream.append(d['timings']);result['inputs'].append(pin(p))
 row['upstreamCleanStageMedianMs']={k:statistics.median(x[k] for x in upstream) for k in ['requestMs','loadCheckMs','emitMs']}
result['warmRatioGMs']={role:{metric:statistics.geometric_mean(c['warm'][role][metric]/c['warm']['typescript'][metric] for c in result['cases'].values()) for metric in ['firstMs','warmFiveMedianMs','lastThreeMedianMs']} for role in ['b1','b2']}
common=set.intersection(*(set(c['compiledDefinitionNames']) for c in result['cases'].values()))
result['commonDefinitionNames']=sorted(common)
result['commonLibraryNamesExcludingHarness']=sorted(n for n in common if n!='main' and not n.startswith('p46.'))
result['interpretation']='Name intersection is not semantic/body identity or time attribution. Warm measurements use only one process per role/case and are not steady-state evidence. Counter times are instrumented and recursive inclusive totals overlap.'
result['inputs'].append(pin(Path(__file__)))
(OUT/'measurements.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(warmRatioGMs=result['warmRatioGMs'],libraryNames=len(result['commonLibraryNamesExcludingHarness']),shape={k:{r:{'bytes':s['bytes'],'cases':s['caseLabels'],'unreached':s['lexicallyUnreachedCases']} for r,s in v['cShape'].items()} for k,v in result['cases'].items()})))
