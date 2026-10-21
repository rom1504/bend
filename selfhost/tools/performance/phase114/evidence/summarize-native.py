#!/usr/bin/env python3
"""Summarize existing final02 receipts; execute no compiler or benchmark."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import math
from pathlib import Path
import statistics

ROOT = Path(__file__).resolve().parents[5]


def read(path): return json.loads(Path(path).read_text())


def pin(path):
    path = Path(path).resolve(); digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''): digest.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=digest.hexdigest())


def verify(row):
    if pin(row['file']) != row: raise ValueError('Changed evidence: '+row['file'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, default=ROOT/'implementation/phase114')
    args = parser.parse_args(); out = args.out.resolve()
    outputs = [out/name for name in ['native-results.json', 'native-results.md', 'selection.json']]
    if any(path.exists() for path in outputs): raise ValueError('Fresh result destinations required')
    build = ROOT/'selfhost/build'; phase = build/'phase114'
    paths = dict(
        plan=phase/'native-final02-plan.json', orchestration=phase/'native-final02-with-transport-plan.json',
        sourceManifest=phase/'final-source02/manifest.json', admission=phase/'final-admission02/manifest.json',
        guard=build/'phase113/p114-native-final02-qualification-guard/process.json',
        jobs=build/'phase113/p114-native-final02-qualification/report.json',
        comparison=build/'phase113/p114-native-final02-qbe-comparison/report.json',
        hosted=build/'phase111/p114-native-final02-full-emit/report.json',
        n1=build/'phase111/p114-native-final02-n1/report.json',
        selfRequest=build/'phase111/p114-native-final02-self/report.json',
        n2=build/'phase111/p114-native-final02-self/build/report.json',
        n1Focused=build/'phase111/p114-native-final02-n1-focused/report.json',
        n2Focused=build/'phase111/p114-native-final02-n2-focused/report.json',
        n2Full45=build/'phase111/p114-native-final02-n2-full45/report.json',
        transportAttempt=phase/'native-final02-transport-attempt/report.json',
        transportManifest=phase/'native-final02-transport-manifest.json',
        transport=build/'phase112/p114-native-final02-transport/report.json',
        historicalTransport=build/'phase112/transport04/report.json',
        runtimeResults=ROOT/'implementation/phase114/results.json',
        runtimeSourceManifest=phase/'final-source01/manifest.json',
        runtimeAdmission=phase/'final-admission01/manifest.json',
        namespaceWitness=ROOT/'implementation/phase114/namespace-products01.json',
        nativeSelection=ROOT/'selfhost/tools/native/selection.json')
    rows = {key: read(path) for key, path in paths.items()}
    receipts = {key: pin(path) for key, path in paths.items()}
    plan, compare, transport = [rows[key] for key in ['plan', 'comparison', 'transport']]
    for key in ['guard','jobs','comparison','hosted','n1','selfRequest','n2','n1Focused','n2Focused','n2Full45','transportAttempt','transport','historicalTransport','runtimeResults']:
        if rows[key].get('complete') is not True: raise ValueError('Incomplete evidence: '+key)
    if not compare['byteExact'] or receipts['plan'] not in compare['inputs']: raise ValueError('Exact original-plan QBE comparison required')
    # Authenticate actual source/API/runtime/QBE/images and their receipt bindings.
    for row in compare['inputs']: verify(row)
    for key in ['source','api','runtime']: verify(plan[key])
    if (not rows['admission']['admitted'] or rows['admission']['compiler'] != plan['source'] or
        rows['admission']['checkedApi'] != plan['api'] or rows['admission']['runtimeObject'] != plan['runtime']):
        raise ValueError('Exact final02 source/API/runtime admission required')
    if any(stage['status'] != 'complete' for stage in rows['hosted']['stages']): raise ValueError('Incomplete hosted stage')
    if not all(rows['hosted'].get(key) for key in ['sourceChecked','runtimeAdmitted','irVerified']): raise ValueError('Hosted gates missing')
    for key, positive, refusals in [('n1Focused',16,3),('n2Focused',16,3),('n2Full45',45,0)]:
        gate = rows[key]; count = gate['summary']
        if not gate['passed'] or count['semanticPasses'] != positive or count['expectedRefusals'] != refusals or count['pending']:
            raise ValueError('Semantic gate count mismatch: '+key)
    if not rows['transportAttempt']['measurementPassed'] or rows['transportAttempt']['measurementReport'] != receipts['transport']:
        raise ValueError('Passed optional transport receipt required')
    if not transport['passed'] or not transport['inputsUnchanged'] or transport['rounds'] != 3 or transport['modes'] != ['cache'] or len(transport['rows']) != 27:
        raise ValueError('Complete frozen 27-sample transport required')
    for sample in transport['rows']:
        if not all(sample[key] for key in ['passed','outputExact','stderrExact']): raise ValueError('Transport output mismatch')
    medians = []
    role_names = dict(phase111='n1', phase112='n2', upstream='upstream')
    metrics = ['requestSeconds','machineBuildSeconds','readyExecutableStageSumSeconds','readyExecutableHarnessSeconds']
    for case in transport['cases']:
        result = dict(name=case['name'], source=case['source'], expectedStdout=case['stdout'], roles={})
        for legacy, role in role_names.items():
            actual = [sample for sample in transport['rows'] if sample['name'] == case['name'] and sample['role'] == legacy]
            if len(actual) != 3: raise ValueError('Three samples per case/role required')
            result['roles'][role] = {}
            for metric in metrics:
                values = [sample[metric] for sample in actual]
                median = statistics.median(values)
                if median != transport['summary']['cache']['cases'][case['name']]['roles'][legacy][metric]['median']:
                    raise ValueError('Reported median mismatch')
                result['roles'][role][metric] = dict(median=median, samples=values)
        medians.append(result)
    geometric = {}
    for metric in ['requestSeconds','readyExecutableStageSumSeconds']:
        geometric[metric] = {}
        for a,b,legacy in [('n1','upstream','phase111/upstream'),('n2','upstream','phase112/upstream'),('n2','n1','phase112/phase111')]:
            value = math.exp(statistics.mean(math.log(row['roles'][a][metric]['median']/row['roles'][b][metric]['median']) for row in medians))
            if not math.isclose(value, transport['summary']['cache']['threeCaseGeometricRatios'][metric][legacy], rel_tol=1e-12): raise ValueError('Reported geomean mismatch')
            geometric[metric][a+'/'+b] = value
    guard = rows['guard']; history = rows['historicalTransport']['summary']['cache']['threeCaseGeometricRatios']
    limitations = [
        'Sequential CPU 3, one worker, GPU off, authenticated cache mode. No parallel/GPU qualification or live-mode timing in this chain.',
        'Exact reproduction compares raw hosted and N1-emitted QBE. N1/N2 ELF hashes differ; no ELF fixed point or N2-to-N3 self-emission is claimed.',
        'Focused suites each contain16 positive executions and3 expected refusals; expected refusal is not successful compilation. N2 full45 is one-shot conformance, not batch runtime timing.',
        'Three reused compiler-request cases and three rounds per role are a small screen, with no confidence interval or broad compiler-throughput claim.',
        'Native requests emit QBE using authenticated prepared Base; upstream emits C and loads/checks source Base. Native machine builds link a cached runtime; upstream Clang-O2 rebuilds runtime C. Request and ready-executable clocks are distinct.',
        'Phase112 transport04 is historical, from a separate campaign with different full compiler source/runtime. It is not a matched Phase112-versus-Phase114 experiment and does not isolate a performance regression.',
        'The broad generated-program runtime score remains bound to source01 hosted products. Source02 has the namespace traversal repair and separate native qualification; three exact ordinary QBE witnesses do not transfer the full45 runtime measurement.',
        'This is experimental evidence selection. Installed public/native selections are unchanged; auxiliary experiments are excluded.'
    ]
    result = dict(kind='phase114-native-qualification-and-transport-results', version=1, complete=True, targetsRunBySummary=False,
        method=pin(__file__), source=plan['source'], api=plan['api'], runtime=plan['runtime'],
        products={key:compare[key] for key in ['hostedQbe','nativeQbe','n1','n2']}, receipts=receipts,
        guard=dict(wallSeconds=guard['wallSeconds'], peakTreeRssBytes=guard['peakTreeRssBytes'], rssLimitBytes=guard['rssLimitBytes'],
            startedUtc=datetime.fromtimestamp(guard['started'],timezone.utc).isoformat(), finishedUtc=datetime.fromtimestamp(guard['finished'],timezone.utc).isoformat(),
            scope='One guard includes hosted acquisition, both builds, native self-request, both focused suites, exact comparison, optional transport and N2full45; nested clocks overlap.'),
        acquisition=dict(hostedTotalSeconds=rows['hosted']['totalSeconds'], nativeSelfRequestSeconds=rows['selfRequest']['nativeSeconds'],
            nativeSelfAndBuildTotalSeconds=rows['selfRequest']['totalSeconds'], hostedStages=rows['hosted']['stages'],
            machineBuildChildSumSeconds={key:sum(job['seconds'] for job in rows[key]['jobs']) for key in ['n1','n2']},
            qualificationJobs=[dict(name=job['name'],seconds=job['seconds'],exitCode=job['status']) for job in rows['jobs']['jobs']]),
        gates=dict(checkedSource=True,sourceRuntimeAdmission=True,finalIrVerified=True,byteExactQbe=True,
            n1Focused=rows['n1Focused']['summary'],n2Focused=rows['n2Focused']['summary'],n2Full45=rows['n2Full45']['summary'],
            transport=dict(passed=True,sourceCases=3,rounds=3,roles=3,completeOutputObservations=27),productionSelectionChanged=False),
        transport=dict(mode='cache',roleKeys=role_names,medianRows=medians,geomeanRatios=geometric,ratioDirection='numerator seconds / denominator seconds; below 1 is faster',
            clocks=transport['clocks'],buildPolicy=transport['buildPolicy'],modeNotes=transport['modeNotes'],
            wallSeconds=transport['finished']-transport['started']),
        historicalContext=dict(receipt=receipts['historicalTransport'],n2RequestOverUpstream=history['requestSeconds']['phase112/upstream'],
            n2ReadyExecutableOverUpstream=history['readyExecutableStageSumSeconds']['phase112/upstream'],matchedWithCurrent=False,isolatedRegressionClaim=False),
        separateRuntimeEvidence=dict(source=rows['runtimeSourceManifest']['source'],summary=receipts['runtimeResults'],
            timingPoints=rows['runtimeResults']['timingPoints'],outputObservations=rows['runtimeResults']['outputObservations'],
            broad=rows['runtimeResults']['broad'],namespaceWitness=receipts['namespaceWitness'],scoreTransferredToSource02=False),limitations=limitations)
    out.mkdir(parents=True,exist_ok=True); outputs[0].write_text(json.dumps(result,indent=2)+'\n')
    selection = dict(kind='phase114-experimental-evidence-selection',productionSelectionChanged=False,authority='Reporting only; no installed selection pointer is changed.',
        runtimeMeasured=dict(source=rows['runtimeSourceManifest']['source'],sourceManifest=receipts['runtimeSourceManifest'],admission=receipts['runtimeAdmission'],results=receipts['runtimeResults']),
        nativeQualified=dict(source=plan['source'],sourceManifest=receipts['sourceManifest'],recipe=rows['sourceManifest']['recipe'],api=plan['api'],runtime=plan['runtime'],
            admission=receipts['admission'],n1=compare['n1'],n2=compare['n2'],results=pin(outputs[0]),qualification=receipts['comparison']),
        sourceRelationship='source02 adds namespace list-walker loops to source01; independent three-request exact-QBE witnesses are scoped, not full45 native runtime reproduction.',
        existingNativeSelection=receipts['nativeSelection'],excluded='Auxiliary experiments and installed promotion.')
    outputs[2].write_text(json.dumps(selection,indent=2)+'\n')
    table=[]
    for row in medians:
        values=[row['roles'][role][metric]['median'] for metric in ['requestSeconds','readyExecutableStageSumSeconds'] for role in ['n1','n2','upstream']]
        table.append('| '+row['name']+' | '+' | '.join(f'{value:.3f}' for value in values)+' |')
    text=f'''# Phase114 native qualification and compiler requests

Source02 completes hosted→N1→native self-emission→N2 through the unchanged
qualification gates. The raw QBE files are byte-identical: **74,220,801 bytes**,
SHA256 `{compare['hostedQbe']['sha256']}`. N1 and N2 each pass 16 positive focused
programs plus 3 expected refusals (2 source, 1 backend); N2 also passes all 45 original
one-shot conformance programs. Refusals are not counted as compiled programs.
The installed selection is unchanged.

The full guard takes **{guard['wallSeconds']:.3f} s** ({guard['wallSeconds']/60:.2f} min),
with peak process-tree RSS **{guard['peakTreeRssBytes']:,} bytes**
({guard['peakTreeRssBytes']/2**30:.3f} GiB) under its 4 GiB guard limit. Hosted acquisition takes
{rows['hosted']['totalSeconds']:.3f} s; the actual N1 self-request takes
{rows['selfRequest']['nativeSeconds']:.3f} s. These nested clocks must not be added
to the guard wall. The guard includes semantic suites and the timing screen.

[Exact pins, gates and clocks](native-results.json) · [Separate evidence selections](selection.json) ·
[Raw comparison](../../selfhost/build/phase113/p114-native-final02-qbe-comparison/report.json) ·
[Guard receipt](../../selfhost/build/phase113/p114-native-final02-qualification-guard/process.json).

## Three-source request screen

All 27 observations pass complete outputs: three unchanged sources × three roles
× three rotated rounds, cache mode, CPU 3, one worker, GPU off. Values are medians
in seconds. Ready time is each sample's request plus machine-build child times;
it excludes harness bookkeeping and the correctness execution.

| Source | N1 request | N2 request | Upstream request | N1 ready | N2 ready | Upstream ready |
|---|---:|---:|---:|---:|---:|---:|
{chr(10).join(table)}

The geometric mean request ratios are **{geometric['requestSeconds']['n1/upstream']:.5f}×**
for N1/upstream and **{geometric['requestSeconds']['n2/upstream']:.5f}×** for N2/upstream.
Ready-executable ratios are **{geometric['readyExecutableStageSumSeconds']['n1/upstream']:.5f}×**
and **{geometric['readyExecutableStageSumSeconds']['n2/upstream']:.5f}×**, respectively.
Ratios below 1 are faster. N2/N1 ratios are
{geometric['requestSeconds']['n2/n1']:.5f} for requests and
{geometric['readyExecutableStageSumSeconds']['n2/n1']:.5f} for ready time.
[Raw measurements](../../selfhost/build/phase112/p114-native-final02-transport/report.json)
retain every sample; the JSON summary independently recomputes their medians
and geometric means.

Native requests emit QBE with authenticated prepared Base. Upstream requests
emit C and load/check source Base. Native builds use QBE/as/link with the cached
runtime; upstream uses Clang-O2 and recompiles runtime C. These are practical
request/build comparisons with disclosed format and preparation differences,
not same-format throughput or generated-program runtime measurements.

Phase112's separate [transport04 campaign](../../selfhost/build/phase112/transport04/report.json)
reported N2 requests at {history['requestSeconds']['phase112/upstream']:.3f}× upstream
and ready time at {history['readyExecutableStageSumSeconds']['phase112/upstream']:.3f}×.
It used a different full compiler source/runtime and was not rerun as a role in
this campaign. The historical/current difference does not isolate a regression
or identify which transformation caused it. Three repeated sources and three
rounds do not establish broad compiler throughput or confidence intervals.

## Source and qualification scope

Qualified native source02: `{plan['source']['sha256']}`.
The earlier broad runtime result remains bound to hosted source01:
`{rows['runtimeSourceManifest']['source']['sha256']}`. Its 44 timed points,
one zero-work control and 405 output/count observations remain the source01
[runtime result](results.json); the score is not relabeled as a source02 native
measurement. Source02 repairs namespace traversal; three ordinary requests have
[exact old/new QBE witnesses](namespace-products01.json), a deliberately limited
bridge between the sources.

Exact reproduction concerns raw QBE. The N1 and N2 executable hashes differ;
there is no ELF fixed-point or N2-to-N3 self-emission claim. Full45 here is
one-shot correctness, not native-produced batch45 timing. Parallel execution,
GPU, live-mode timing, installed promotion and auxiliary experiments are outside
this result. The report pins the original gates, source/API/runtime, images and
receipts without changing production pointers.
'''
    outputs[1].write_text(text)
    print(json.dumps(dict(complete=True,targetsRun=False,outputs=[pin(path) for path in outputs])))


if __name__ == '__main__': main()
