"""Read-only verification of frozen Phase 4 proof and full frontend observations."""
from pathlib import Path
import json, hashlib, datetime
R=Path(__file__).resolve().parents[3]; P=R/'selfhost'; B=P/'build/phase4'
def load(p):return json.loads(Path(p).read_text())
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def identity(p):return {'file':str(p),'sha256':sha(p),'bytes':Path(p).stat().st_size}
proof=load(B/'combined-fixedpoint/report.json'); checked=load(B/'combined-checked/report.json'); comparison=load(B/'frontend-combined/comparison.json'); execution=load(B/'frontend-combined/execution.json')
assert proof['complete'] and checked['complete'] and checked['inputsUnchanged'] and execution['complete'] and comparison['complete']
assert checked['source']['sha256']==proof['sourceSha256']=='34c6ef63931e522a96a4203f8bbd8e103d3a27636cce5dd42d9ec57a8587d122'
assert checked['api']['sha256']==proof['initialCompiler']['sha256']=='0653f21e7e227bf7bf7e3ad777630da64d520534753900636a571ed57a43f810'
for item in [checked['source'],checked['api'],proof['sourceIdentity'],proof['base'],proof['driver']]+proof['hostHelpers']:
 assert sha(item['file'])==item['sha256']
assert len(checked['modules'])==59
for m in checked['modules']:
 assert sha(m['destination'])==m['sha256'] and sha(P/m['relative'])==m['sha256'],m['relative']
assert sha(P/'src/runtime.mjs')==sha(B/'baseline/src/runtime.mjs')==proof['runtimeSha256']
assert len(proof['stages'])==2
outputs=[]
for s in proof['stages']:
 assert s['code']==0 and s['signal'] is None and s['inputsVerified'] and sha(s['output'])==s['outputSha256']
 outputs.append(Path(s['output']).read_bytes())
assert outputs[0]==outputs[1]
reports={k:load(v['file']) for k,v in comparison['files'].items()}
for k,v in comparison['files'].items(): assert sha(v['file'])==v['sha256']
for k,report in reports.items():
 assert len(report['results'])==2756 and report['inventory']['total']==1378
 assert not report['changedInputs'] and not report['identity']['changedArtifacts'] and not report['identity']['adapterChangedDuringRun']
 assert all(not w['errors'] and w['stats']['timeouts']==0 and w['stats']['failures']==0 for w in report['workers'])
 assert all(r['result'].get('status') not in ['timeout','crash','unsupported'] for r in report['results'])
 if k in ['candidate','reference']:
  for path,h in report['inputHashes'].items():assert sha(path)==h,path
  for artifact in report['identity']['artifacts'].values():assert sha(artifact['file'])==artifact['sha256']
assert reports['candidate']['identity']['artifacts']['compiler']['sha256']==checked['api']['sha256']
def inventory(r):return sorted((x['id'],x['sha256']) for x in r['inventory']['tests'])
assert all(inventory(r)==inventory(reports['candidate']) for r in reports.values())
def observations(r):
 out={}
 for row in r['results']:
  v=row['result']; key=row['id']+'::'+row['lane']; assert key not in out
  text=next((v[k] for k in ['diagnostic','output','stdout'] if v.get(k) is not None),'')
  out[key]=([v.get(k) for k in ['status','phase','checked','exitCode','signal']],text)
 return out
maps={k:observations(v) for k,v in reports.items()}
assert maps['candidate']==maps['previousCandidate'] and maps['reference']==maps['previousReference']
assert maps['candidate'].keys()==maps['reference'].keys()
mismatches=[k for k in maps['candidate'] if maps['candidate'][k]!=maps['reference'][k]]
assert len(mismatches)==560 and set(mismatches)=={x['key'] for x in comparison['liveMismatches']}
assert not comparison['historicalBehaviorChanges'] and not comparison['referenceChanges'] and not comparison['newLiveMismatches'] and not comparison['resolvedLiveMismatches']
result={'kind':'phase4-independent-final-source-verification','verifiedAt':datetime.datetime.now(datetime.timezone.utc).isoformat(),'complete':True,'source':checked['source'],'api':checked['api'],'modulesVerifiedAgainstFrozenAndCurrentSource':59,'runtimeSha256':proof['runtimeSha256'],'base':proof['base'],'proof':identity(B/'combined-fixedpoint/report.json'),'stageOutputs':[identity(s['output']) for s in proof['stages']],'stageBytesIdentical':True,'stageMilliseconds':[s['ms'] for s in proof['stages']],'frontend':{'fixtures':1378,'probesPerCompiler':2756,'historicalBehaviorChanges':0,'referenceChanges':0,'liveMismatches':560,'newLiveMismatches':0,'resolvedLiveMismatches':0,'fixtureAndArtifactBytesReverified':True,'reports':{k:identity(v['file']) for k,v in comparison['files'].items()}},'scope':'Correctness and unchanged observations, not full language conformance or a controlled frontend performance comparison. An unrelated CPU1 audit overlapped 16:53:08.193–16:53:11.397 UTC (3.204s).'}
print(json.dumps(result,indent=2))
