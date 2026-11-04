#!/usr/bin/env python3
"""Summarize immutable Phase156 observations; does not execute the compiler."""
import hashlib
import json
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build/phase156'


def identity(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024*1024), b''):
            digest.update(block)
    return dict(file=str(path.relative_to(ROOT)), bytes=path.stat().st_size,
                sha256=digest.hexdigest())


def main():
    observations = []
    receipts = []
    for name in ('pilot01', 'full01', 'map02', 'full02'):
        path = BUILD / name / 'report.json'
        report = json.loads(path.read_text())
        assert report['complete'], path
        receipts.append(identity(path))
        for case in report['cases']:
            assert all(row['passed'] and row['byteExact'] for row in case['rows'])
            observations.append(dict(run=name, case=case['name'],
                source=case['source'], oracle=case['oracle'],
                rounds=report['rounds'], **case['summary'],
                rows=[dict(role=row['role'], round=row['round'],
                           seconds=row['process']['seconds'], product=row['product'])
                      for row in case['rows']]))
    guards = []
    for path in sorted(BUILD.rglob('process.json')):
        record = json.loads(path.read_text())
        if record.get('kind') != 'build-retention-disk-guard-v1':
            continue
        assert 'finished' in record, path
        guards.append(dict(receipt=identity(path), complete=record['complete'],
            returncode=record['returncode'], seconds=record['wallSeconds'],
            peakRssBytes=record['peakTreeRssBytes'],
            minimumFreeBytes=record['minimumDiskFreeBytes']))
    full_rows = [row for case in observations if case['case'] == 'full-compiler' for row in case['rows']]
    full_medians = {role:statistics.median(row['seconds'] for row in full_rows if row['role'] == role)
                    for role in ('old', 'publication')}
    full_ratio = full_medians['publication'] / full_medians['old']
    result = dict(kind='phase156-transfer-summary', complete=True,
        observations=observations, receipts=receipts, guards=guards,
        balancedFull=dict(observationsPerRole=2, medianSeconds=full_medians,
            candidateOverOriginal=full_ratio, timeReductionPercent=100*(1-full_ratio),
            note='One old-first pair and one publication-first pair. No confidence interval.'),
        guardedSeconds=sum(g['seconds'] for g in guards),
        guardCount=len(guards), maximumTreeRssBytes=max(g['peakRssBytes'] for g in guards),
        scope='Pilot has one observation per role/case; full has two reversed pairs and Map follow-up two balanced rounds. Shared native image, live Base preparation, '
              'fresh child request through complete QBE write and teardown. '
              'No machine build in request clocks, confidence interval, upstream ratio '
              'or generated-program runtime measurement. Guard time excludes agent, '
              'documentation and retention work. Successful guard exit is not a semantic pass.',
        maintainedSourceChanged=False, productionSelectionChanged=False,
        fullCompilerImageBuilt=False,
        semanticGate=dict(primary='selfhost/build/phase156/controls02/report.json',
            correction='selfhost/build/phase156/duplicate01/report.json',
            note='Primary report remains failed for one parser-expectation error. '
                 'The separately bound correction closes that row; neither report is rewritten.'))
    dest = ROOT / 'implementation/phase156/metrics.json'
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(result, indent=2) + '\n')
    categories = dict(sourceChecking=0., semanticControls=0., sharedNativeBuild=0.,
                      actualRequestMeasurements=0.)
    for row in guards:
        name = row['receipt']['file']
        key = ('sourceChecking' if '/checked-api-guard/' in name else
               'sharedNativeBuild' if '/native-guard/' in name else
               'semanticControls' if any('/'+n+'-guard/' in name for n in ('controls01','controls02','duplicate01')) else
               'actualRequestMeasurements')
        categories[key] += row['seconds']
    cost = dict(kind='phase156-cost', complete=True, guardSeconds=categories,
        totalGuardSeconds=result['guardedSeconds'], guards=len(guards),
        accounting='All executed guards, including failed/rejected attempts. Request campaigns include full-byte '
                   'verification, harness overhead and (pilot only) fresh original oracle requests. '
                   'Source checks are independent; controls01/02 had harness failures retained with correction. '
                   'No source-to-executable self-build or broad benchmark campaign. Agent, documentation, '
                   'packaging and retention effort are separate and not inferred from guard clocks.',
        bendPrototypeLines=sum(len(p.read_text().splitlines()) for p in (ROOT/'selfhost/tests/phase156').glob('*.bend')),
        maintainedCompilerLineDelta=0, newCompilerSelections=0,
        independentAgentWork='Publication invariant/control preparation; dense eligibility; shared-use implementation '
                             'and machine audit; request/semantic audit; retention/evidence preparation. '
                             'Root owns integration and all target execution. No token/quota amount claimed.')
    (dest.parent/'cost.json').write_text(json.dumps(cost, indent=2)+'\n')
    print(json.dumps(dict(guardCount=result['guardCount'], guardedSeconds=result['guardedSeconds'],
        observations=[{k:r[k] for k in ('case','medianSeconds','ratios')} for r in observations])))


if __name__ == '__main__':
    main()
