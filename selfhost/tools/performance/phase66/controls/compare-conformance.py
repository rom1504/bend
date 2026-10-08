#!/usr/bin/env python3
"""Summarize closed conformance observations without converting mismatches to passes."""
import argparse
import collections
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]


def pin(file):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    return dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--recipe', type=Path, action='append', required=True)
    ap.add_argument('--out', type=Path, required=True)
    a = ap.parse_args()
    assert not a.out.exists()
    assert a.out.resolve().is_relative_to(ROOT/'selfhost/build/phase66') or a.out.resolve().is_relative_to(ROOT/'implementation/phase66')
    delta_file = Path(__file__).with_name('inventory01')/'delta.json'
    delta = json.loads(delta_file.read_text())
    changed = {r['id']: r['change'] for r in delta['delta']}
    inputs = [pin(Path(__file__)), pin(delta_file)]
    runs = []
    maps = {}
    for recipe_file in a.recipe:
        inputs.append(pin(recipe_file))
        recipe = json.loads(recipe_file.read_text())
        assert recipe['kind'] == 'phase66-conformance-observation-recipe'
        for command in recipe['commands']:
            report_file = Path(command['report'])
            if not report_file.exists():
                runs.append(dict(name=command['name'], report=str(report_file), observationsClosed=False))
                continue
            inputs.append(pin(report_file))
            report = json.loads(report_file.read_text())
            assert report['finished'] and report['started']
            assert not report['changedInputs']
            assert not report['identity']['adapterChangedDuringRun'] and not report['identity']['changedArtifacts']
            if report['workers'] is not None:
                assert report['workers'] and all(not r['errors'] for r in report['workers'])
            requested = [(r['id'], r['lane']) for r in report['selection']['requested']]
            actual = [(r['id'], r['lane']) for r in report['results']]
            assert len(actual) == len(set(actual)) == command['expectedObservations']
            assert sorted(requested) == sorted(actual)
            rowmap = {(r['id'].removeprefix('newdelta/'), r['lane']): r for r in report['results']}
            assert len(rowmap) == len(actual), 'Normalized fixture IDs collide'
            key = command['name']
            assert key not in maps, 'Duplicate role/lane name; compare one selected run per role'
            maps[key] = rowmap
            exact = {}
            for lane in sorted({r['lane'] for r in report['results']}):
                exact[lane] = dict(collections.Counter(r['status'] for r in report['results'] if r['lane'] == lane))
            checked = [r for r in report['results'] if r['lane'] == 'check']
            accepted = lambda r: r.get('result', {}).get('checked') is True and (r['result'].get('typeAccepted') is True or r['result'].get('typeAccepted') is None and r['result'].get('status') == 'ok')
            failures = [dict(id=r['id'], lane=r['lane'], status=r['status'], reason=r.get('reason'),
                phase=r.get('result', {}).get('phase'), diagnostic=r.get('result', {}).get('diagnostic'))
                for r in report['results'] if r['status'] not in ['pass', 'not-applicable', 'observed']]
            runs.append(dict(name=key, report=pin(report_file), observationsClosed=True,
                rows=len(actual), exactLanes=exact, selectedComplete=report['selectedComplete'],
                typeAcceptance=dict(total=len(checked), accepted=sum(accepted(r) for r in checked),
                    proofTrustRefusals=sum(r.get('evidence') == 'proof-trust-rejection' for r in checked),
                    checkerRejections=sum(r.get('evidence') == 'checker-rejection' for r in checked)),
                failures=failures, image=report['identity'], referenceRevision=report['inventory']['revision']))
    def observation(row):
        value = row.get('result') or {}
        out = {k: value.get(k) for k in ['phase', 'checked', 'typeAccepted', 'proofTrust', 'kernelChecked', 'unsafeDefinitions', 'exitCode', 'diagnostic']}
        out['status'] = value.get('status') if value.get('status') is not None else row['status']
        out['output'] = value.get('output') if value.get('output') is not None else value.get('stdout')
        return out
    comparisons = []
    pairs = [('typescript-old', 'bend-unchanged-old-base'), ('typescript-new', 'bend-candidate-new-base'),
        ('bend-unchanged-old-base', 'bend-candidate-new-base'), ('bend-unchanged-new-base', 'bend-candidate-new-base')]
    for lane in ['frontend', 'js']:
        for reference_role, candidate_role in pairs:
            reference_name, candidate_name = reference_role+'-'+lane, candidate_role+'-'+lane
            reference, candidate = maps.get(reference_name), maps.get(candidate_name)
            if reference is None or candidate is None:
                continue
            common = sorted(set(candidate)&set(reference))
            lost, gained, differences, observations = [], [], [], []
            for key in common:
                old, new = reference[key], candidate[key]
                detail = dict(id=key[0], lane=key[1], fixtureChange=changed.get(key[0], 'unchanged'), before=old['status'], after=new['status'])
                if old['status'] == 'pass' and new['status'] != 'pass':
                    lost.append(detail)
                if old['status'] != 'pass' and new['status'] == 'pass':
                    gained.append(detail)
                if old['status'] != new['status']:
                    differences.append(detail)
                before_observation, after_observation = observation(old), observation(new)
                if before_observation != after_observation:
                    observations.append(dict(detail, referenceObservation=before_observation, candidateObservation=after_observation))
            comparisons.append(dict(reference=reference_name, candidate=candidate_name,
                commonObservations=len(common), newlyMissingExactPasses=lost, newlyExactPasses=gained,
                statusDifferences=differences, exactObservationAgreements=len(common)-len(observations),
                observationDifferences=observations,
                referenceOnly=len(set(reference)-set(candidate)), candidateOnly=len(set(candidate)-set(reference))))
    for item in inputs:
        assert pin(item['file']) == item
    result = dict(kind='phase66-conformance-comparison', dataOnly=True,
        observationsClosed=all(r['observationsClosed'] for r in runs), inputs=inputs, runs=runs, comparisons=comparisons,
        scope='Exact status counts and separate complete normalized result-field comparisons, matching the maintained target tool. An observed negative parse label alone is never agreement or a checker pass. Type acceptance and proof-trust refusal remain distinct. Missing reports remain pending. A completed mismatching observation is not successful conformance. No Lean/GPU or general language-completeness claim.')
    a.out.parent.mkdir(parents=True, exist_ok=True)
    with a.out.open('x') as f:
        f.write(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(output=pin(a.out), observationsClosed=result['observationsClosed'], runs=len(runs))))


if __name__ == '__main__':
    main()
