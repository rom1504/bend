#!/usr/bin/env python3
"""Join existing results; never execute or alter a measured compiler target."""
import hashlib,json,statistics as S
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];R=ROOT/'selfhost/build/phase77';OUT=ROOT/'implementation/phase77'
def read(p):return json.loads(p.read_text())
def pin(p):return dict(path=str(p.relative_to(ROOT)),sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def write(name,data):(OUT/name).write_text(json.dumps(data,indent=2)+'\n')
receipts={}
for name in ['compiler01/validation-001/report.json','compiler01-new14/execution/report.json','compiler01-raw31/execution/report.json','compiler01-word10/execution/report.json','native100-inventory01.json','word01-controls/report.json','compiler01-qualification/self-check/report.json','compiler01-qualification/fixed-point/report.json','release03/legacy42/checks/report.json','release03/default24/report.json','session-controls02/report.json','session-cli01/report.json','string-controls/report.json']:
 p=R/name;d=read(p);assert d.get('pass',d.get('passed')) is True,name;receipts[name]=pin(p)
threads=read(R/'compiler01-threads/report.json');assert threads['complete'] and len(threads['records'])==28 and all(x['passCheck'] for x in threads['records'])
receipts['threads28']=pin(R/'compiler01-threads/report.json')
identity=R/'compiler01-C-identity12';plan=read(identity/'plan.json');count=0
for j in plan['jobs']:
 if j['action']=='request' and j['role']=='b2':
  p=identity/'runs'/j['name']/'report.json';d=read(p);assert d['pass'] and d['exactC'] and d['inputsUnchanged'];receipts['identity/'+j['name']]=pin(p);count+=1
assert count==12
closure=read(R/'compiler01-js-closure/report.json');assert closure['complete'] and not closure['changed'] and closure['unchangedFunctions']==2992
receipts['nonnative-closure']=pin(R/'compiler01-js-closure/report.json')
for name in ['release03/job-install','release03/job-verify-after','release03/job-verify-final','session-cli01-guard']:
 p=R/name/'process.json';d=read(p);assert d['complete'] and d['returncode']==0;receipts[name]=pin(p)
attempt=read(R/'compiler01/attempt.json');assert attempt['checked'];auxiliary=[]
for source in attempt['snapshot']['sources']:
 p=Path(source['original']['file'])
 if p==ROOT/'selfhost/src/back/native/manifest.txt':
  assert p.read_text()==Path(source['frozen']['file']).read_text().replace('pattern.bend\n','pattern.bend\nword-pattern.bend\n')
  auxiliary.append(dict(current=pin(p),frozen=source['frozen'],reason='Register already-qualified module in standalone native-test assembly; production uses compiler.json.'))
 else:assert hashlib.sha256(p.read_bytes()).hexdigest()==source['original']['sha256'],p
images=read(R/'compiler01-b2/image-pins.json');api=ROOT/'selfhost/dist/typed-api.mjs';assert hashlib.sha256(api.read_bytes()).hexdigest()==images['b2']['sha256']
write('qualification.json',dict(complete=True,passed=True,selected='compiler01',artifact='self-emitted-b2',images=images,installedApi=pin(api),compilerSourceSnapshotMatches=True,auxiliaryChanges=auxiliary,receipts=receipts,knownGaps=dict(referenceNativeFailures=7,broaderNativeApiGaps=13),mathematicalCompilerProof=False,runtimeRegressionAuthorization='User explicitly allowed temporary generated-program regressions; see runtime.json for each measured cost.'))
rows=[]
for name in ['runtime01-six','runtime01-coverage']:
 p=R/name/'report.json';d=read(p);assert d['complete'] and len(d['records'])==54 and all(x['correct'] and x['qualified'] for x in d['records'])
 for row in d['rows']:
  m=row['mediansMs'];rows.append(dict(case=row['case'],mediansMs=m,candidateOverUpstream=m['candidate']/m['upstream'],candidateOverPrevious=m['candidate']/m['baseline73'],receipt=pin(p)))
write('runtime.json',dict(complete=True,rows=rows,geomeanCandidateOverUpstream=S.geometric_mean(x['candidateOverUpstream'] for x in rows),geomeanCandidateOverPrevious=S.geometric_mean(x['candidateOverPrevious'] for x in rows),scope='12 fixed native families, 108 correct qualified single-worker intervals. Previous C artifact set is exactly Phase73/75/76. B1 and B2 emit equal C.'))
ds={k:read(R/f'mixed01-{k}/report.json') for k in ['b2','typescript']};assert all(d['complete'] and d['pass'] and len(d['records'])==30 and all(x['exactC'] for x in d['records']) for d in ds.values())
windows={}
for lo,hi,label in [(0,6,'all6'),(1,6,'afterFirstRound'),(3,6,'last3')]:
 rows=[]
 for case in ['numeric','array','lexer','small','functions65']:
  m={k:S.median(x['elapsedMs'] for x in d['records'] if x['case']==case and lo<=x['round']<hi) for k,d in ds.items()};rows.append(dict(case=case,mediansMs=m,ratio=m['b2']/m['typescript']))
 windows[label]=dict(rows=rows,geometricRatio=S.geometric_mean(x['ratio'] for x in rows))
write('session.json',dict(complete=True,windows=windows,receipts=[pin(R/f'mixed01-{k}/report.json') for k in ds],peakObservedRssBytes={k:max(x['rssBytes'] for x in d['records']) for k,d in ds.items()},scope='One fresh process per role, TS then B2, 6 rotated rounds of 5 mixed programs. B2 elapsed includes per-request file integrity hashing; imports and prepared Base are separate. Exploratory short run, not universal steady-state parity.'))
p=R/'generalization01-timing/plan.json';plan=read(p);samples=[]
for j in plan['jobs']:
 if j['action']!='request':continue
 f=p.parent/'runs'/j['name']/'report.json';d=read(f);assert d['complete'] and d['pass'] and d['inputsUnchanged'] and d['exactC'];samples.append(dict(case=j['case'],role=j['role'],ms=d['timings']['requestMs'],receipt=pin(f)))
assert len(samples)==18
med={c:{role:S.median(x['ms'] for x in samples if x['case']==c and x['role']==role) for role in plan['roles']} for c in plan['cases']}
write('heldout.json',dict(complete=True,mediansMs=med,samples=samples,scope='Two non-IO held-out sources; 18 fresh requests, independently compiled/executed C. No paired old compiler here: ratios establish scope, not before/after improvement.'))
modules=read(ROOT/'selfhost/src/compiler.json')['modules'];texts=[(ROOT/'selfhost'/p).read_text().splitlines() for p in modules]
write('simplicity.json',dict(modules=len(modules),physicalLines=sum(map(len,texts)),codeLines=sum(bool(l.strip()) and not l.lstrip().startswith('#') for t in texts for l in t),previous=dict(modules=131,physicalLines=32018,codeLines=26162),scope='Manifest-listed Bend modules only; blank/comment-only lines excluded from code. New private word-pattern module; one host session tool and B2 packaging support are additional infrastructure.'))
print('final evidence joins passed')
