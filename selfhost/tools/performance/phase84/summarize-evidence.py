#!/usr/bin/env python3
"""Summarize completed Phase84 receipts, including failed predecessors."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];RAW=ROOT/'selfhost/build/phase84';OUT=ROOT/'implementation/phase84'
def pin(p):
 b=p.read_bytes();return dict(file=str(p.relative_to(ROOT)),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def read(p):return json.loads(p.read_text())
def write(n,v):(OUT/n).write_text(json.dumps(v,indent=2)+'\n')
guards=[]
for p in sorted(RAW.rglob('*.json')):
 if p.name not in ['process.json','run.json']:continue
 r=read(p)
 if isinstance(r,dict) and 'peakTreeRssBytes' in r and 'wallSeconds' in r:
  guards.append(dict(receipt=pin(p),**{k:r.get(k) for k in ['complete','returncode','wallSeconds','peakTreeRssBytes','minimumAvailableBytes','started','finished']}))
resource=dict(jobs=len(guards),wallSeconds=sum(r['wallSeconds'] for r in guards),peakTreeRssBytes=max(r['peakTreeRssBytes'] for r in guards),minimumAvailableBytes=min(r['minimumAvailableBytes'] for r in guards),failed=[r for r in guards if not r['complete']],guardSpanSeconds=max(r['finished'] for r in guards)-min(r['started'] for r in guards),guards=guards,scope='Serial target occupancy and enclosing first/last guard span only. Includes failed checks and genuine-B2 build. Excludes planning/agent work before first guard and documentation/archiving afterward. No Codex quota estimate.')
write('resources.json',resource)
clean=[]
for screen in range(1,6):
 plan=RAW/f'screen{screen:02}'/'plan.json';data=read(plan)
 for j in data['jobs']:
  if j['action']!='request':continue
  p=plan.parent/'runs'/j['name']/'report.json';r=read(p);assert r['complete'] and r['pass'] and r['exactC'] and r['inputsUnchanged'];clean.append(pin(p))
counts={}
for p in sorted((RAW/'refusal-counts01/runs').glob('clean-*/report.json')):
 r=read(p);assert r['complete'] and r['pass'] and r['exactC'];counts[r['job']['case']]={'report':pin(p),**r['diagnostic']}
write('refusal-counts.json',dict(complete=True,cases=counts,scope='Actual predicate counts from disposable source-bound B1 wrapper, exact C. Instrumented times not speed samples.'))
profiles={}
for role in ['b2','candidate']:
 p=RAW/'fusion-profiles01/runs'/('profile-numeric-'+role)/'report.json';r=read(p);assert r['complete'] and r['pass'] and r['exactC'];profiles[role]=dict(report=pin(p),timings=r['timings'],stages=r['stages'])
write('fusion-stages.json',dict(complete=True,roles=profiles,scope='One Numeric profile per actual B2 image. Public stage clocks and CPU samples are diagnostic; clean screen04 is the performance comparison.'))
attempts={}
for number in range(1,6):
 p=RAW/f'compiler{number:02}'/'attempt.json';g=read(RAW/f'compiler{number:02}-guard/process.json');attempts[f'compiler{number:02}']=dict(guard=pin(RAW/f'compiler{number:02}-guard/process.json'),complete=g['complete'])
 if p.exists():attempts[f'compiler{number:02}'].update(attempt=pin(p),api=read(p).get('api'),checked=read(p).get('checked'))
for prefix,expected in [('fusion-focused03',True),('report-controls02',True)]:
 r=read(RAW/prefix/'report.json');assert r['complete'] and r['pass']
assert subprocess.run(['git','diff','--exit-code','HEAD','--','selfhost/src','selfhost/tools/typed-driver.mjs','selfhost/dist'],cwd=ROOT,capture_output=True).returncode==0
r=read(RAW/'release-verify-guard/process.json');assert r['complete']
write('qualification.json',dict(complete=True,productionUnchanged=True,installedVerification=pin(RAW/'release-verify-guard/process.json'),cleanRequests=len(clean),allCleanCExact=True,clean=clean,attempts=attempts,reportControls=pin(RAW/'report-controls02/report.json'),fusionControls=pin(RAW/'fusion-focused03/report.json'),b2Pins=pin(RAW/'compiler04-b2/image-pins.json'),scope='Experimental qualification only: four successful checked-B1/frontend36 builds, one failed build, genuine fusion B2 and eight driver comparisons, finite focused controls. No new broad release gate, self-check/B3 reproduction, conformance improvement or runtime timing claim.'))
print(json.dumps({k:v for k,v in resource.items() if k not in ['guards','failed']}));print('failed guards:',len(resource['failed']),'clean exact C:',len(clean))
