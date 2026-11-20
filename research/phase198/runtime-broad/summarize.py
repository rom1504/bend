"""Recheck every original oracle, pin, case and comparison before reporting."""
import argparse
import importlib.util
import json
import statistics
from pathlib import Path
from types import SimpleNamespace

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
NOW=ROOT/'selfhost/build/phase198'
spec=importlib.util.spec_from_file_location('broad_summary',ROOT/'selfhost/tests/phase193/summarize.py')
M=importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
M.S.PARTITION=HERE/'partition.json'

def summarize(plan,run,out):
    receipt=M.B.read(plan/'report.json')
    assert receipt['complete'] and receipt['runtime10']['rows'] and receipt['abi']
    M.B.verify(receipt['manifest'])
    manifest=M.B.read(plan/'manifest.json')
    parent=M.B.read(NOW/'broad-runtime-plan01/recipe.json')
    before={c['id']:c for c in parent['cases']}
    assert len(before)==len(manifest['cases'])==45
    for case in manifest['cases']:
        k=case['id']; p=case['products']
        assert p['c']==before[k]['products']['c'] and p['baseline']==before[k]['products']['candidate']
        assert all(p[r]['generatedSource']==receipt['cases'][k]['object'] for r in ('baseline','candidate','live'))
        assert all(p[r]['artifact']==receipt['cases'][k][r] for r in ('candidate','live'))
    args=SimpleNamespace(report=run/'report.json',references=plan/'manifest.json',c_role='c',baseline_role='baseline',spread_limit=1.10,emission=[])
    result=M.S.summarize(args)
    assert result['subsets']['all']['caseCount']==45 and result['subsets']['all']['ratioEligibleCount']==44
    result.update(kind='phase198-split-runtime-broad',complete=True,inheritedMethod=result['method'],method=M.C.pin(__file__),
                  splitRuntime=receipt['runtime'],liveRuntime=receipt['liveRuntime'],originalRuntime=receipt['baseline'],abiReceipt=M.C.pin(plan/'report.json'),
                  scope='Current N1 program objects are identical in both runtime arms. Same-block mature Bend C reference. Development covers all members of seven families used to choose the split runtime. Timed execution uses the maintained complete-output and count protocol.')
    timed=M.B.read(run/'report.json')
    assert timed['rounds']==4 and timed['positionBalanced']
    measured={}
    for role in ('c','baseline','candidate','live'):
        samples=[r['elapsedMs'] for case in timed['cases'] if case['point']['ratioEligible'] for r in case['samples'] if r['role']==role]
        measured[role]=dict(count=len(samples),minimumMs=min(samples),medianMs=statistics.median(samples),maximumMs=max(samples))
    differences=[]
    by_id={case['id']:case for case in timed['cases']}
    for case in result['cases']:
        if case['ratioEligible']:
            baseline=case['ratios']['baseline']['overBaseline']
            assert baseline==1
            live=case['ratios']['live']['overBaseline']
            cached=case['ratios']['candidate']['overBaseline']
            samples={(row['round'],row['role']):row['metricMs'] for row in by_id[case['id']]['samples']}
            pairs=[samples[i,'live']/samples[i,'candidate'] for i in range(timed['rounds'])]
            paired={role:[samples[i,role]/samples[i,'baseline'] for i in range(timed['rounds'])] for role in ('live','candidate')}
            differences.append(dict(id=case['id'],liveOverCached=live/cached,cachedOverOriginal=cached,liveOverOriginal=live,
                                    liveOverCachedByRound=pairs,overOriginalByRound=paired,
                                    materiallyDifferent=live/cached<0.98 or live/cached>1.02,dispersion=case['flagged']))
    result.update(measuredIntervals=measured,liveAgainstCached=differences,materialTolerance=0.02)
    M.B.save(out,result,fresh=True)
    out.with_suffix('.md').write_text(M.markdown(result).replace('# Phase193 runtime summary','# Phase198 split runtime on 45 current programs',1))
    r=result['subsets']['all']['roles']
    print(json.dumps(dict(originalOverC=r['baseline']['overC']['geomean'],splitOverC=r['candidate']['overC']['geomean'],
                          splitOverOriginal=r['candidate']['overBaseline']['geomean'],liveOverC=r['live']['overC']['geomean'],liveOverOriginal=r['live']['overBaseline']['geomean'],heldout=result['subsets']['heldout']['roles']['candidate']['overBaseline']['geomean'])))
if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('--plan',type=Path,required=True)
    p.add_argument('--run',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    summarize(a.plan,a.run,a.out)
