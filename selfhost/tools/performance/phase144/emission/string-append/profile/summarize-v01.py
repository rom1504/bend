"""Offline concat observation summary; re-sum pinned raw event files."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[7]
def pin(p):
 p=Path(p).resolve();h=hashlib.sha256();size=0
 with p.open('rb') as f:
  for b in iter(lambda:f.read(1048576),b''):h.update(b);size+=len(b)
 return dict(file=str(p),bytes=size,sha256=h.hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(p):assert pin(p['file'])==p,p['file']
report=ROOT/'selfhost/build/phase144/concat-profile-observe01/report.json';r=read(report);build=ROOT/'selfhost/build/phase144/concat-profile-build01/report.json';control=ROOT/'selfhost/build/phase144/concat-profile-control01/report.json';plan=ROOT/'selfhost/build/phase144/concat-profile01/plan.json'
assert r['complete'] and read(build)['complete'] and read(control)['complete'];m=read(plan)
inputs=[pin(__file__),pin(report),pin(build),pin(control),pin(plan),*m['inputs'],*m['outputs']];rows=[]
for c in r['cases']:
 for key in ['source','object','qbe']:inputs.append(c[key]);verify(c[key])
 assert len(c['runs'])==2
 for run in c['runs']:
  assert run['exitCode']==0 and run['exactOutput']
  for key in ['events','stdout','stderr','binary']:inputs.append(run[key]);verify(run[key])
  d=read(run['events']['file']);assert d['complete'] and not d['counter_overflow'] and not d['invalid_context_events']
  assert d['counts_enabled'] is run['enabled'] and d['counter_names'][-7:]==m['addedCounters']
  if not run['enabled']:assert d['rows']==[];continue
  totals={name:0 for name in d['counter_names']}
  for row in d['rows']:
   assert len(row['counts'])==len(d['counter_names'])
   for name,value in zip(d['counter_names'],row['counts']):totals[name]+=value
  assert totals==run['totals']
  counts={n:totals[n] for n in m['addedCounters']};attempts=counts['concat_attempts'];success=counts['concat_success_empty']+counts['concat_success_splice'];refused=sum(counts[k] for k in m['addedCounters'][4:]);assert attempts==success+refused
  rows.append(dict(name=c['name'],source=c['source'],object=c['object'],qbe=c['qbe'],diagnosticBinary=run['binary'],events=run['events'],counts=counts,successes=success,refusals=refused,successFraction=success/attempts,refusalFraction=refused/attempts,nodesPerAttempt=counts['concat_nodes_examined']/attempts,exactCountersOffAndOnOutputs=True))
for p in inputs:verify(p)
out=ROOT/'research/phase144/concat-profile.json';assert not out.exists()
result=dict(kind='phase144-concat-diagnostic-summary',complete=True,targetsRun=False,inputs=inputs,cases=rows,atomicRuntime=True,compileFlags=['-O2','-std=gnu11','-ffp-contract=off'],diagnosticRepetitions=1,diagnosticWarmups=0,limitations=['Whole invocation includes semantic result, wrapper and output;not only timed kernel.','Spine-node totals are not separated by final outcome;do not attribute all visits to refusal or wasted work.','Positive hook positions are source audited;independent generic fixture checks16 existing counters and7 added zero channels,not positive branch coverage.','Counts are not time saved or source-level allocation origins.','Retained final03 codegen objects execute the admission later reverted in source04;atomic runtime matches the isolated codegen comparison,not selected serial timing.'])
out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,report=pin(out),cases=[{k:c[k] for k in ['name','successFraction','refusalFraction','nodesPerAttempt']} for c in rows])))
