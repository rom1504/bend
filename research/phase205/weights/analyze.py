#!/usr/bin/env python3
"""Exact fixed-weight Phase200 excess accounting; no benchmark execution."""
import argparse,hashlib,json,math,statistics
from collections import defaultdict
from fractions import Fraction as F
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
def pin(path):
 path=Path(path).resolve();b=path.read_bytes();return dict(file=str(path),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def exact(x):return dict(seconds=float(x),exactSeconds=str(x))
def group(rows):
 candidate=sum((r['_candidate'] for r in rows),F());c=sum((r['_c'] for r in rows),F());signed=candidate-c;positive=sum((max(F(),r['_candidate']-r['_c']) for r in rows),F())
 return dict(cases=[r['id'] for r in rows],caseCount=len(rows),candidate=exact(candidate),c=exact(c),signedExcess=exact(signed),positiveCaseExcess=exact(positive),netFamilyExcess=exact(max(F(),signed)),ratio=float(candidate/c) if c else None)
def public(row):return {k:v for k,v in row.items() if not k.startswith('_')}
def main():
 p=argparse.ArgumentParser();p.add_argument('--summary',type=Path,default=ROOT/'research/phase200/measure/recovered-summary01.json');p.add_argument('--report',type=Path);p.add_argument('--out',type=Path,default=HERE/'results01.json');a=p.parse_args();assert not a.out.exists() and not a.out.with_suffix('.md').exists()
 summary=json.loads(a.summary.read_text());report=a.report or Path(summary['report']['file']);actual=pin(report);assert all(actual[k]==summary['report'][k] for k in ('bytes','sha256'));raw=json.loads(report.read_text())
 assert summary['kind']=='phase200-recovered-observations-summary' and summary['completeObservedEvidence'] and not summary['executionGuardSucceeded']
 assert summary['source']['sha256']=='c8b1b8a30d08e15e37d92cd6ed65ccc33b9bff484957e21ebeb903069ef106d7'
 assert raw['rounds']==3 and raw['positionBalanced'] and len(raw['cases'])==45 and summary['oracleRevalidated']['samples']==405
 prior={c['id']:c for c in summary['cases']};rows=[];families=defaultdict(list);sources=defaultdict(list)
 for case in raw['cases']:
  if not case['point']['ratioEligible']:continue
  assert len(case['samples'])==9
  values={}
  for role in ('candidate','c'):
   samples=[F(str(r['elapsedMs']))/r['repetitions'] for r in case['samples'] if r['role']==role];assert len(samples)==3
   values[role]=statistics.median(samples)*case['point']['repetitions']/1000
   assert math.isclose(float(values[role]),prior[case['id']]['fixedEquivalentMs'][role]/1000,rel_tol=1e-12,abs_tol=1e-12)
  r=dict(id=case['id'],family=case['family'],sourceGroup=case['sourceGroup'],catalogRepetitions=case['point']['repetitions'],candidate=exact(values['candidate']),c=exact(values['c']),signedExcess=exact(values['candidate']-values['c']),positiveExcess=exact(max(F(),values['candidate']-values['c'])),dispersionFlagged=prior[case['id']]['flagged'],_candidate=values['candidate'],_c=values['c'])
  rows.append(r);families[r['family']].append(r);sources[r['sourceGroup']].append(r)
 assert len(rows)==44
 total=group(rows);candidate=sum((r['_candidate'] for r in rows),F());c=sum((r['_c'] for r in rows),F());target=F(3,2)*c;need=candidate-target
 saved=summary['subsets']['all']['roles']['candidate']['overC'];assert math.isclose(float(candidate),saved['fixedEquivalentMs']/1000,rel_tol=1e-12)
 scenarios={
  'lexer':['lexer'],'unicode-text':['unicode-text'],'tree-bitonic':['tree-bitonic'],'bst':['bst'],'expression':['expression'],
  'lexer+text':['lexer','unicode-text'],
  'lexer+text+tree-bitonic':['lexer','unicode-text','tree-bitonic'],
  'lexer+text+tree-bitonic+bst':['lexer','unicode-text','tree-bitonic','bst'],
  'lexer+text+tree-bitonic+bst+expression':['lexer','unicode-text','tree-bitonic','bst','expression']}
 ceilings={}
 for name,selected in scenarios.items():
  subset=[r for r in rows if r['family'] in selected];g=group(subset);budget=sum((r['_candidate'] for r in subset),F());parity=sum((r['_candidate']-r['_c'] for r in subset),F());positive=sum((max(F(),r['_candidate']-r['_c']) for r in subset),F())
  ceilings[name]=dict(families=selected,sourceGroups=sorted({r['sourceGroup'] for r in subset}),observed=g,cParitySavings=exact(parity),noRegressionCParitySavings=exact(positive),absoluteZeroCostSavings=exact(budget),wholeRatioAtCParity=float((candidate-parity)/c),wholeRatioAtNoRegressionCParity=float((candidate-positive)/c),wholeRatioAtZeroCost=float((candidate-budget)/c),wholeRatioAtSelectedSourceSpeedup1_5=float((candidate-budget/3)/c),canReachThresholdAtCParity=parity>=need,canReachThresholdAtZeroCost=budget>=need,requiredGroupReductionFraction=float(need/budget),requiredGroupSpeedup=float(budget/(budget-need)) if budget>need else None,requiredFractionOfPositiveExcess=float(need/positive) if positive else None,remainingSavingAfterCParity=exact(max(F(),need-parity)))
 source_rows={key:dict(families=sorted({r['family'] for r in rs}),**group(rs)) for key,rs in sources.items()}
 result=dict(kind='phase205-frozen-phase200-fixed-weights',complete=True,programsExecuted=False,method=pin(__file__),summary=pin(a.summary),report=actual,source=summary['source'],executionGuardSucceeded=False,formula='seconds(role,case)=median(exact elapsedMs/repetitions over the three measured role samples)*original catalog repetitions/1000; aggregate before taking ratios. Calibration counts never become catalog weights.',total=total,threshold=dict(maximumWholeRatioToC=1.5,targetCandidate=exact(target),requiredSaving=exact(need),requiredCandidateReductionFraction=float(need/candidate)),families={name:group(rs) for name,rs in sorted(families.items(),key=lambda kv:-sum((max(F(),r['_candidate']-r['_c']) for r in kv[1]),F()))},sourceGroups=source_rows,ceilings=ceilings,cases=[public(r) for r in rows],scope='Arithmetic ceiling only, not a new measurement or demonstrated implementation. Source transfer means all observed inputs sharing the explicit source hash, not a proof that a rule transfers. Lexer, Unicode text, tree-bitonic, BST and expression are separate explicit groups; combined scenarios are unions without double counting. C parity is a reference scenario, not a physical lower bound; zero-cost elimination is the absolute source-only bound with everything else fixed. Original Phase200 guard failed disk budget; all captured observations were independently recovered. Dispersion flags and frozen fixed workloads remain unchanged.')
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
 lines=['# Frozen Phase200 fixed-work ceilings','',result['scope'],'',f"Candidate {float(candidate):.9f} s; C {float(c):.9f} s; ratio {float(candidate/c):.9f}. Signed excess {float(candidate-c):.9f} s; positive per-case excess {total['positiveCaseExcess']['seconds']:.9f} s.",f"To reach 1.5× C: save {float(need):.9f} s ({100*float(need/candidate):.6f}% of candidate time); target {float(target):.9f} s.",'','| Family | Cases | Candidate s | C s | Signed excess s | Positive excess s |','|---|---:|---:|---:|---:|---:|']
 for name,g in result['families'].items():lines.append(f"| {name} | {g['caseCount']} | {g['candidate']['seconds']:.9f} | {g['c']['seconds']:.9f} | {g['signedExcess']['seconds']:.9f} | {g['positiveCaseExcess']['seconds']:.9f} |")
 lines+=['','| Source-group scenario | Cases | C-parity saving s | Zero-cost ceiling s | Whole / C at parity | Required group speedup |','|---|---:|---:|---:|---:|---:|']
 for name,v in ceilings.items():lines.append(f"| {name} | {v['observed']['caseCount']} | {v['cParitySavings']['seconds']:.9f} | {v['absoluteZeroCostSavings']['seconds']:.9f} | {v['wholeRatioAtCParity']:.9f} | {v['requiredGroupSpeedup'] if v['requiredGroupSpeedup'] is not None else 'impossible'} |")
 lines+=['','Exact rational seconds, every case/source hash, scenario membership, dispersion flags and a 1.5× selected-source-speedup scenario are retained in JSON.','Reproduce: `python3 -B research/phase205/weights/analyze.py --out /tmp/phase205-weights.json`. Use `--report` for an extracted archived report with identical bytes.']
 a.out.with_suffix('.md').write_text('\n'.join(lines)+'\n');print(json.dumps(dict(out=str(a.out),total=total,threshold=result['threshold'],ceilings={k:{x:v[x] for x in ['cParitySavings','absoluteZeroCostSavings','wholeRatioAtCParity','requiredGroupSpeedup','canReachThresholdAtCParity']} for k,v in ceilings.items()})))
if __name__=='__main__':main()
