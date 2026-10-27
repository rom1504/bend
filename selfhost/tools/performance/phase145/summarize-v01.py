#!/usr/bin/env python3
"""Summarize already completed Phase145 observations; never run a target."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists(), 'Use a fresh summary path'
    inputs = [pin(__file__)]

    def read(relative):
        path = ROOT / relative
        data = json.loads(path.read_text())
        assert data['complete'] is True, path
        inputs.append(pin(path))
        return data

    clean = read('selfhost/build/phase145/execution-clean01/report.json')
    index = read('selfhost/build/phase145/execution-index01/report.json')
    warm = read('selfhost/build/phase145/execution-warm02/report.json')
    upstream = read('selfhost/build/phase145/upstream03/summary01.json')
    cases = clean['cases'] + index['cases']
    observations = clean['observations'] + index['observations']
    assert len(observations) == 30 and all(row['byteExact'] for row in observations)
    guards = []
    for path in sorted((ROOT / 'selfhost/build/phase145').rglob('process.json')):
        if not path.parent.name.endswith('-guard'):
            continue
        data = json.loads(path.read_text())
        assert 'finished' in data and 'returncode' in data, path
        inputs.append(pin(path))
        guards.append(dict(receipt=pin(path), **{key: data[key] for key in (
            'complete', 'started', 'finished', 'wallSeconds', 'returncode',
            'peakTreeRssBytes', 'minimumAvailableBytes')}))
    assert all(a['finished'] <= b['started'] for a, b in
               zip(sorted(guards, key=lambda r: r['started']),
                   sorted(guards, key=lambda r: r['started'])[1:])), 'Overlapping target lane'
    failed = [r for r in guards if not r['complete'] or r['returncode'] != 0]
    result = dict(
        kind='phase145-comparative-work-summary', complete=True, targetsRun=False,
        inputs=inputs, sameSourceCases=cases, exactCleanProducts=len(observations),
        warmIterations=[{k: r[k] for k in ('iteration', 'warmup', 'seconds', 'byteExact')}
                        for r in warm['iterations']],
        upstreamCases=[dict(name=r['name'], mode=r['mode'],
                            compilerActionSeconds=r['compilerActionSeconds'],
                            emissionFixedPoint=r.get('emissionFixedPoint'))
                       for r in upstream['rows']],
        cost=dict(guardedJobs=len(guards), guardedSeconds=sum(r['wallSeconds'] for r in guards),
                  failedJobs=len(failed), failedSeconds=sum(r['wallSeconds'] for r in failed),
                  peakTreeRssBytes=max(r['peakTreeRssBytes'] for r in guards),
                  minimumAvailableBytes=min(r['minimumAvailableBytes'] for r in guards),
                  nonoverlappingTargetLane=True,
                  scope='Includes target supervision and two failed attempts; excludes metadata preparation, analysis, agent effort, archiving and prior compiler acquisition. Not quota accounting.'),
        guards=guards,
        scope=['Same-source comparison uses complete exact ordinary QBE and fresh processes, prepared Base and natural JS GC. OS caches are not flushed.',
               'Upstream compiler-action subtotals include Base checking and emit C; they are not denominator-compatible parity measurements.',
               'Warm engine iteration clocks differ from cold process clocks; counters and stage probes are diagnostic.',
               'Production compiler, runtime, qualification and default selection are unchanged.'])
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(complete=True, cost=result['cost'], sameSourceCases=cases)))


if __name__ == '__main__':
    main()
