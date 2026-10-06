#!/usr/bin/env python3
"""Read three completed ablation runs; preserve their separate denominators."""
import argparse
import hashlib
import json
from pathlib import Path
import statistics
import sys

sys.dont_write_bytecode = True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--root',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();root=a.root.resolve(strict=True);out=a.out.resolve()
assert root.is_relative_to(ROOT/'selfhost/build/phase58') and out.is_relative_to(ROOT/'selfhost/build/phase58') and not out.exists()
inputs={}
def pin(path):
    path=Path(path).resolve(strict=True);data=path.read_bytes()
    row=dict(path=str(path),sha256=hashlib.sha256(data).hexdigest(),bytes=len(data))
    if str(path) in inputs:assert inputs[str(path)]==row
    inputs[str(path)]=row;return row
def read(path):pin(path);return json.loads(Path(path).read_text())
pin(__file__)
prep=read(root/'report.json');assert prep['complete'] and prep['pass'] and prep['dataOnly'] and not prep['targetExecuted']
commands=read(root/'commands.json');assert pin(root/'commands.json')['sha256']==prep['commands']['sha256']
assert len(commands['commands'])==3 and prep['requiredSamples']==72 and prep['optionalSamples']==36
worker=next(x for x in prep['inputs'] if x['path'].endswith('/programs/execute.mjs'))
assert [r['id'] for r in prep['byteComparison']]==prep['ids']
assert {r['id'] for r in prep['byteComparison'] if r['byteEqual']}=={'test-map-set-ops','editdist'}
runs=[]
for index,command in enumerate(commands['commands']):
    argv=command['argv']
    arg=lambda name:argv[argv.index(name)+1]
    assert arg('--budget')=='60' and arg('--cpu')=='3' and arg('--rss-mib')=='2048' and arg('--available-mib')=='4096'
    selected=arg('--cases').split(',')
    assert selected==(list(reversed(prep['ids'])) if index==1 else prep['ids'])
    baseline=read(arg('--baseline'));candidate=read(arg('--candidate'));catalog=read(arg('--catalog'))
    catalog_hash=pin(arg('--catalog'))['sha256'];assert baseline['catalogSha256']==candidate['catalogSha256']==catalog_hash
    roles={**baseline['roles'],**candidate['roles']};assert set(roles)=={'baseline','candidate','typescript'}
    expected={}
    for b in [baseline,candidate]:
        for c in b['cases']:
            if c['id'] in selected:expected.setdefault(c['id'],{}).update(c['modules'])
    points={c['id']:c for c in catalog['cases']}
    report_path=Path(arg('--out'))/'report.json';r=read(report_path)
    assert r['complete'] and r['pass'] and r['status']=='measured' and r['measuredCases']==r['selectedCases']==4
    plan=r['plan'];assert plan['selectedIds']==selected and plan['protocol']==prep['protocol']
    assert plan['budgetSeconds']==60 and plan['cpu']==3 and plan['heapMiB']==1024 and plan['rssMiB']==2048 and plan['availableMiB']==4096
    assert plan['variants']==roles and plan['roles']==['typescript','baseline','candidate']
    assert len(r['cases'])==4 and [c['id'] for c in r['cases']]==selected
    cases=[];sample_count=0
    for c in r['cases']:
        assert c['point']==points[c['id']]['point'] and c['rounds']==3 and c['summary']['complete']
        assert c['summary']['balancedRounds']==[0,1,2] and len(c['samples'])==9
        role_rows={}
        for role in ['baseline','candidate','typescript']:
            samples=[s for s in c['samples'] if s['role']==role]
            assert [s['round'] for s in samples]==[0,1,2]
            values=[];rounds=[]
            for s in samples:
                assert s['complete'] and s['process']['complete'] and s['process']['returncode']==0
                z=s['result'];assert z['complete'] and z['module']['sha256']==expected[c['id']][role]['sha256']
                assert z['toolSha256']==worker['sha256']
                process_command=s['process']['command']
                assert process_command[:4]==['taskset','-c','3',arg('--node')]
                assert '--max-old-space-size=1024' in process_command and '--stack-size=4096' in process_command
                for k in ['exportName','args','expected']:assert z['config'][k]==c['point'][k]
                for k in ['warmupCalls','warmupMs','calibrationMs','targetMs']:assert z['config'][k]==prep['protocol'][k]
                values.append(z['msPerCall']);rounds.append(dict(round=s['round'],msPerCall=z['msPerCall'],
                    halfDriftPercent=z.get('halfDriftPercent'),firstCallMs=z.get('firstCallMs'),importMs=z.get('importMs')))
            median=statistics.median(values);stats=c['summary']['stats'][role]
            assert stats['medianMs']==median and stats['samplesMs']==values
            spread=max(values)/min(values);drift=[v['round'] for v in rounds if abs(v['halfDriftPercent'] or 0)>20]
            role_rows[role]=dict(label=roles[role]['label'],module=expected[c['id']][role],medianMs=median,
                minimumMs=min(values),maximumMs=max(values),maxOverMin=spread,rounds=rounds,
                flags=dict(spreadAbove1_20=spread>1.2,absoluteHalfDriftAbove20PercentRounds=drift))
        ratio={key:role_rows[left]['medianMs']/role_rows[right]['medianMs'] for key,left,right in
               [('baseline/candidate','baseline','candidate'),('baseline/typescript','baseline','typescript'),('candidate/typescript','candidate','typescript')]}
        assert ratio==c['summary']['ratios']
        cases.append(dict(id=c['id'],point=c['point'],choiceSharedByteEqual=next(z['byteEqual'] for z in prep['byteComparison'] if z['id']==c['id']),
            actualBaselineCandidateByteEqual=expected[c['id']]['baseline']['sha256']==expected[c['id']]['candidate']['sha256'],roles=role_rows,ratios=ratio))
        sample_count+=len(c['samples'])
    assert sample_count==36
    runs.append(dict(name=command['name'],baseline='Phase56 String01' if index==2 else 'Phase58 choice01',candidate='Phase58 shared01',
        report=pin(report_path),plan=plan,wallSeconds=r['wallSeconds'],samples=sample_count,cases=cases))
