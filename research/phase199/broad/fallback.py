#!/usr/bin/env python3
"""Explicit two-role/two-round fallback; no freshly matched C timing claim."""
import argparse,importlib.util,json,sys
from pathlib import Path
from types import SimpleNamespace
sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def module(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
R=module('runtime',HERE/'runtime.py');B=R.B
A=module('analysis',ROOT/'selfhost/tests/phase186/analyze-runtime.py')
def summarize(plan,out):
 shared=B.read(plan/'manifest.json');prep=B.read(plan/'report.json');raw=B.read(out/'timing/report.json');r=A.analyze(out/'timing/report.json')
 assert prep['complete'] and prep['manifest']==B.pin(plan/'manifest.json')
 assert r['roles']==['baseline','candidate'] and r['rounds']==2 and r['positionBalanced']
 assert r['caseCount']==45 and r['ratioEligibleCount']==44 and r['oracleRevalidated']['samples']==180
 assert raw['targetMs']==140 and raw['minimumAcceptedMs']==100
 cases={c['id']:c for c in shared['cases']};c_observations=0
 for case in r['cases']:
  fixed=cases[case['id']]
  for role in r['roles']:assert case['artifacts'][role]==fixed['products'][role]['artifact']
  check=prep['cases'][case['id']]['oracles']['c'];proc=check['process'];point=dict(fixed['point'],repetitions=int(fixed['point']['repetitions']>0),warmups=0)
  assert not proc['timedOut'] and proc['command'][0]==fixed['products']['c']['artifact']['file']
  elapsed=B.observation(B.verify(proc['stdout']).read_bytes(),B.verify(proc['stderr']).read_bytes(),proc['exitCode'],point,proc['seconds']);assert elapsed==check['elapsedMs'];c_observations+=1
 for case in raw['cases']:
  for row in case['samples']:assert not case['point']['ratioEligible'] or row['elapsedMs']>=100
 r.update(kind='phase199-two-round-native-pair-fallback',method=B.pin(__file__),sharedPreparation=B.pin(plan/'report.json'),source=prep['source'],bundle=prep['bundle'],matchedComparison=A.compare(r,r,'baseline','candidate',False),matureCPreflightsRevalidated=c_observations,matureCTiming='Not freshly timed in fallback; no matched candidate/C ratio is reported.',scope='All45/44 eligible, original catalog/work/count oracles, two native roles with two position-balanced rounds and unchanged140/100ms target/floor. Shorter sample set is explicitly lower confidence. All dispersed cases retained; no installed qualification or C speed comparison.')
 B.save(out/'summary.json',r,fresh=True)
 stats=r['totals']['candidate'];(out/'summary.md').write_text('# Two-round native pair fallback\n\n'+r['scope']+'\n\nCandidate / incumbent geometric mean: '+str(stats['geomeanOverReference'])+'. Fixed-catalog ratio: '+str(stats['fixedCatalogTotalRatio'])+'.\n\n'+r['matureCTiming']+'\n')
 print(json.dumps(dict(summary=str(out/'summary.json'),matchedComparison=r['matchedComparison'],flaggedCases=r['flaggedCases'])))
def run(plan,out):
 shared=R.load(plan/'manifest.json');assert list(shared['roles'])==['c','baseline','candidate'] and len(shared['cases'])==45
 out=out.resolve();out.mkdir(parents=True,exist_ok=False)
 R.merge(SimpleNamespace(cases=','.join(c['id'] for c in shared['cases']),role=[(role,plan/'manifest.json',role) for role in ['baseline','candidate']],reference='baseline',out=out/'pair-plan'))
 result=R.run(SimpleNamespace(manifest=out/'pair-plan/manifest.json',out=out/'timing',cases=None,rounds=2,target_ms=140,cpu=3,seconds=135,guarded=True));assert result['complete'];summarize(plan,out)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--plan',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args();run(a.plan,a.out)
