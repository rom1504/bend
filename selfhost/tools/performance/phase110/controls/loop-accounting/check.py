#!/usr/bin/env python3
"""Independently reconcile saved timings and unchanged semantic observations."""
import argparse
import hashlib
import json
import math
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
PHASES = {'open', 'setup', 'workerEnvelope', 'pendingCheck', 'observation',
          'resultAndAliasDrop', 'liveAccountingAndClose', 'bookkeepingAndStdout'}


def pin(path):
    data = path.read_bytes()
    return {'file': str(path.resolve()), 'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def records(path):
    return [json.loads(line) for line in path.read_text().splitlines() if line.strip()]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--prepared', type=Path, required=True)
    parser.add_argument('--stdout', type=Path, required=True)
    parser.add_argument('--stderr', type=Path, required=True)
    parser.add_argument('--case', action='append', help='repeatable; defaults to frozen seven timing cases')
    parser.add_argument('--process-seconds', type=float, help='optional independently recorded total child-process wall time')
    parser.add_argument('--out', type=Path)
    args = parser.parse_args()
    prepared = json.loads((args.prepared / 'manifest.json').read_text())
    assert prepared['kind'] == 'phase110-prepared-loop-accounting-v1' and prepared['complete']
    for row in prepared['inputs'] + prepared['outputs']:
        actual = pin(ROOT / row['file'])
        assert (actual['bytes'], actual['sha256']) == (row['bytes'], row['sha256']), row['file']
    selected = args.case or prepared['timingCases']
    assert len(selected) == len(set(selected)), 'duplicate requested case'
    expected = {row['name']: row for row in records(args.prepared / 'expected.jsonl')}
    observed, timing = records(args.stdout), records(args.stderr)
    assert len(observed) == len(timing) == len(selected), 'wrong observation/timing count'
    assert {row['name'] for row in observed} == {row['name'] for row in timing} == set(selected)
    for row in observed:
        assert row == expected[row['name']], ('semantic oracle mismatch', row['name'])
    rows = []
    for row in timing:
        assert row['accountingVersion'] == 1 and row['clock'] == 'CLOCK_MONOTONIC'
        assert type(row['repetitions']) is int and 1 <= row['repetitions'] <= 10000
        assert type(row['maxBumpWords']) is int and row['maxBumpWords'] >= 0
        phases = row['phasesNanoseconds']
        assert set(phases) == PHASES and all(type(v) is int and v >= 0 for v in phases.values())
        for name in ('outerNanoseconds', 'partitionNanoseconds', 'accountedNanoseconds', 'residualNanoseconds'):
            assert type(row[name]) is int and row[name] >= 0, name
        total = sum(phases.values())
        assert total == row['partitionNanoseconds'] == row['accountedNanoseconds'], ('phase mismatch', row['name'])
        assert total + row['residualNanoseconds'] == row['outerNanoseconds'], ('outer mismatch', row['name'])
        worker = row['workerSeconds']
        assert isinstance(worker, (int, float)) and math.isfinite(worker) and worker >= 0
        # Original clock stores doubles and prints nine decimals. Allow only
        # rounding-scale slack when comparing it with the enclosing ns ledger.
        assert worker * 1e9 <= phases['workerEnvelope'] + 2000 * row['repetitions'], ('worker outside envelope', row['name'])
        rows.append({**row, 'openAndSetupNanoseconds': phases['open'] + phases['setup'],
                     'originalWorkerFractionOfOuter': worker * 1e9 / row['outerNanoseconds'] if row['outerNanoseconds'] else None})
    outer = sum(row['outerNanoseconds'] for row in rows)
    phase_totals = {key: sum(row['phasesNanoseconds'][key] for row in rows) for key in sorted(PHASES)}
    external = args.process_seconds
    if external is not None:
        assert math.isfinite(external) and external >= 0
        assert external + 1e-6 >= outer / 1e9, 'independent process wall time is shorter than summed run intervals'
    result = {'kind': 'phase110-loop-accounting-reconciliation-v1', 'complete': True,
              'semanticCasesPassed': len(rows), 'totalRepetitions': sum(row['repetitions'] for row in rows),
              'outerNanoseconds': outer, 'phasesNanoseconds': phase_totals,
              'partitionNanoseconds': sum(phase_totals.values()),
              'residualNanoseconds': sum(row['residualNanoseconds'] for row in rows),
              'workerSeconds': sum(row['workerSeconds'] for row in rows),
              'externalProcessSeconds': external,
              'processOutsideRunSeconds': external - outer / 1e9 if external is not None else None,
              'inputs': [pin(path) for path in (args.prepared / 'manifest.json', args.stdout, args.stderr, Path(__file__))],
              'rows': rows,
              'scope': 'Saved observations only; no target execution. External process residual includes startup, selection, final formatting/flushing and teardown when supplied.'}
    if args.out:
        if args.out.exists():
            raise ValueError('fresh output file required')
        args.out.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
