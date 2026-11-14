#!/usr/bin/env python3
"""Root-lane paired ceiling timings from already validated owned-projection products."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import statistics
import subprocess
import time


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def verify(identity):
    assert pin(identity['file']) == identity, 'Changed input: '+identity['file']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--controls', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--group', choices=['hot', 'cold'], default='hot')
    parser.add_argument('--rounds', type=int, default=4)
    parser.add_argument('--repetitions', type=int, default=20000)
    parser.add_argument('--depth', type=int, default=8)
    parser.add_argument('--seconds', type=int, default=90)
    args = parser.parse_args()
    assert os.sched_getaffinity(0) == {3}, 'Use root-owned outer guarded CPU3 lane'
    assert 1 <= args.rounds <= 8 and 1 <= args.repetitions <= 10000000
    assert 0 <= args.depth <= 8 and 1 <= args.seconds <= 300
    assert not args.out.exists(), 'Fresh output required'
    authority = json.loads(args.controls.read_text())
    assert authority['complete'] and authority['kind'] == 'phase195-owned-projection-ceiling'
    assert authority['rows'][args.group]['complete']
    product = next(row for row in authority['machines']
                   if row['group'] == args.group and row['route'] == 'direct')
    inputs = [pin(__file__), pin(args.controls), product['binary']]
    for identity in inputs:
        verify(identity)
    args.out.mkdir(parents=True)
    result = dict(kind='phase195-owned-projection-ceiling-timing', complete=False,
        inputs=inputs, options=vars(args) | {'controls': str(args.controls), 'out': str(args.out)},
        rows=[], scope='Matched emitted baseline/candidate tree readers on already validated '
        'inputs. In-program elapsed includes identical payload/checksum observations, excludes '
        'tree construction/destruction. Whole-process wall includes both and runtime setup. '
        'No actual Map workload, general observer admission or compiler throughput claim.')

    def save():
        (args.out/'report.json').write_text(json.dumps(result, indent=2)+'\n')

    mask = (1 << 64)-1

    def mix(a, b):
        return ((a ^ b)*1099511628211) & mask

    expected = 0
    for i in range(args.repetitions):
        query = (i*17) & ((1 << args.depth)-1)
        expected = mix(expected, mix(mix(7, query*17+11), query*31+13))
    result['expectedChecksum'] = expected
    start = time.monotonic()
    save()
    try:
        for shared in [0, 1]:
            for block in range(args.rounds):
                order = [0, 1] if block % 2 == 0 else [1, 0]
                for role in order:
                    for identity in inputs:
                        verify(identity)
                    left = args.seconds-(time.monotonic()-start)
                    assert left > 0, 'Whole-run deadline exhausted'
                    command = [product['binary']['file'], 'bench', str(role),
                               str(args.repetitions), str(args.depth), str(shared)]
                    begin = time.monotonic()
                    env = dict(os.environ, LC_ALL='C')
                    for name in ['LD_PRELOAD', 'LD_AUDIT', 'BENDRTS']:
                        env.pop(name, None)
                    process = subprocess.run(command, stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE, timeout=min(30, left), env=env)
                    label = f'shared{shared}-block{block}-role{role}'
                    stdout, stderr = args.out/(label+'.stdout'), args.out/(label+'.stderr')
                    stdout.write_bytes(process.stdout)
                    stderr.write_bytes(process.stderr)
                    row = dict(shared=shared, block=block, role=role, command=command,
                        wallSeconds=time.monotonic()-begin, returncode=process.returncode,
                        stdout=pin(stdout), stderr=pin(stderr))
                    result['rows'].append(row)
                    save()
                    assert process.returncode == 0 and not process.stderr, 'Target/oracle failed'
                    pattern = (rb'phase195 ownership bench: role=(\d+) cold=(\d+) shared=(\d+) '
                        rb'depth=(\d+) repetitions=(\d+) checksum=(\d+) fast=(\d+) '
                        rb'elapsed_ns=(\d+) failures=(\d+)\n')
                    match = re.fullmatch(pattern, process.stdout)
                    assert match, 'Unexpected output'
                    fields = list(map(int, match.groups()))
                    assert fields[:6] == [role, int(args.group == 'cold'), shared,
                        args.depth, args.repetitions, expected] and fields[8] == 0
                    assert 0 <= fields[6] <= args.repetitions and fields[7] > 0
                    if role == 0:
                        assert fields[6] == 0
                    elif args.group == 'hot':
                        assert fields[6] == args.repetitions
                    row.update(fastRoutes=fields[6], elapsedNanoseconds=fields[7],
                               nsPerIteration=fields[7]/args.repetitions, oraclePassed=True)
                    save()
        summaries = {}
        for shared in [0, 1]:
            values = {role: [row['nsPerIteration'] for row in result['rows']
                            if row['shared'] == shared and row['role'] == role] for role in [0, 1]}
            medians = {role: statistics.median(xs) for role, xs in values.items()}
            summaries[str(shared)] = dict(samples=values, medians=medians,
                                           candidateOverBaseline=medians[1]/medians[0])
        result.update(complete=True, bySharing=summaries)
    except Exception as error:
        result['error'] = repr(error)
        raise
    finally:
        result['wallSeconds'] = time.monotonic()-start
        save()
    print(json.dumps(result['bySharing']))


if __name__ == '__main__':
    main()
