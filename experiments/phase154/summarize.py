#!/usr/bin/env python3
"""Offline Phase154 accounting; never runs a compiler or changes evidence."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / 'selfhost/build/phase154'
OUT = ROOT / 'implementation/phase154'


def read(path):
    return json.loads(path.read_text())


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data),
                sha256=hashlib.sha256(data).hexdigest())


def main():
    OUT.mkdir(exist_ok=True)
    metrics = dict(kind='phase154-direct-identities-results', complete=True,
                   baselineCommit='bde17c0', productionChanged=False,
                   qualification='private prototype only', timings={}, profiles={},
                   inputs=[])
    for family in ('compiler', 'map'):
        path = BUILD / f'time-{family}01/report.json'
        report = read(path)
        assert report['complete'] and report['passed'] and report['performanceQualified']
        metrics['inputs'].append(pin(path))
        metrics['timings'][family] = dict(
            medianSeconds=report['medianSeconds'], ratio=report['ratio'],
            timeReductionPercent=100 * (1 - report['ratio']),
            repeats=report['repeats'], pairRatios=[p['ratio'] for p in report['pairs']],
            clocks='whole child, fixed setup and cleanup included; no subtraction',
            region=report['region'])
    for path in sorted((BUILD / 'profile-plan01/capture').glob('*/analysis.json')):
        report = read(path)
        assert report['usable'] and report['zeroLoss']
        role = path.parent.name.rsplit('-', 1)[1]
        leaves = report['top_functions']
        groups = {g['name']: g['samples'] for g in report['groups']}
        metrics['inputs'].append(pin(path))
        metrics['profiles'][role] = dict(
            samples=report['header']['samples'], repeats=33, periodUs=16000,
            groups=groups,
            namedIndexHashSamples=sum(f['samples'] for f in leaves
                                      if f['decoded'].endswith('.index_hash')),
            quality=report['quality'],
            warning='One physical leaf capture per role. Not logical allocation attribution or a clean speed estimate.')
    controls = BUILD / 'controls03/report.json'
    metrics['inputs'].append(pin(controls))
    metrics['controls'] = dict(passed=read(controls)['passed'], rows=len(read(controls)['rows']),
                               literalScalarCases=25, actualOwners=20,
                               sameProducerRefusals=5, sameVerifierContextRefusals=6,
                               verifiedExactOutputOwners=9)
    metrics['decision'] = ('Retain private prototype; no production migration or full self-build. '
                           'Near-2x discriminator not met. Legacy direct producer coverage '
                           'does not establish the complete prepared backend region.')
    metrics['unmeasured'] = ['whole cold build gain', 'current upstream ratio',
                             'general generated-program runtime', 'recursive research acceleration']
    (OUT / 'metrics.json').write_text(json.dumps(metrics, indent=2) + '\n')
    jobs = []
    for path in sorted(BUILD.rglob('process.json')):
        report = read(path)
        if report.get('kind') != 'build-retention-disk-guard-v1':
            continue
        jobs.append(dict(receipt=pin(path), returncode=report['returncode'],
                         wallSeconds=report['wallSeconds'],
                         peakTreeRssBytes=report['peakTreeRssBytes']))
    cost = dict(kind='phase154-costs', jobs=jobs, guardedJobs=len(jobs),
                guardedWallSeconds=sum(j['wallSeconds'] for j in jobs),
                failedJobs=sum(j['returncode'] != 0 for j in jobs),
                peakTreeRssBytes=max(j['peakTreeRssBytes'] for j in jobs),
                fullCompilerBuilds=0, smallNativeImageBuilds=1,
                scope='Guard time includes preparation, failures, timing and validation. '
                      'Excludes agent work, offline analysis, documentation and retention. '
                      'No billing/quota telemetry is available.')
    (OUT / 'cost.json').write_text(json.dumps(cost, indent=2) + '\n')
    print(json.dumps(dict(timings=metrics['timings'], guardedSeconds=cost['guardedWallSeconds'])))


if __name__ == '__main__':
    main()
