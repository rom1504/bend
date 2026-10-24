"""Seal/analyze three native request pairs for an unqualified QBE ceiling.

Reuse the frozen request arguments, compact Base and exact QBE oracles. The
existing profiler rotates cases and variant order across three clean rounds.
No upstream rerun, generated-product machine build, or self-hosting campaign.
"""
import argparse
import copy
import importlib.util
import json
import math
from pathlib import Path
import statistics as S

ROOT=Path(__file__).resolve().parents[5]
spec=importlib.util.spec_from_file_location('probe',Path(__file__).with_name('reader-identity-probe.py'))
probe=importlib.util.module_from_spec(spec);spec.loader.exec_module(probe);pin=probe.pin

def save(path,data):
    with path.open('x') as f:json.dump(data,f,indent=2);f.write('\n')

def prepare(out):
    frozen=ROOT/'selfhost/build/phase131/final-profile01/manifest.json'
    patch=ROOT/'selfhost/build/phase131/owning-identity-full-probe01/report.json'
    audit=ROOT/'selfhost/build/phase131/owning-identity-full-audit01.json'
    proof=ROOT/'selfhost/build/phase131/laws-string-reflexivity01/report.json'
    control_build=ROOT/'selfhost/build/phase111/p131-final-native01-n2/report.json'
    candidate_build=ROOT/'selfhost/build/phase111/p131-owning-identity-native01/report.json'
    base=json.loads(frozen.read_text());p=json.loads(patch.read_text())
    left=json.loads(control_build.read_text());right=json.loads(candidate_build.read_text())
    assert p['complete'] and p['kind']=='owning-adapter-identity' and not p['productionChange']
    assert left['complete'] and right['complete']
    assert p['ceiling'] in right['inputs']
    frozen_qbe=pin(ROOT/'selfhost/build/phase130/p131-final-self01/program.ssa')
    assert frozen_qbe in left['inputs'] and frozen_qbe in p['inputs']
    runtime=pin(ROOT/'selfhost/build/phase128/runtime-borrow01/runtime.o')
    assert runtime in left['inputs'] and runtime in right['inputs']
    inputs=[pin(Path(__file__)),pin(frozen),pin(patch),pin(audit),pin(proof),
            pin(control_build),pin(candidate_build),*left['inputs'],*right['inputs'],*base['inputs']]
    workloads=[]
    for old in base['workloads']:
        assert len(old['variants'])==1
        original=old['variants'][0];assert original['binary']==left['binary']
        assert original['expected']['stdout']['kind']=='exact' and original['expected']['stderr']['kind']=='exact'
        variants=[]
        for name,build in [('baseline',left),('candidate',right)]:
            v=copy.deepcopy(original);v['name']=name;v['binary']=build['binary'];v['command'][0]=build['binary']['file']
            v['inputs']=[build['binary'] if row==left['binary'] else row for row in v['inputs']]
            variants.append(v)
        workloads.append(dict(name=old['name'],timeoutSeconds=old['timeoutSeconds'],variants=variants))
    assert {w['name'] for w in workloads}=={'lexer','coverage-closures-256','coverage-map-churn-128'}
    for row in inputs:assert pin(Path(row['file']))==row,row['file']
    manifest=dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),inputs=inputs,workloads=workloads,
        sourceSame=True,productionChange=False,independentVerifierAppliedToPatch=False,
        scope='Final N2 versus exact two-adapter identity ceiling. Same runtime, prepared Base, source requests '
              'and frozen complete QBE output. Three rotating paired rounds, complete compiler child only. '
              'No upstream rerun or machine builds. QBE patch is an unqualified performance ceiling, not promotion.')
    save(out/'manifest.json',manifest)
    command=['python3',str(ROOT/'selfhost/tools/performance/phase111/guard.py'),'--out',str(out/'guard'),
        '--seconds','100','--rss-mib','1024','--available-mib','16384','--file-mib','64','--cpu','3','--',
        'python3',str(ROOT/'selfhost/tools/profiler/run.py'),'--manifest',str(out/'manifest.json'),
        '--out',str(out/'timing'),'--modes','clean','--rounds','3']
    summary=['python3',str(Path(__file__).resolve()),'--report',str(out/'timing/report.json'),'--out',str(out/'summary')]
    save(out/'jobs.json',dict(complete=True,targetsRun=False,command=command,summaryCommand=summary))

def analyze(report,out):
    r=json.loads(report.read_text())
    assert r['complete'] and r['passed'] and not r['changedInputs']
    assert r['modes']==['clean'] and r['cleanRounds']==3 and len(r['rows'])==18
    assert all(x['correct'] and not x['diagnosticRuntime'] for x in r['rows'])
    cases=[]
    for name in sorted({x['workload'] for x in r['rows']}):
        rows={role:[x for x in r['rows'] if x['workload']==name and x['variant']==role] for role in ['baseline','candidate']}
        assert all(len(v)==3 for v in rows.values())
        med={role:S.median(x['wallSeconds'] for x in xs) for role,xs in rows.items()}
        cpu={role:S.median(x['cpuSeconds'] for x in xs) for role,xs in rows.items()}
        hashes={role:sorted({x['stdout']['sha256'] for x in xs}) for role,xs in rows.items()}
        assert hashes['baseline']==hashes['candidate'] and len(hashes['baseline'])==1
        paired=[next(x['wallSeconds'] for x in rows['candidate'] if x['round']==i)/
                next(x['wallSeconds'] for x in rows['baseline'] if x['round']==i) for i in range(1,4)]
        cases.append(dict(name=name,medianSeconds=med,cpuMedianSeconds=cpu,
            candidateOverBaseline=med['candidate']/med['baseline'],pairedRatios=paired,
            rawSeconds={role:[x['wallSeconds'] for x in xs] for role,xs in rows.items()},exactQbeSha256=hashes['baseline'][0]))
    ratio=math.exp(S.mean(math.log(x['candidateOverBaseline']) for x in cases))
    summary=dict(complete=True,inputs=[pin(Path(__file__)),pin(report),r['manifest']],cases=cases,
        geometricCandidateOverBaseline=ratio,percentTimeReduction=100*(1-ratio),
        scope='Three-case compiler execution screen, exact complete QBE outputs, same final N2 source/runtime. '
              'Unqualified machine-code ceiling; no new upstream or generated-program-speed claim.')
    save(out/'report.json',summary)
    lines=['# Owning identity: native compiler ceiling','',
        '| Request | N2 seconds | Ceiling seconds | Ceiling/N2 |','|---|---:|---:|---:|']
    for c in cases:lines.append(f"|{c['name']}|{c['medianSeconds']['baseline']:.6f}|{c['medianSeconds']['candidate']:.6f}|{c['candidateOverBaseline']:.6f}|")
    lines += ['',f"Geometric ratio: {ratio:.6f}; time reduction: {100*(1-ratio):.2f}%.",'',summary['scope']]
    (out/'README.md').write_text('\n'.join(lines)+'\n')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--report',type=Path);a=p.parse_args();out=a.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131')
    # Do not create output before the pending candidate build can be read.
    if not a.report:
        assert (ROOT/'selfhost/build/phase111/p131-owning-identity-native01/report.json').exists()
    out.mkdir()
    if a.report:analyze(a.report,out)
    else:prepare(out)
    print(json.dumps(dict(complete=True,targetsRun=False,out=str(out))))

if __name__=='__main__':main()
