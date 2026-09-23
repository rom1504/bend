#!/usr/bin/env python3
"""Derive final coverage/verdict/health counts without rerunning a compiler."""
import collections,hashlib,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[3];RUN=ROOT/'selfhost/build/phase5/final-backends/broad-run-01';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
r=json.loads((RUN/'report.json').read_text());assert r.get('finished')
out={'kind':'phase5-broad-backend-audit','report':{'file':str(RUN/'report.json'),'sha256':sha(RUN/'report.json')},'coverageComplete':r['complete'],'inputsVerified':r.get('inputsVerified',False),'infrastructureHealthy':r.get('infrastructureHealthy',False),'artifactKind':r['artifactKind'],'newBootstrap':False,'compilers':{}}
for name in ['reference','candidate']:
 p=RUN/'paired'/(name+'.json')
 if not p.exists():out['compilers'][name]={'closedRawReport':False,'progress':r['rows'].get(name)};continue
 raw=json.loads(p.read_text());rows=raw['results'];a={'closedRawReport':True,'file':str(p),'sha256':sha(p),'observations':len(rows),'strictStatuses':dict(collections.Counter(x['status'] for x in rows)),'uniqueFixtures':len({x['id'] for x in rows}),'strictFailedUniqueFixtures':len({x['id'] for x in rows if x['status']=='fail'}),'lanes':{},'nonpassPositiveRows':[],'identityStable':raw['identity']['adapterChangedDuringRun'] is False and not raw['identity']['changedArtifacts'] and not raw['changedInputs']}
 for lane in ['js','native']:
  rr=[x for x in rows if x['lane']==lane];a['lanes'][lane]={'observations':len(rr),'strictStatuses':dict(collections.Counter(x['status'] for x in rr)),'negativeObservations':sum(x['negative'] for x in rr),'positiveObservations':sum(not x['negative'] for x in rr),'successfulRuntimeResults':sum(x['result'].get('status')=='ok' and x['result'].get('phase')=='runtime' for x in rr),'positiveStrictPass':sum(not x['negative'] and x['status']=='pass' for x in rr),'negativeStrictPass':sum(x['negative'] and x['status']=='pass' for x in rr)}
 for x in rows:
  if not x['negative'] and x['status']!='pass':a['nonpassPositiveRows'].append({k:x.get(k) for k in ['id','lane','status','reason','result','artifacts']})
 out['compilers'][name]=a
p=RUN/'paired/paired.json'
if p.exists():
 pair=json.loads(p.read_text());rows=pair.get('rows',[]);diff=[x for x in rows if not x['exactAgreement']];drop=lambda v:{k:x for k,x in v.items() if k!='diagnostic'}
 out['paired']={'file':str(p),'sha256':sha(p),'observations':len(rows),'missing':pair.get('missing'),'error':pair.get('error'),'selectedComplete':pair.get('selectedComplete'),'exactDifferences':len(diff),'semanticDifferences':sum(not x['semanticAgreement'] for x in rows),'uniqueExactDifferingFixtures':len({x['id'] for x in diff}),'diagnosticOnlyDifferences':sum(drop(x['reference'])==drop(x['candidate']) for x in diff),'differences':diff}
(RUN/'audit.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps({k:v for k,v in out.items() if k not in ['compilers','paired']}));
for n,a in out['compilers'].items():print(n,json.dumps({k:v for k,v in a.items() if k not in ['nonpassPositiveRows']}))
if 'paired'in out:print('paired',json.dumps({k:v for k,v in out['paired'].items() if k!='differences'}))