assert sum(x['samples'] for x in runs)==108
lines=['# Shared-SCC runtime ablation','',
       'All three runs completed: 36 fresh samples each. The first two compare choice01 with shared01; the third uses Phase56 String01 as baseline. No samples or medians are pooled across runs.',
       'Baseline/candidate greater than 1 favors shared01. Each row retains its own three-round medians; short warmups are screens, not a steady-state or isolated JIT-cause proof.',
       'MapSet/editdist are byte-identical only in the choice01/shared01 comparison. All flags and individual round values remain in report.json.','']
for run in runs:
    lines += ['## '+run['name'],'',f"Baseline: {run['baseline']}; candidate: {run['candidate']}. Wall {run['wallSeconds']:.3f}s.",'',
              '| Case | Baseline µs | Shared µs | TS µs | Baseline/shared | Shared/TS | Flagged roles |','|---|---:|---:|---:|---:|---:|---|']
    for c in run['cases']:
        rr=c['roles'];flags=[role for role,row in rr.items() if row['flags']['spreadAbove1_20'] or row['flags']['absoluteHalfDriftAbove20PercentRounds']]
        lines.append(f"| {c['id']} | {rr['baseline']['medianMs']*1000:.6g} | {rr['candidate']['medianMs']*1000:.6g} | {rr['typescript']['medianMs']*1000:.6g} | {c['ratios']['baseline/candidate']:.6f} | {c['ratios']['candidate/typescript']:.6f} | {', '.join(flags) or 'none'} |")
    lines.append('')
for row in list(inputs.values()):assert pin(row['path'])==row
result=dict(kind='phase58-scc-runtime-ablation-results',complete=True,dataOnly=True,targetsExecutedByAnalyzer=False,
    preparation=pin(root/'report.json'),runs=runs,samples=108,pooled=False,
    scope='Completed-run arithmetic and identity join. Explicitly separate choice01 and Phase56 denominators; no compiler change, isolated JIT explanation, promotion threshold or whole-corpus claim.',
    inputs=list(inputs.values()),inputsUnchanged=True)
out.mkdir();(out/'report.json').write_text(json.dumps(result,indent=2)+'\n');(out/'report.md').write_text('\n'.join(lines))
print(json.dumps(dict(complete=True,report=pin(out/'report.json'),samples=108,runs=3)))
