"""Authenticate the composed runtime roles and compare the identical-object arms."""
import argparse
import importlib.util
import json
from pathlib import Path
from types import SimpleNamespace

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('family_summary',ROOT/'selfhost/tests/phase193/summarize.py')
P=importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
P.S.PARTITION=HERE/'partition.json'

def summarize(plan,run,out):
    producer=P.B.read(plan/'report.json')
    assert producer['complete'] and len(producer['cases'])==45
    P.B.verify(producer['native'])
    P.B.verify(producer['source'])
    P.B.verify(producer['manifest'])
    assert producer['manifest']==P.B.pin(plan/'manifest.json')
    held=P.B.read(HERE/'portfolio-pins.json')
    assert producer['inputs']==held
    for v in held.values():P.B.verify(v)
    def cases(manifest):
        return {c['id']:c for c in P.B.read(manifest)['cases']}
    mature=cases(held['matureC']['file'])
    phase197=cases(held['phase197']['file'])
    composed=cases(producer['native']['file'])
    for name,c in cases(plan/'manifest.json').items():
        p=c['products']
        assert p['c']==mature[name]['products']['c'] and p['phase197']==phase197[name]['products']['candidate']
        assert p['candidate']==composed[name]['products']['candidate']
        proof=producer['cases'][name]
        assert dict(p['candidate'],artifact=proof['live'])==p['live'] and p['candidate']['generatedSource']==proof['object']
        assert proof['originalRelink']['sha256']==p['candidate']['artifact']['sha256'] and len(proof['oracles'])==4
    def collect(baseline):
        return P.S.summarize(SimpleNamespace(report=run/'report.json',references=plan/'manifest.json',
            c_role='c',baseline_role=baseline,spread_limit=1.1,emission=[]))
    result=collect('phase197')
    same=collect('candidate')
    assert result['positionBalanced'] and result['rounds']==4 and result['subsets']['all']['caseCount']==45
    assert result['oracleRevalidated']['samples']==720 and result['subsets']['all']['ratioEligibleCount']==44
    result.update(kind='phase198-portfolio-live-broad',complete=True,method=P.C.pin(__file__),producer=P.B.pin(plan/'report.json'),
        liveAgainstOriginalPortfolio={k:g['roles']['live']['overBaseline'] for k,g in same['subsets'].items()},
        liveAgainstOriginalPortfolioCases={c['id']:c['ratios']['live']['overBaseline'] for c in same['cases'] if c['ratioEligible']},
        scope='All 45 cases are executed. Reference baselines are authenticated C and Phase197. Live/portfolio compares the same emitted N1 objects. The development partition describes the seven runtime-study families and does not establish an independent compiler holdout.')
    P.B.save(out,result,fresh=True)
    out.with_suffix('.md').write_text(P.markdown(result).replace('# Phase193 runtime summary','# Composed portfolio and live constructor runtime',1))
    allroles=result['subsets']['all']['roles']
    print(json.dumps(dict(portfolioOverC=allroles['candidate']['overC']['geomean'],portfolioOverPhase197=allroles['candidate']['overBaseline']['geomean'],
        liveOverC=allroles['live']['overC']['geomean'],liveOverPhase197=allroles['live']['overBaseline']['geomean'],
        liveOverOriginalPortfolio=result['liveAgainstOriginalPortfolio']['all']['geomean'])))

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--plan',required=True,type=Path)
    p.add_argument('--run',required=True,type=Path)
    p.add_argument('--out',required=True,type=Path)
    a=p.parse_args()
    summarize(a.plan,a.run,a.out)
