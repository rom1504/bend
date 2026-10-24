#!/usr/bin/env python3
"""Offline provisional native report, keeping final and FAST measurement blocks separate."""
import argparse
import importlib.util
import json
import math
from pathlib import Path
import statistics as S
import sys

ROOT = Path(__file__).resolve().parents[5]
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location('p131_source_inventory', Path(__file__).with_name('source-audit.py'))
A = importlib.util.module_from_spec(spec); spec.loader.exec_module(A)


def read(path): return json.loads(Path(path).read_text())
def geo(values): return math.exp(S.mean(math.log(v) for v in values))
def stats(values): return dict(median=S.median(values), minimum=min(values), maximum=max(values), samples=values)


def block(raw_path, analysis_path, label):
    raw, analysis = read(raw_path), read(analysis_path)
    assert raw['complete'] and raw['passed'] and raw['inputsUnchanged'] and len(raw['rows']) == 27
    assert A.pin(raw_path) in analysis['inputs'] and analysis['complete']
    assert analysis['exactNativeQbeAllCases']
    cases = []
    for case in analysis['cases']:
        roles = {}
        for role in ['phase111', 'phase112', 'upstream']:
            rows = [r for r in raw['rows'] if r['name'] == case['name'] and r['role'] == role]
            assert len(rows) == 3 and all(r['passed'] and r['outputExact'] and r['stderrExact'] for r in rows)
            roles[role] = {key: stats([r[key] for r in rows]) for key in
                ['requestSeconds', 'machineBuildSeconds', 'readyExecutableStageSumSeconds', 'readyExecutableHarnessSeconds']}
            roles[role]['requestCpuSeconds'] = stats([r['jobs'][0]['userSeconds'] + r['jobs'][0]['systemSeconds'] for r in rows])
        cases.append(dict(name=case['name'], roles=roles, requestRatios={k:case[k] for k in
            ['candidateOverParent', 'candidateOverUpstream', 'parentOverUpstream']},
            candidatePercentChange=case['requestPercentChange'], observedRangeHint=case['observedRangeHint'],
            pairedRoundRatios=case['pairedRoundRatios'], nativeQbeExact=case['nativeQbeExact']))
    ratios = {}
    for clock in ['requestSeconds', 'machineBuildSeconds', 'readyExecutableStageSumSeconds', 'readyExecutableHarnessSeconds']:
        ratios[clock] = {key:geo(c['roles'][numerator][clock]['median']/c['roles'][denominator][clock]['median'] for c in cases)
            for key,numerator,denominator in [('candidateOverParent','phase112','phase111'),
                ('candidateOverUpstream','phase112','upstream'),('parentOverUpstream','phase111','upstream')]}
    assert math.isclose(ratios['requestSeconds']['candidateOverParent'], analysis['geometricRequestRatios']['candidateOverParent'], rel_tol=1e-12)
    return dict(label=label, raw=A.pin(raw_path), analysis=A.pin(analysis_path), manifest=raw['manifest'],
        roles=raw['roles'], cases=cases, geometricRatios=ratios, observedRows=27, allOutputsCorrect=True,
        exactQbeBetweenNativeRoles=True, cpuAffinity=raw['cpuAffinity'], sampleWindowSeconds=analysis['sampleWindowSeconds'],
        sameRequestedSources=True, sameCompilerSource=False, clocks=raw['clocks'], buildPolicy=raw['buildPolicy'],
        qualificationAtTiming=raw['lineage']['qualificationScope'])


