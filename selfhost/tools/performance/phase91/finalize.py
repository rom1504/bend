#!/usr/bin/env python3
"""Join closed current-release metrics and guarded execution; no target execution."""
import hashlib,json,pathlib,statistics
ROOT=pathlib.Path(__file__).resolve().parents[4]
def pin(path):
 data=path.read_bytes();return dict(file=path.relative_to(ROOT).as_posix(),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
def main():
 inputs=[]
 def read(name):
  p=ROOT/name;inputs.append(pin(p));return json.loads(p.read_text())
 continuity=read('implementation/phase91/continuity.json');assert continuity['complete'] and continuity['pass']
 census=read('implementation/phase91/census01.json');assert census['complete'] and census['inputsUnchanged']
 conform=read('implementation/phase91/conformance-results02.json');assert conform['complete'] and not conform['passed']
 compilation={}
 for target in ['js','c']:
  r=read(f'selfhost/build/phase91/compilation01/{target}-clean.json');assert r['complete'] and r['passed'] and r['inputsUnchanged']
  assert len(r['rows'])==({'js':207,'c':27}[target])
  compilation[target]=dict(freshTiming=True,sources=len(r['summary']),rounds=3,samples=len(r['rows']),ratios=r['geometricRatiosToTypeScript'],wallSeconds=r['wallSeconds'],scope=r['scope'])
 guards=[]
 for path in sorted((ROOT/'selfhost/build/phase91').rglob('process.json')):
  r=json.loads(path.read_text());assert r.get('finished') and 'wallSeconds' in r and not r.get('stoppedFor')
  inputs.append(pin(path));guards.append(dict(file=path.relative_to(ROOT).as_posix(),**r))
 guards.sort(key=lambda r:r['started'])
 assert all(a['finished']<=b['started'] for a,b in zip(guards,guards[1:]))
 negatives=[r for r in guards if r['returncode']!=0]
 assert {r['file'] for r in negatives}=={'selfhost/build/phase91/frontend01/guard/process.json','selfhost/build/phase91/deep-diagnostic01/b2/guard/process.json','selfhost/build/phase91/deep-diagnostic01/old-b2/guard/process.json'}
 assert all(r['returncode']==1 for r in negatives)
 assert all(r['complete'] for r in guards if r not in negatives)
 counts=dict(jobs=len(guards),successfulProcesses=len(guards)-len(negatives),completedNonzeroProcesses=len(negatives),resourceStops=0,overlappingTargetPairs=0,
             guardedSeconds=sum(r['wallSeconds'] for r in guards),guardedSpanSeconds=guards[-1]['finished']-guards[0]['started'],
             peakTreeRssBytes=max(r['peakTreeRssBytes'] for r in guards))
 release=read('selfhost/build/phase91/release-verify/process.json');assert release['complete']
 result=dict(kind='phase91-five-metric-scoreboard',complete=True,compilerChanged=False,
   source=census['manifest'],images=census['images'],upstream=census['upstream'],
   ratioDefinition='our time / same-campaign pinned upstream time; lower is better',
   generatedProgramRuntime=dict(historicalTimings=continuity['historicalTiming'],freshContinuity=continuity['counts'],
       scope='Exact current JS modules and complete O3-preprocessed C on original corpora. No fresh runtime timings or ELF/GPU claim.'),
   compilation=compilation,
   conformance=dict(freshCandidateFrontendObservations=3174,exactHistoricalReferenceAgreements=3173,
       diagnosticMismatchCases=['page/deep_list_walk.bend'],
       diagnosticMismatchCause='B2 diagnostic printer stack exhaustion; current B1/TS print the full page, old and current B2 return the same short fallback; invalid proof is rejected by all.',
       freshCandidateNativeCases=100,passedCandidateNativeCases=100,referenceExecutionFresh=False,
       retainedNativeReference=conform['retainedNativeReference']['statuses'],
       remainingNativeUnsupportedAPIs=13,fullLanguageConformance=False,
       scope=conform['limits']),
   simplicity=dict(moduleCount=census['moduleCount'],**census['bendTotals'],sourceDeltaThisPhase=0,
       concepts='No established numeric semantic-concept measure or demonstrated reduction.'),
   execution=counts,inputs=inputs,
   limits=['Node-hosted JS B1/B2 request latency is distinct from native07 host latency.',
           'Phase90 native six-case and full-self results remain separate dated measurements.',
           'No full JS1170 or native/GPU-language census was rerun.',
           'Historical ratio changes across campaigns are not causal optimization estimates.'])
 for expected in inputs:assert pin(ROOT/expected['file'])==expected
 out=ROOT/'implementation/phase91/summary.json';assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n')
 ledger=ROOT/'implementation/phase91/execution-ledger.json';assert not ledger.exists()
 ledger.write_text(json.dumps(dict(complete=True,summary=counts,jobs=guards),indent=2)+'\n')
 print(json.dumps(dict(complete=True,execution=counts,compilation=compilation)))
if __name__=='__main__':main()
