#!/usr/bin/env python3
"""Join selected07 frontend, fresh JS census and exactly reusable Bun observations."""
import argparse
import collections
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('phase66_lanes_parent', HERE/'join-conformance-lanes.py')
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)
RAW, pin, read = P.RAW, P.pin, P.read


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for key in ['comparison', 'bun-reuse', 'out']:
        ap.add_argument('--'+key, type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    pin(__file__)
    pin(HERE/'join-conformance-lanes.py')
    frontend = read(RAW/'conformance-final07-frontend-reuse.json')
    assert frontend['kind'] == 'phase66-final07-frontend-closure-reuse'
    assert frontend['complete'] and frontend['passed'] and frontend['exactObservations'] == 3174
    for item in frontend['inputs']:
        pin(item)
    selected_pin = pin(frontend['selectedAttempt'])
    selected = read(selected_pin)
    assert selected['checked'] and selected['config']['strictExact']
    assert pin(selected['api']) == pin(frontend['compilerImages']['selected'])
    P.audit_report(read(frontend['originalFrontendReport']))
    comparison = read(args.comparison)
    assert comparison['kind'] == 'phase66-conformance-comparison' and comparison['observationsClosed']
    for item in comparison['inputs']:
        pin(item)
    reports = {}
    for name in ['typescript-new-js', 'bend-candidate-new-base-js']:
        runs = [r for r in comparison['runs'] if r['name'] == name]
        assert len(runs) == 1 and runs[0]['rows'] == 1170 and runs[0]['observationsClosed']
        report = read(runs[0]['report'])
        P.audit_report(report)
        assert all(not w['errors'] for w in report.get('workers') or [])
        rows = {r['id']: r for r in report['results']}
        assert len(rows) == len(report['results']) == 1170
        assert {r['lane'] for r in rows.values()} == {'js'}
        assert {(r['id'], r['lane']) for r in report['selection']['requested']} == {(k, 'js') for k in rows}
        reports[name] = dict(receipt=runs[0]['report'], report=report, rows=rows)
    candidate = reports['bend-candidate-new-base-js']['rows']
    reference = reports['typescript-new-js']['rows']
    assert candidate.keys() == reference.keys()
    recipe_pin = pin(RAW/'conformance-final07-direct-js01/recipe.json')
    recipe = read(recipe_pin)
    assert recipe['scope'] == 'full-js' and recipe['jsBackend'] == 'direct'
    assert len(recipe['images']) == len(recipe['commands']) == 1
    image, command = recipe['images'][0], recipe['commands'][0]
    assert pin(image['attempt']) == selected_pin
    assert pin(image['compilerImage'])['sha256'] == selected['api']['sha256']
    assert pin(command['report']) == pin(reports['bend-candidate-new-base-js']['receipt'])
    # The full comparator independently rehashed every final07 staged tool,
    # helper/runtime/API/Base, including intentional direct-adapter derivation.
    assert any(pin(x) == recipe_pin for x in comparison['inputs'])
    subset_pin = pin(RAW/'direct-census-subset-plan.json')
    subset = read(subset_pin)
    assert subset['coverage'] == dict(historical=26, currentIncluded=25, deleted=1)
    pin(subset['parentSelection'])
    retained = []
    for row in subset['included']:
        source = pin(row['source'])
        assert row['id'] in candidate
        fixture = next(t for t in reports['bend-candidate-new-base-js']['report']['inventory']['tests'] if t['id'] == row['id'])
        assert fixture['sha256'] == source['sha256']
        retained.append(dict(id=row['id'], source=source, candidateStatus=candidate[row['id']]['status'],
            referenceStatus=reference[row['id']]['status']))
    assert len(retained) == len({r['id'] for r in retained}) == 25
    bun = read(args.bun_reuse)
    assert bun['kind'] == 'phase66-final07-bun-byte-reuse-audit' and bun['complete']
    assert bun['inputsUnchanged'] and bun['allPriorExecutedPairsReusable'] and not bun['focusedReplayRequests']
    assert pin(bun['attempt']) == selected_pin
    assert pin(bun['compiler']) == pin(selected['api'])
    assert pin(bun['candidateNodeReport']) == pin(reports['bend-candidate-new-base-js']['receipt'])
    assert pin(bun['typescriptNodeReport']) == pin(reports['typescript-new-js']['receipt'])
    assert not bun['runtimeClosure']['changed']
    for item in bun['inputs']:
        pin(item)
    assert len(bun['cases']) == len({r['id'] for r in bun['cases']}) == 56
    assert bun['summary'] == dict(**{'pass': 54, 'fail': 1, 'deferred-environment': 1})
    for row in bun['cases']:
        if row['status'] != 'deferred-environment':
            assert row['reused'] and not row['reasons']
            assert all(r['equalPriorEmittedClosure'] and r['checkedRuntime'] for r in row['roles'].values())
    assert [r['id'] for r in bun['cases'] if r['status'] == 'fail'] == ['io/process_run.bend']
    assert [r['id'] for r in bun['cases'] if r['status'] == 'deferred-environment'] == ['gfx/app_linear.bend']
    gaps = sorted(k for k in candidate if reference[k]['status'] == 'pass' and candidate[k]['status'] != 'pass')
    assert not gaps, 'Unresolved reference-passing candidate gaps: '+repr(gaps)
    assert all(r['status'] not in ['crash', 'timeout'] for r in candidate.values())

    def brief(row):
        value = row.get('result') or {}
        return dict(id=row['id'], status=row['status'], reason=row.get('reason'), phase=value.get('phase'),
            typeAccepted=value.get('typeAccepted'), proofTrust=value.get('proofTrust'), exitCode=value.get('exitCode'),
            diagnostic=value.get('diagnostic'), output=value.get('output', value.get('stdout')))

    summaries = {}
    for name, data in reports.items():
        rows = data['rows'].values()
        summaries[name] = dict(report=pin(data['receipt']), observations=1170,
            statuses=dict(collections.Counter(r['status'] for r in rows)),
            allFixtureOraclesPass=all(r['status'] == 'pass' for r in rows),
            unsuccessful=[brief(r) for r in rows if r['status'] != 'pass'])
    pairs = [r for r in comparison['comparisons'] if r['reference'] == 'typescript-new-js' and r['candidate'] == 'bend-candidate-new-base-js']
    assert len(pairs) == 1 and pairs[0]['commonObservations'] == 1170
    bun_passed = {r['id'] for r in bun['cases'] if r['status'] == 'pass'}
    union = {name: sorted({r['id'] for r in data['rows'].values() if r['status'] == 'pass'} | bun_passed) for name, data in reports.items()}
    receipt = dict(kind='phase66-selected07-conformance-lanes', complete=True, dataOnly=True, targetExecuted=False,
        producer=pin(__file__), selectedAttempt=selected_pin, selectedApi=pin(selected['api']),
        frontendReuse=pin(RAW/'conformance-final07-frontend-reuse.json'), exactFrontendObservations=3174,
        primaryJavaScript=summaries, comparison=pin(args.comparison), recipe=recipe_pin,
        exactObservationAgreements=pairs[0]['exactObservationAgreements'], statusDifferences=pairs[0]['statusDifferences'],
        referencePassingCandidateFailures=gaps, noUnexplainedCandidateOnlyGaps=True,
        candidatePassingReferenceFailures=[dict(reference=brief(reference[k]), candidate=brief(candidate[k]))
            for k in sorted(candidate) if candidate[k]['status'] == 'pass' and reference[k]['status'] != 'pass'],
        retainedDirectSubset=dict(historicalPlan=subset_pin, selectedRecipe=recipe_pin, observations=retained,
            deleted=subset['deleted'], statusCounts=dict(collections.Counter(r['candidateStatus'] for r in retained))),
        supplementalBun=dict(reuse=pin(args.bun_reuse), summary=bun['summary'], priorRuntime=bun['runtime'],
            unchangedEmittedModules=True, programsRerun=False),
        mixedRuntimeCoverage=dict(passingIds=union, counts={k:len(v) for k,v in union.items()},
            scope='Union of unchanged Node fixture passes and separately admitted exact-module Bun passes. Does not rewrite Node statuses or count graphics deferral/shared failure/unprintable exemptions as executable passes.'),
        priorGapsPreserved=pin(RAW/'conformance-lanes05.json'),
        scope='Finite selected07 evidence: full3174 frontend observations, fresh1170 Node JS probes, and exact-byte transfer of54paired Bun passes/one shared failure/one graphics deferral. No reference-passing candidate-only gap remains. This is not an all1170-pass claim, mathematical proof, universal language conformance or native/legacy/GPU qualification.',
        inputs=list(P.inputs.values()))
    for item in receipt['inputs']:
        pin(item)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        stream.write(json.dumps(receipt, indent=2)+'\n')
    print(json.dumps(dict(output=pin(out), gaps=gaps, mixedRuntimeCounts=receipt['mixedRuntimeCoverage']['counts'])))


if __name__ == '__main__':
    main()
