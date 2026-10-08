#!/usr/bin/env python3
"""Join closed full frontend/primary-JS observations; never hide unsuccessful oracles."""
import argparse
import collections
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase66'
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item['file'] if item else value).resolve(strict=True)
    data = file.read_bytes()
    result = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if item:
        assert result['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert result['bytes'] == item['bytes'], file
        if 'canonicalPath' in item:
            assert result['file'] == item['canonicalPath'], file
    assert result['file'] not in inputs or inputs[result['file']] == result
    inputs[result['file']] = result
    return result


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def audit_report(report):
    assert report['finished'] and not report['changedInputs']
    assert not report['identity']['adapterChangedDuringRun'] and not report['identity']['changedArtifacts']
    assert report['inputHashes'].keys() == report['inputPaths'].keys()
    for logical, sha in report['inputHashes'].items():
        assert str(Path(logical).resolve(strict=True)) == report['inputPaths'][logical]
        pin(dict(file=logical, sha256=sha))
    for item in report['identity']['artifacts'].values():
        pin(item)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--comparison', type=Path, required=True)
    p.add_argument('--closure', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    pin(__file__)
    frontend = read(RAW / 'conformance-final04-frontend-reuse.json')
    assert frontend['kind'] == 'phase66-frontend-exact-reuse'
    assert frontend['complete'] and frontend['passed'] and frontend['exactObservations'] == 3174
    closure = read(args.closure)
    assert closure['kind'] == 'phase66-exact-javascript-closure-reuse-eligibility'
    assert closure['complete'] and closure['eligibleForExactJavaScriptReuse']
    assert closure['nativeQualificationTransferred'] is False
    assert pin(closure['baseline']) == pin(frontend['newAttempt'])
    for receipt in [frontend, closure]:
        for item in receipt['inputs']:
            pin(item)
    audit_report(read(frontend['originalFrontendReport']))
    comparison = read(args.comparison)
    assert comparison['kind'] == 'phase66-conformance-comparison' and comparison['observationsClosed']
    for item in comparison['inputs']:
        pin(item)
    names = {'typescript-new-js', 'bend-candidate-new-base-js'}
    reports = {}
    for name in names:
        runs = [r for r in comparison['runs'] if r['name'] == name]
        assert len(runs) == 1 and runs[0]['rows'] == 1170 and runs[0]['observationsClosed']
        report = read(runs[0]['report'])
        audit_report(report)
        assert all(not worker['errors'] for worker in report.get('workers') or [])
        rows = {row['id']: row for row in report['results']}
        assert len(rows) == len(report['results']) == 1170
        assert {row['lane'] for row in rows.values()} == {'js'}
        assert {(r['id'], r['lane']) for r in report['selection']['requested']} == {(k, 'js') for k in rows}
        reports[name] = dict(receipt=runs[0]['report'], report=report, rows=rows)
    reference = reports['typescript-new-js']['rows']
    candidate = reports['bend-candidate-new-base-js']['rows']
    assert candidate.keys() == reference.keys()
    subset = read(RAW / 'direct-census-subset-plan.json')
    assert subset['coverage'] == dict(historical=26, currentIncluded=25, deleted=1)
    assert pin(subset['attempt']) == pin(closure['baseline'])
    recipe = read(subset['recipe'])
    assert recipe['scope'] == 'full-js' and recipe['jsBackend'] == 'direct'
    assert len(recipe['images']) == len(recipe['commands']) == 1
    assert pin(recipe['images'][0]['attempt']) == pin(closure['baseline'])
    assert pin(recipe['commands'][0]['report']) == pin(reports['bend-candidate-new-base-js']['receipt'])
    assert recipe['images'][0]['compilerImage']['sha256'] == closure['api']['sha256']
    assert pin(subset['api'])['sha256'] == closure['api']['sha256']
    for key in ['parentSelection', 'selection', 'base', 'driver', 'adapter', 'judge', 'inventory']:
        pin(subset[key])
    retained = []
    for row in subset['included']:
        pin(row['source'])
        assert row['id'] in candidate
        retained.append(dict(id=row['id'], source=row['source'], candidateStatus=candidate[row['id']]['status'],
            referenceStatus=reference[row['id']]['status']))
    assert len(retained) == len({row['id'] for row in retained}) == 25

    def brief(row):
        result = row.get('result') or {}
        return dict(id=row['id'], status=row['status'], reason=row.get('reason'), phase=result.get('phase'),
            typeAccepted=result.get('typeAccepted'), proofTrust=result.get('proofTrust'),
            exitCode=result.get('exitCode'), diagnostic=result.get('diagnostic'),
            output=result.get('output', result.get('stdout')))

    summaries = {}
    for name, data in reports.items():
        rows = data['rows'].values()
        summaries[name] = dict(report=pin(data['receipt']), observations=1170,
            statuses=dict(collections.Counter(row['status'] for row in rows)),
            phases=dict(collections.Counter((row.get('result') or {}).get('phase', 'none') for row in rows)),
            allFixtureOraclesPass=all(row['status'] == 'pass' for row in rows),
            unsuccessful=[brief(row) for row in rows if row['status'] != 'pass'])
    pairs = [row for row in comparison['comparisons'] if row['reference'] == 'typescript-new-js' and row['candidate'] == 'bend-candidate-new-base-js']
    assert len(pairs) == 1 and pairs[0]['commonObservations'] == 1170
    later = ['io/cid_unknown.bend', 'io/effect_ctr_name.bend', 'io/main_foreign.bend', 'reg/array_open_element.bend']
    result = dict(kind='phase66-closed-conformance-lanes', complete=True, dataOnly=True,
        targetExecuted=False, producer=pin(__file__), frontend=pin(RAW/'conformance-final04-frontend-reuse.json'),
        exactFrontendObservations=3174, closure=pin(args.closure), observedAttempt=closure['baseline'],
        finalAttempt=closure['candidate'], primaryJavaScript=summaries,
        comparison=pin(args.comparison), exactObservationAgreements=pairs[0]['exactObservationAgreements'],
        statusDifferences=pairs[0]['statusDifferences'],
        referencePassingCandidateFailures=[dict(reference=brief(reference[k]), candidate=brief(candidate[k]))
            for k in sorted(candidate) if reference[k]['status'] == 'pass' and candidate[k]['status'] != 'pass'],
        candidatePassingReferenceFailures=[dict(reference=brief(reference[k]), candidate=brief(candidate[k]))
            for k in sorted(candidate) if candidate[k]['status'] == 'pass' and reference[k]['status'] != 'pass'],
        retainedDirectSubset=dict(plan=pin(RAW/'direct-census-subset-plan.json'), observations=retained,
            deleted=subset['deleted'], allCurrentOraclesPass=all(row['candidateStatus']=='pass' for row in retained)),
        fourLaterStageFixtures=[dict(id=k, candidate=brief(candidate[k]), reference=brief(reference[k])) for k in later],
        scope='Complete observations are not automatically successful conformance. Every non-pass stays explicit, including unsupported, crashes, timeouts, and shared reference failures. No failure is reclassified here. Primary direct JavaScript is separate from native, legacy JavaScript, Lean, GPU, mathematical proof and universal language conformance. Final05 inherits only the exact unchanged JavaScript closure of tested04; native qualification is separate.',
        inputs=list(inputs.values()))
    for item in list(inputs.values()):
        pin(item)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open('x') as stream:
        stream.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=pin(out), statuses={k:v['statuses'] for k,v in summaries.items()},
        referencePassingCandidateFailures=len(result['referencePassingCandidateFailures']))))


if __name__ == '__main__':
    main()
