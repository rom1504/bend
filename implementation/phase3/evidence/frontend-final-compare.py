from pathlib import Path
import json,hashlib,datetime,collections
root=Path(__file__).resolve().parent
load=lambda f:json.loads(Path(f).read_text());sha=lambda f:hashlib.sha256(Path(f).read_bytes()).hexdigest();setup=load(root/'launch.json');oldfile=Path(setup['historicalReport']);reffile=oldfile.parents[2]/'reference-all/report.json'
files={'candidate':root/'candidate.json','upstream':root/'upstream.json','phase2':oldfile,'phase2Upstream':reffile}
r={k:load(f) for k,f in files.items()};key=lambda x:x['id']+'::'+x['lane'];maps={k:{key(x):x for x in v['results']} for k,v in r.items()}
assert all(set(m)==set(maps['candidate']) for m in maps.values())
for label in ['candidate','upstream']:
 assert not r[label]['changedInputs'] and not r[label]['identity']['changedArtifacts'] and not r[label]['identity']['adapterChangedDuringRun']
 assert all(not x['errors'] for x in r[label]['workers'])
assert all({x['id']:x['sha256'] for x in v['inventory']['tests']}=={x['id']:x['sha256'] for x in r['candidate']['inventory']['tests']} for v in r.values())
def semantic(row):
 x=row.get('result',{});return {k:x.get(k) for k in ['status','phase','checked','exitCode','signal']}
def diagnostic(row):
 x=row.get('result',{});return x.get('diagnostic',x.get('output',x.get('stdout','')))
def observed(row):return {'semantic':semantic(row),'text':diagnostic(row)}
def same(a,b):return observed(a)==observed(b)
changes=[];mismatches=[];new=[];resolutions=[]
for k in sorted(maps['candidate']):
 now,ref,old,oldref=[maps[n][k] for n in ['candidate','upstream','phase2','phase2Upstream']]
 if not same(now,old):changes.append({'key':k,'previous':observed(old),'current':observed(now),'previousVerdict':old['status'],'currentVerdict':now['status']})
 if not same(now,ref):
  row={'key':k,'kind':'acceptance-or-phase' if semantic(now)!=semantic(ref) else 'exact-diagnostic-or-report','candidate':observed(now),'upstream':observed(ref),'previousCandidate':observed(old),'existedInPhase2':not same(old,oldref)};mismatches.append(row)
  if not row['existedInPhase2']:new.append(row)
 elif not same(old,oldref):resolutions.append(k)
report={'kind':'phase3-frozen-final-frontend-comparison','scope':'All pinned parse/check probes, serial persistent workers; exact observations and diagnostics retained. Workflow wall observations only, not a repeated paired performance benchmark or full-language conformance.','files':{k:{'file':str(f),'sha256':sha(f)} for k,f in files.items()},'inputsUnchanged':True,'sameProbeInventory':True,'fixtureCount':len(r['candidate']['inventory']['tests']),'probeCount':len(maps['candidate']),'summaries':{k:v['summary'] for k,v in r.items()},'workflowMilliseconds':{k:(datetime.datetime.fromisoformat(r[k]['finished'].replace('Z','+00:00'))-datetime.datetime.fromisoformat(r[k]['started'].replace('Z','+00:00'))).total_seconds()*1000 for k in ['candidate','upstream']},'workerStats':{k:r[k]['workers'] for k in ['candidate','upstream']},'historicalBehaviorChanges':changes,'liveMismatches':mismatches,'newLiveMismatches':new,'resolvedLiveMismatches':resolutions,'currentVersusHistoricalReferenceChanges':[{'key':k,'previous':observed(maps['phase2Upstream'][k]),'current':observed(maps['upstream'][k])} for k in maps['upstream'] if not same(maps['upstream'][k],maps['phase2Upstream'][k])],'allLaneCompleteness':{'candidate':r['candidate']['complete'],'upstream':r['upstream']['complete']}}
(root/'comparison.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:len(report[k]) for k in ['historicalBehaviorChanges','liveMismatches','newLiveMismatches','resolvedLiveMismatches','currentVersusHistoricalReferenceChanges']},indent=2))
