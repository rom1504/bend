#!/usr/bin/env python3
"""Summarize existing runtime receipts; reads data, never executes a target."""
import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path


def summarize(root):
    def pin(path):
        path = path.resolve(strict=True)
        data = path.read_bytes()
        return dict(path=str(path.relative_to(root)), bytes=len(data),
                    sha256=hashlib.sha256(data).hexdigest())

    raw = root / 'selfhost/build/phase70'
    names = [('originalSix', 'compiler02-native06-comparison', 54),
             ('sixAdditions', 'compiler02-coverage-final-comparison01', 54),
             ('narrowStability', 'compiler02-native-stability02', 36)]
    output = dict(kind='phase70-compiler02-native-runtime-checkpoint',
                  targetsExecutedBySummarizer=False, promoted=False,
                  producer=pin(Path(__file__)), campaigns={})
    for label, directory, count in names:
        report_path = raw / directory / 'report.json'
        report = json.loads(report_path.read_text())
        assert report['complete'] and len(report['records']) == count
        plan_path = raw / directory / 'plan.json'
        plan = json.loads(plan_path.read_text())
        assert pin(plan_path)['sha256'] == report['plan']['sha256']
        observations = []
        for row in report['records']:
            assert row['correct'] and row['qualified'] and row['elapsedMs'] >= 100
            child = row['child']
            assert row['process']['complete'] and child['returncode'] == 0 and not child['stderr']
            actual = list(map(int, child['stdout'].strip().splitlines()))
            assert actual == row['expected'] + [row['elapsedMs']]
            assert row['elapsedMs'] <= child['processSeconds'] * 1000 + 2
            assert row['repetitions'] == plan['counts'][row['case']]['repetitions']
            assert row['warmups'] == plan['counts'][row['case']]['warmups']
            observations.append(dict(case=row['case'], role=row['role'], round=row['round'],
                repetitions=row['repetitions'], warmups=row['warmups'], expected=row['expected'],
                actual=actual, elapsedMs=row['elapsedMs'], correct=True, qualified=True,
                processSeconds=child['processSeconds'], userSeconds=child['userSeconds'],
                systemSeconds=child['systemSeconds']))
        rows = []
        for row in report['rows']:
            medians = {role: statistics.median(x['elapsedMs'] for x in observations
                if x['case'] == row['case'] and x['role'] == role)
                for role in ['baseline69', 'candidate', 'upstream']}
            assert medians == row['mediansMs']
            ratios = dict(candidateOverUpstream=medians['candidate']/medians['upstream'],
                baselineOverUpstream=medians['baseline69']/medians['upstream'],
                candidateOverBaseline=medians['candidate']/medians['baseline69'],
                baselineOverCandidate=medians['baseline69']/medians['candidate'])
            assert ratios['candidateOverUpstream'] == row['candidateOverUpstream']
            assert ratios['baselineOverCandidate'] == row['baseline69OverCandidate']
            rows.append(dict(case=row['case'], mediansMs=medians, **ratios,
                             timeReductionPercent=100*(1-ratios['candidateOverBaseline'])))
        gm = lambda key: math.exp(statistics.mean(math.log(row[key]) for row in rows))
        assert math.isclose(gm('candidateOverUpstream'), report['geomeanCandidateOverUpstream'])
        assert math.isclose(gm('baselineOverCandidate'), report['geomeanBaseline69OverCandidate'])
        output['campaigns'][label] = dict(report=pin(report_path), plan=pin(plan_path),
            started=report['started'], finished=report['finished'], qualifiedIntervals=count,
            rows=rows, observations=observations,
            geomeanCandidateOverUpstream=gm('candidateOverUpstream'),
            geomeanBaselineOverUpstream=gm('baselineOverUpstream'),
            geomeanCandidateOverBaseline=gm('candidateOverBaseline'),
            geomeanBaselineOverCandidate=gm('baselineOverCandidate'),
            geometricTimeReductionPercent=100*(1-gm('candidateOverBaseline')))
    primary = [output['campaigns'][key] for key in ['originalSix', 'sixAdditions']]
    output['optionalTwelveEqualFamilyWeights'] = dict(
        geomeanCandidateOverUpstream=math.sqrt(math.prod(x['geomeanCandidateOverUpstream'] for x in primary)),
        scope='Explicit equal-family union of two distinct six-family campaigns; not a replacement for either primary denominator. Narrow stability observations are excluded.')
    output['identities'] = [pin(path) for path in [
        raw/'compiler02/equality/api.mjs',
        root/'selfhost/build/phase69/typed-build10/equality/api.mjs',
        raw/'compiler02-coverage-final-plan01/holdouts.json',
        raw/'compiler02-coverage-final-plan01/queue.json',
        raw/'compiler02-coverage-recipe.json',
        raw/'compiler02-coverage-missing-five01/report.json',
        raw/'compiler02-coverage-baseline-holdouts01/report.json',
        root/'selfhost/tools/performance/phase70/coverage/cases-v2.json',
        root/'selfhost/tools/performance/phase70/coverage/oracle-v2.py',
        root/'selfhost/tools/performance/phase70/coverage/array-map-shape-v2.json',
    ]]
    output['limits'] = ('These are B1-emitted C program runtimes after Clang compilation, not B1/B2 compiler request time. '
        'Summary retains every interval including unfavorable samples. Three primary rounds per role and finite fixed workloads do not establish universal parity. '
        'Raw reports and plans remain authoritative; this portable summary pins them and carries their timing/correctness observations. '
        'No release installation or later compiler variant is measured by this checkpoint.')
    return output


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    result = summarize(args.root.resolve())
    with args.out.open('x') as stream:
        stream.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(output=str(args.out), qualifiedIntervals=sum(
        item['qualifiedIntervals'] for item in result['campaigns'].values()),
        optionalTwelve=result['optionalTwelveEqualFamilyWeights'], targetsExecuted=False)))
