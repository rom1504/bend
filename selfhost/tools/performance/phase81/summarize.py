#!/usr/bin/env python3
"""Summarize clean samples and separate CPU/heap/region diagnostics."""
import collections,hashlib,json,math,re,statistics
from pathlib import Path
ROOT=Path('/home/ai/bend2/build/publish/bend'); RAW=ROOT/'selfhost/build/phase81'; OUT=ROOT/'implementation/phase81'
def read(p):return json.loads(p.read_text())
def pin(p):
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def save(n,d):(OUT/n).write_text(json.dumps(d,indent=2)+'\n')
def name(s):return s.removeprefix('$jd$').replace('_95_','_').strip('$') or '<anonymous>'
plan=read(RAW/'survey01/plan.json'); reports=[(p,read(p)) for p in (RAW/'survey01/runs').glob('*/report.json')]
assert len(reports)==len(plan['jobs']) and all(r['complete'] and r['pass'] and r['inputsUnchanged'] for p,r in reports)
clean=[(p,r) for p,r in reports if r['job']['name'].startswith('clean-')];assert len(clean)==54
medians={};quiet={}
for case in plan['cases']:
 medians[case]={}
 for role in ['b1','b2','typescript']:
  rows=[(p,r) for p,r in clean if r['job']['case']==case and r['role']==role and r['job'].get('withReport')!=False]
  xs=[r['timings']['requestMs'] for p,r in rows];assert len(xs)==3
  medians[case][role]={'samplesMs':xs,'medianMs':statistics.median(xs),'evidence':[pin(p) for p,r in rows]}
 for role in ['b1','b2']:medians[case][role]['overTS']=medians[case][role]['medianMs']/medians[case]['typescript']['medianMs']
 qs=[(p,r) for p,r in clean if r['job']['case']==case and r['job'].get('withReport')==False]
 if qs:
  xs=[r['timings']['requestMs'] for p,r in qs];quiet[case]={'samplesMs':xs,'medianMs':statistics.median(xs),'overReport':statistics.median(xs)/medians[case]['b2']['medianMs'],'evidence':[pin(p) for p,r in qs]}
gm=lambda xs:math.exp(statistics.mean(math.log(x) for x in xs))
save('measurements.json',dict(scope=plan['scope'],cases=medians,screenGM={r:gm(medians[c][r]['overTS'] for c in ['numeric','array','lexer']) for r in ['b1','b2']},quietDifferentContract=quiet,allExactC=True))
cpu={};heaps={}
groups={
 'text':r'^(ne_template|ne_fill|nt_(lines|indent|replace|clean))',
 'normalization_substitution':r'^(wnf$|norm_|subst|env_subst|g_eval|g_args|g_let)',
 'index_lookup_hash':r'^(index_|lookup)',
 'occurrence_queries':r'^(nc_uses|nq_uses|nq_min_uses)',
 'term_access':r'^(tg|nm|ix|qt|ks|rm|kb|ke|kid|terms_at)$'}
for p,r in reports:
 j=r['job']
 if not j['profile']:continue
 file=Path(r['profile']['file']);d=read(file)
 if j.get('heap'):
  selfBytes=collections.Counter();groupsBytes=collections.Counter()
  def walk(n,anc):
   nm=name(n['callFrame']['functionName']);b=n['selfSize'];selfBytes[nm]+=b;anc=anc+[nm]
   for key,pat in groups.items():
    if any(re.search(pat,v) for v in anc):groupsBytes[key]+=b
   for ch in n['children']:walk(ch,anc)
  walk(d['head'],[])
  heaps[r['role']]={'estimatedAllocatedBytes':sum(selfBytes.values()),'topSelfBytes':selfBytes.most_common(40),'overlappingStackUnionsBytes':dict(groupsBytes),'report':pin(p),'profile':pin(file)}
 else:
  nodes={n['id']:n for n in d['nodes']};parents={ch:n['id'] for n in d['nodes'] for ch in n.get('children',[])}
  selfMs=collections.Counter();inclusive=collections.Counter();unions=collections.Counter()
  for i,dt in zip(d['samples'],d['timeDeltas']):
   ms=dt/1000;selfMs[name(nodes[i]['callFrame']['functionName'])]+=ms;anc=set()
   while i:
    anc.add(name(nodes[i]['callFrame']['functionName']));i=parents.get(i)
   for nm in anc:inclusive[nm]+=ms
   for key,pat in groups.items():
    if any(re.search(pat,v) for v in anc):unions[key]+=ms
  cpu[j['name']]={'timings':r['timings'],'publicStages':r['stages'],'sampledTotalMs':sum(selfMs.values()),'selfMs':selfMs.most_common(40),'inclusiveMs':inclusive.most_common(100),'overlappingStackUnionsMs':dict(unions),'report':pin(p),'profile':pin(file)}
save('profiles.json',dict(caution='One CPU profile per role/source; heap sampling Numeric only, includes collected allocations. GC lacks allocating ancestry. Stack unions overlap and inclusive clocks are not removable costs. Profiling setup/stop may appear outside timed request; no speedup inferred.',cpu=cpu,heap=heaps))
regions={}
for p in (RAW/'regions01/runs').glob('clean-*/report.json'):
 r=read(p);assert r['pass'] and r['exactC'];regions[r['job']['case']]={'requestMs':r['timings']['requestMs'],'regions':r['diagnostic']['regions'],'report':pin(p)}
assert len(regions)==5
save('regions.json',dict(caution='Observation-only generated B2 derivative. Wrappers break some compiler tail loops; counts include recursive entries. Recursive inclusive sums can exceed wall time. Use exclusive values for recursive regions; neither is a clean optimization result.',cases=regions))
guards=[read(p) for d in ['survey01','regions01'] for p in (RAW/d/'runs').glob('*-guard/process.json')]
save('qualification.json',dict(productionChanged=False,newCompilerCandidate=False,cleanRequests=54,cpuProfiles=15,heapProfiles=3,regionRequests=5,preparations=3,exactCRequests=77,allPass=True,guards=len(guards),guardedWallSeconds=sum(g['wallSeconds'] for g in guards),peakTreeRssBytes=max(g['peakTreeRssBytes'] for g in guards),firstJobStart=min(g['started'] for g in guards),lastJobFinish=max(g['finished'] for g in guards),method=pin(Path(__file__))))
print(json.dumps({'screenGM':{r:gm(medians[c][r]['overTS'] for c in ['numeric','array','lexer']) for r in ['b1','b2']},'guards':len(guards),'guardedSeconds':sum(g['wallSeconds'] for g in guards),'heapMB':{r:round(v['estimatedAllocatedBytes']/1e6,2) for r,v in heaps.items()}}))
