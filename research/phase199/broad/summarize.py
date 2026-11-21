#!/usr/bin/env python3
"""Reauthenticate the complete three-role screen, without executing programs."""
import argparse, importlib.util, json, sys
from pathlib import Path
from types import SimpleNamespace
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3]
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
P=load('p193summary',ROOT/'selfhost/tests/phase193/summarize.py');B,C=P.B,P.C
P.S.PARTITION=ROOT/'research/phase198/runtime-broad/partition.json'

def summarize(plan,run):
 proof=B.read(plan/'report.json');manifest=B.read(plan/'manifest.json');raw=B.read(run/'report.json')
 C.require(proof['complete'] and proof['manifest']==C.pin(plan/'manifest.json'),'Completed frozen preparation required')
 for pin in proof['inputs']:C.verify(pin)
 C.verify(proof['native']);C.verify(proof['source']);C.verify(proof['baseline']);C.verify(proof['baselinePreparation'])
 native=B.read(proof['native']['file']);baseline=B.read(proof['baseline']['file']);held=B.read(ROOT/'research/phase198/runtime-broad/portfolio-pins.json');mature=B.read(held['matureC']['file'])
 keyed=lambda doc:{c['id']:c for c in doc['cases']}
 cases,new,old,refs=map(keyed,[manifest,native,baseline,mature])
 C.require(len(cases)==45 and cases.keys()==new.keys()==old.keys()==refs.keys()==proof['cases'].keys(),'Complete equal native45 coverage required')
 C.require(list(manifest['roles'])==['c','baseline','candidate'] and raw['roles']==manifest['roles'],'Exact three roles required')
 C.require(manifest['roles']['candidate']['compilerSource']==proof['source'] and manifest['roles']['candidate']['runtime']==proof['liveRuntime'],'Source/live runtime identity differs')
 C.require(manifest['roles']['baseline']==baseline['roles']['live'] and manifest['roles']['c']==mature['roles']['c'],'Reference roles differ')
 preflights=0
 for name,case in cases.items():
  row=proof['cases'][name];C.verify(row['production']);C.verify(row['object']);C.verify(row['default']);C.verify(row['live'])
  original=new[name]['products']['candidate']
  C.require(case['products']['c']==refs[name]['products']['c'] and case['products']['baseline']==old[name]['products']['live'],'Reference products differ')
  C.require(case['products']['candidate']==dict(original,artifact=row['live']),'Candidate must retain the native emitted object and inputs')
  C.require(row['default']==original['artifact'] and row['object']==original['generatedSource'] and all(row['verifiedDefaultRelink'][k]==row['default'][k] for k in ('bytes','sha256')),'Original-runtime exact relink check differs')
  for alias,check in row['oracles'].items():
   proc=check['process'];point=dict(case['point'],repetitions=int(case['point']['repetitions']>0),warmups=0)
   product=case['products'][alias];command=[product['artifact']['file'],*B.native_runtime_arguments(product),str(point['repetitions']),'0',*map(str,point['runtimeArgs'])]
   C.require(proc['command']==command and not proc['timedOut'],'Preflight invocation differs')
   elapsed=B.observation(C.verify(proc['stdout']).read_bytes(),C.verify(proc['stderr']).read_bytes(),proc['exitCode'],point,proc['seconds'])
   C.require(elapsed==check['elapsedMs'] and check['repetitions']==point['repetitions'],'Preflight metric differs');preflights+=1
  C.require(set(row['oracles'])==set(manifest['roles']),'All role preflights required')
 C.require(preflights==proof['independentObservations']==135,'135 independent preflight observations required')
 C.require(raw['rounds']==3 and raw['positionBalanced'] and raw['targetMs']==140 and raw['minimumAcceptedMs']==100,'Frozen short-screen timing policy differs')
 result=P.S.summarize(SimpleNamespace(report=run/'report.json',references=plan/'manifest.json',c_role='c',baseline_role='baseline',spread_limit=1.10,emission=[]))
 for case in result['cases']:
  C.require(all(case['artifacts'][role]==cases[case['id']]['products'][role]['artifact'] for role in result['roles']),'Timed artifacts differ from frozen products')
 C.require(result['subsets']['all']['caseCount']==45 and result['subsets']['all']['ratioEligibleCount']==44 and result['oracleRevalidated']['samples']==405,'Complete 45-case / 405-sample run required')
 result.update(kind='phase199-three-role-authenticated-summary',inheritedMethod=result['method'],method=C.pin(__file__),preparation=C.pin(plan/'report.json'),source=proof['source'],preflightObservations=preflights,unchangedCases=proof['unchangedCases'])
 result['scope']+=' Three roles and three position-balanced rounds at 140 ms calibration target replace the historical four-role/four-round/250 ms screen; the 100 ms acceptance floor, original catalog workloads, outputs, fixed-work weights and dispersion checks are unchanged. Development/heldout labels reuse the Phase198 partition and do not assert fresh unseen transfer. All 45 cases are timed, including byte-identical products. This is an N1 candidate screen, not N2/N3 reproduction or installed release qualification.'
 return result
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--plan',type=Path,required=True);p.add_argument('--run',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();md=a.out.with_suffix('.md')
 C.require(a.out.suffix=='.json' and not a.out.exists() and not md.exists(),'Fresh JSON and Markdown required')
 r=summarize(a.plan,a.run);a.out.parent.mkdir(parents=True,exist_ok=True);B.save(a.out,r,fresh=True);md.write_text(P.markdown(r).replace('# Phase193 runtime summary','# Phase199 three-role runtime screen',1));print(json.dumps({'summary':str(a.out),'observations':r['oracleRevalidated'],'candidate':r['subsets']['all']['roles']['candidate'],'warnings':r['warnings']}))