def source_count(source):
    text = source.read_text(); bodies,kinds=A.inventory(text)
    return dict(source=A.pin(source), physicalLines=len(text.splitlines()), codeLines=A.code_lines(text),
        uniqueDeclarationNames=len(bodies), declarationHeads=kinds), bodies


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();assert not out.exists() and not out.with_suffix('.md').exists()
    final=block(ROOT/'selfhost/build/phase112/p131-final-parent-timing01/report.json',
        ROOT/'selfhost/build/phase131/final-native-timing-analysis01/report.json','Phase130 N1 versus final Phase131 N2')
    fast=block(ROOT/'selfhost/build/phase112/p131-fast-parent-timing01/report.json',
        ROOT/'selfhost/build/phase131/native-timing-analysis01/report.json','Phase130 N1 versus FAST Phase131 N1; earlier separate block')
    ad_path=ROOT/'selfhost/build/phase131/combined-literals-admission01.json';ad=read(ad_path)
    before,old=source_count(Path(final['roles']['phase111']['source']['file']))
    after,new=source_count(Path(ad['source']['file']))
    assert after['source']==ad['source']==final['roles']['phase112']['source']
    complexity=dict(parent=before,final=after,physicalLineDelta=after['physicalLines']-before['physicalLines'],
        codeLineDelta=after['codeLines']-before['codeLines'],byteDelta=after['source']['bytes']-before['source']['bytes'],
        addedDeclarationNames=len(set(new)-set(old)),changedExistingDeclarations=sum(A.norm(old[n])!=A.norm(new[n]) for n in old),
        scope='Actual selected compiler.bend only; external laws/harness/research files excluded. Selected control/reference helpers remain included. Code lines exclude blank/full-line comments. Declaration counts are syntactic, not concepts/proved laws.')
    emissions=[]
    for name,stage in [('p131-final-acquire01','Qualified Phase130 N1 emits final source to Q1'),('p131-final-self01','Final Phase131 N1 emits same final source to Q2')]:
        path=ROOT/'selfhost/build/phase130'/name/'report.json';r=read(path)
        assert r['complete'] and r['exitCode']==0 and not r['changedInputs'] and r['source']==ad['source']
        emissions.append(dict(stage=stage,receipt=A.pin(path),image=r['image'],source=r['source'],product=r['product'],
            requestWallSeconds=r['nativeSeconds'],requestCpuSeconds=r['cpuSeconds'],harnessTotalSeconds=r['totalSeconds'],
            peakRssKiB=r['peakRssKiB']))
    full=dict(observations=emissions,requestWallRatio=emissions[1]['requestWallSeconds']/emissions[0]['requestWallSeconds'],
        requestCpuRatio=emissions[1]['requestCpuSeconds']/emissions[0]['requestCpuSeconds'],sameCompilerSource=True,
        generatedQbeEqual=False,scope='One observation per producer; not randomized, not confidence-qualified. Acquisition overlapped separate CPU6 work; self-emission did not share that condition. Both include full cold native source-to-QBE requests; machine builds excluded. N2/N3 fixed-point request was still pending at this report cutoff.')
    builds=[]
    for stage in ['n1','n2']:
        path=ROOT/f'selfhost/build/phase111/p131-final-native01-{stage}/report.json';r=read(path);assert r['complete']
        builds.append(dict(stage=stage,receipt=A.pin(path),binary=r['binary'],object=r['object']))
    result=dict(kind='phase131-provisional-native-results',complete=True,targetsRun=False,nativeQualification='Pending independent N3 binder at report cutoff; timing manifests intentionally remain experimental.',
        selected=False,installed=False,finalBlock=final,fastBlock=fast,samplesPooledAcrossBlocks=False,
        finalCompilerComplexity=complexity,fullSourceRequestObservations=full,nativeProducts=builds,
        inputs=[A.pin(__file__),A.pin(A.__file__),A.pin(ad_path),final['raw'],final['analysis'],fast['raw'],fast['analysis']],
        limitations=['Three sources and three repetitions screen compilation latency, not a broad compiler-throughput benchmark.',
            'Native request output is QBE; upstream request output is C. Both native roles use identical compact Base; upstream reads/checks source Base.',
            'Native cached-runtime QBE/as/link and upstream full C/Clang runtime construction are different documented workflows.',
            'No generated-program runtime speed or recursive research acceleration is established.',
            'FAST and final are different compiler sources and generations observed in separate timing blocks; do not pool or claim a direct controlled final/FAST ratio.',
            'Per-case min/max are observed ranges from three samples, not confidence intervals.'])
    out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result,indent=2)+'\n')
    f=final['geometricRatios'];fa=fast['geometricRatios'];lines=[
        '# Phase131 native results — provisional', '',
        f"Final N2 reduces native request time by **{100*(1-f['requestSeconds']['candidateOverParent']):.2f}%** geometrically versus qualified Phase130 N1 across three frozen requests. Its request ratio is **{f['requestSeconds']['candidateOverUpstream']:.3f}× upstream**, down from the same-block parent's {f['requestSeconds']['parentOverUpstream']:.3f}×. All 27 output observations pass; all 18 native outputs match exactly between the two native roles.", '',
        'This measures native compilation requests, not generated-program execution. Final source is `1bc5930…728f9`; measured final **N2** ELF is `2fae360…fd5dc`. Parent is Phase130 **N1**, source `995d6b4…6bdd`, ELF `a25e4c7…15c2c5`. Full SHA256 identities are in the JSON. Final N3 qualification was pending at this report cutoff; installed selection is unchanged.', '',
        '| Request | Parent seconds [range] | Final N2 seconds [range] | Upstream seconds [range] | Final/parent | Final/upstream |',
        '|---|---:|---:|---:|---:|---:|']
    for c in final['cases']:
        cells=[]
        for role in ['phase111','phase112','upstream']:
            s=c['roles'][role]['requestSeconds'];cells.append(f"{s['median']:.4f} [{s['minimum']:.4f}, {s['maximum']:.4f}]")
        lines.append('| '+c['name']+' | '+' | '.join(cells)+f" | {c['requestRatios']['candidateOverParent']:.4f} | {c['requestRatios']['candidateOverUpstream']:.4f} |")
    lines += ['', 'All three final ranges are below their corresponding parent ranges. These are three-sample descriptive ranges, not confidence intervals.', '',
        '| Clock, geometric ratio | Final/parent | Final/upstream |', '|---|---:|---:|']
    for clock,label in [('requestSeconds','Compiler child request'),('machineBuildSeconds','Machine-build child sum'),('readyExecutableStageSumSeconds','Request + machine children'),('readyExecutableHarnessSeconds','Ready executable with between-stage harness')]:
        lines.append(f"| {label} | {f[clock]['candidateOverParent']:.4f} | {f[clock]['candidateOverUpstream']:.4f} |")
    lines += ['', 'The request clock includes startup, source/input reads, Base preparation, output and exit; authentication/reporting are outside it. Ready-child sums exclude Python bookkeeping and output execution. Ready-harness time starts after preflight and includes between-stage bookkeeping. Native emits QBE using prepared compact Base/cached runtime; upstream Bun emits C using source Base and rebuilds its runtime with Clang. The ready-workflow advantage is not same-format request parity.', '',
        f"Earlier FAST block, kept separate: qualified FAST **N1** (`7f79529…d22fd` source) used {fa['requestSeconds']['candidateOverParent']:.4f}× parent request time (6.11% lower), {fa['requestSeconds']['candidateOverUpstream']:.4f}× upstream request time and {fa['readyExecutableStageSumSeconds']['candidateOverUpstream']:.4f}× upstream ready-child time. That block's parent/upstream was {fa['requestSeconds']['parentOverUpstream']:.4f}×. Different compiler sources, generations and observation times prevent treating this as an interleaved final-versus-FAST comparison.", '',
        f"Full final-source requests, one observation each: Phase130 N1 acquired Q1 in {emissions[0]['requestWallSeconds']:.3f}s native child time; final N1 emitted Q2 in {emissions[1]['requestWallSeconds']:.3f}s ({full['requestWallRatio']:.4f}×; {100*(1-full['requestWallRatio']):.2f}% lower). CPU times were {emissions[0]['requestCpuSeconds']:.3f}s and {emissions[1]['requestCpuSeconds']:.3f}s. Q1 and Q2 differ as expected for new codegen policies. Acquisition overlapped CPU6 work, so this single pair is supporting evidence, not a controlled gain estimate. Q2=Q3 must still be established independently.", '',
        f"Selected final compiler: **{after['physicalLines']:,} physical lines / {after['codeLines']:,} code lines**, {after['uniqueDeclarationNames']:,} unique declaration names; {after['source']['bytes']:,} bytes. Versus Phase130 this is +{complexity['physicalLineDelta']:,} physical / +{complexity['codeLineDelta']:,} code lines / +{complexity['byteDelta']:,} bytes, with {complexity['addedDeclarationNames']} added names. Literal exposure also rewrites existing declarations: {complexity['changedExistingDeclarations']} normalized bodies differ. These are selected compiler-source counts; external laws and harnesses are excluded, selected control/reference helpers included. Declaration counts are not counts of concepts or proven laws.", '',
        'Evidence: [final timing analysis](../../selfhost/build/phase131/final-native-timing-analysis01/report.json), [raw final observations](../../selfhost/build/phase112/p131-final-parent-timing01/report.json), [separate FAST analysis](../../selfhost/build/phase131/native-timing-analysis01/report.json), and [exact identities / all clocks](native-results.json).']
    out.with_suffix('.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps(dict(complete=True,result=A.pin(out),requestRatios=f['requestSeconds'],complexity={k:complexity[k] for k in ['physicalLineDelta','codeLineDelta','addedDeclarationNames']})))


if __name__=='__main__': main()
