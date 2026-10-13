#!/usr/bin/env python3
"""Summarize closed Phase80 receipts without mixing clean and diagnostic clocks."""
import hashlib,json,math,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase80';OUT=ROOT/'implementation/phase80'
OUT.mkdir(exist_ok=True)
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def dump(name,data):(OUT/name).write_text(json.dumps(data,indent=2)+'\n')
screens=[]
for name in ['screen02','screen03','heldout03','screen04','heldout04','screen05','heldout05']:
 plan=RAW/name/'plan.json';p=json.loads(plan.read_text());rows={};receipts=[]
 for job in p['jobs']:
  if job['action']!='request':continue
  f=plan.parent/'runs'/job['name']/'report.json';r=json.loads(f.read_text());assert r['complete'] and r['pass'] and r['exactC'] and r['inputsUnchanged']
  rows.setdefault(job['case'],{}).setdefault(job['role'],[]).append(r['timings']['requestMs']);receipts.append(pin(f))
 cases={}
 for c,roles in rows.items():
  medians={r:statistics.median(xs) for r,xs in roles.items()};cases[c]=dict(samplesMs=roles,mediansMs=medians,candidateOverBaseline=medians['ordinary']/medians['baseline'],candidateOverTypeScript=medians['ordinary']/medians['typescript'],baselineOverTypeScript=medians['baseline']/medians['typescript'])
 prep={}
 for role in ['baseline','ordinary']:
  f=plan.parent/'runs'/('prepare-'+role)/'report.json';r=json.loads(f.read_text());assert r['pass'];prep[role]=dict(report=pin(f),milliseconds=r['timings']['prepareBaseMs'],cacheBytes=sum(x['bytes'] for x in r['cache']))
 screens.append(dict(name=name,plan=pin(plan),requests=len(receipts),receipts=receipts,cases=cases,preparation=prep,equalCaseGeometricMeans={k:math.prod(r[k] for r in cases.values())**(1/len(cases)) for k in ['candidateOverBaseline','candidateOverTypeScript','baselineOverTypeScript']}))
dump('measurements.json',dict(scope='Checked B1 only. Two samples per role/case in initial screens, three in heldout04/05, five in screen05. Exact previously executed C; imports, explicit frontend-only Base preparation, Clang and execution excluded. These bounded screens do not establish production B2 performance.',screens=screens))
profiles=[]
for role in ['baseline','ordinary']:
 f=RAW/'profiles02/runs'/('profile-numeric-'+role)/'report.json';r=json.loads(f.read_text());assert r['pass'] and r['exactC'];p=json.loads(Path(r['profile']['file']).read_text());nodes={n['id']:n for n in p['nodes']};leaf={}
 for n,t in zip(p['samples'],p['timeDeltas']):
  k=nodes[n]['callFrame']['functionName'];leaf[k]=leaf.get(k,0)+t/1000
 profiles.append(dict(role=role,receipt=pin(f),profile=r['profile'],requestMs=r['timings']['requestMs'],stages=r['stages'],exclusiveLeafSampledMs=sorted([dict(name=k,milliseconds=v) for k,v in leaf.items()],key=lambda x:-x['milliseconds'])))
dump('profiles.json',dict(scope='Diagnostic only. Public stage clocks and V8 samples do not replace clean request timings. Inclusive clocks overlap.',profiles=profiles))
counts=[]
for name in ['counts01','counts02']:
 f=RAW/name/'runs/clean-counts-numeric-baseline/report.json';r=json.loads(f.read_text());assert r['pass'] and r['exactC'];counts.append(dict(name=name,receipt=pin(f),rows=r['diagnostic']))
dump('analysis-counts.json',dict(scope='Observationally instrumented unchanged Phase78 B1, Numeric only. Every original result is recomputed. Recursive inclusive times overlap; wrapper/trampoline overhead changes clocks. First-argument identity ignores other arguments and is not a valid cache key by itself.',runs=counts))
builds=[]
for n in ['01','02','03','04','05']:
 d=RAW/('compiler'+n);a=json.loads((d/'attempt.json').read_text());r=json.loads((d/'validation-001/report.json').read_text());assert a['checked'] and r['pass'] and r['selected']['exactDifferences']==0
 modules=json.loads((d/'snapshot/src/compiler.json').read_text())['modules'];sources=[d/'snapshot'/s for s in modules if s.endswith('.bend')]
 lines=[line for p in sources for line in p.read_text().splitlines()]
 builds.append(dict(name='compiler'+n,attempt=pin(d/'attempt.json'),api=a['api'],selectedReport=pin(d/'validation-001/report.json'),frontendCases=r['selected']['candidate']['probes'],physicalLines=len(lines),nonblankNoncommentLines=sum(bool(l.strip()) and not l.lstrip().startswith('#') for l in lines),modules=len(sources)))
dump('qualification.json',dict(scope='Five checked-B1 builds and selected frontend36 per build. Native exact-output screens only; no full frontend/native/runtime/B2/self-reproduction qualification or promotion.',builds=builds,failedBasePreparation=pin(RAW/'screen01/runs/prepare-ordinary/report.json'),prefixDiagnostic=pin(RAW/'prefix02-guard/stdout.log')))
accounts=[]
for f in RAW.rglob('process.json'):
 r=json.loads(f.read_text())
 if 'wallSeconds' in r and 'started' in r:accounts.append(dict(receipt=pin(f),complete=r['complete'],started=r['started'],finished=r['finished'],wallSeconds=r['wallSeconds'],peakTreeRssBytes=r['peakTreeRssBytes']))
span=max(r['finished'] for r in accounts)-min(r['started'] for r in accounts)
dump('timing-account.json',dict(scope='Recorded supervised process occupancy, including failed launches. These non-overlapping jobs ran serially. Span is first recorded target start to last recorded target finish; reading/design/reporting outside it is not charged or estimated. No Codex quota inference.',jobs=accounts,supervisedSeconds=sum(r['wallSeconds'] for r in accounts),recordedSpanSeconds=span,peakTreeRssBytes=max(r['peakTreeRssBytes'] for r in accounts)))
print(json.dumps(dict(screens=[dict(name=x['name'],ratios=x['equalCaseGeometricMeans']) for x in screens],builds=[dict(name=x['name'],lines=x['physicalLines'],code=x['nonblankNoncommentLines']) for x in builds],supervisedSeconds=sum(r['wallSeconds'] for r in accounts))))
