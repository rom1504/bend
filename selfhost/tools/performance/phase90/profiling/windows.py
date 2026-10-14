#!/usr/bin/env python3
"""Offline 30 s wall-time ownership windows from a strictly accepted prefix."""
import argparse
import collections
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
METHOD = ROOT / 'selfhost/tools/performance/phase88/ownership/analyze.py'
spec = importlib.util.spec_from_file_location('ownership', METHOD)
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
A = M.A


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--analysis', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert not a.out.exists()
    strict = json.loads(a.analysis.read_bytes())
    assert strict['complete'] and strict['diagnosticStopped'] and not strict['targetComplete']
    for identity in strict['identities'].values():
        assert A.sha(identity['file']) == identity['sha256'], identity
    assert Path(strict['identities']['analyzer']['file']).resolve() == (
        ROOT / 'selfhost/tools/performance/phase89/partial-capture/analyze.py').resolve()
    binary = Path(strict['identities']['binary']['file'])
    samples_path = Path(strict['identities']['samples']['file'])
    # The completed reader requires final_tid==main. A watchdog-stopped prefix
    # has already passed the separate strict reader with a non-main final_tid.
    lines = samples_path.read_text().splitlines()
    assert lines[0] == 'BEND_OWNERSHIP_CPU_SAMPLES_V1' and lines[-1] == 'END'
    mi, si, ki = [lines.index(x) for x in ['MAPS', 'SAMPLES', 'MARKS']]
    header = dict(line.split('\t', 1) for line in lines[1:mi])
    mappings, samples, marks = [], [], []
    for line in lines[mi + 1:si]:
        f = line.split(maxsplit=5)
        low, high = [int(x, 16) for x in f[0].split('-')]
        mappings.append(dict(start=low, end=high, offset=int(f[2], 16), path=f[5] if len(f) > 5 else ''))
    for line in lines[si + 1:ki]:
        f = line.split('\t')
        assert len(f) == 6
        samples.append(dict(tid=int(f[0]), mono=int(f[1]), pc=int(f[2], 16),
                            callers=[int(x, 16) for x in f[3:] if int(x, 16)]))
    for line in lines[ki + 1:-1]:
        f = [int(x) for x in line.split('\t')]
        assert len(f) == 4
        marks.append(dict(index=f[0], tid=f[1], mono=f[2], cpu=f[3]))
    assert all(int(header[k]) == 0 for k in ['overruns', 'dropped', 'thread_overflow',
        'thread_clock_failures', 'timer_disarm_failures'])
    assert len(samples) == strict['sampleCount']
    segments = A.load_segments(binary)
    mappings = [m for m in mappings if m['path'] and Path(m['path']).resolve() == binary.resolve()]

    def address(pc):
        for mapping in mappings:
            if mapping['start'] <= pc < mapping['end']:
                return A.virtual_address(pc, mapping, segments)
        return None

    addresses = {v for s in samples for pc in [s['pc'], *(r - 1 for r in s['callers'])]
                 if (v := address(pc)) is not None}
    symbols = A.symbolize(binary, addresses)

    def name(pc):
        return symbols.get(address(pc), [dict(function='[outside]')])[0]['function']

    bins = collections.defaultdict(lambda: dict(leaf=collections.Counter(), owners=collections.Counter(),
        sites=collections.Counter(), threads=collections.Counter()))
    first = min(s['mono'] for s in samples)
    for sample in samples:
        bucket = bins[(sample['mono'] - first) // 30000000000]
        leaf = name(sample['pc'])
        bucket['leaf'][leaf] += 1
        bucket['threads'][sample['tid']] += 1
        if leaf in M.OWNERSHIP and sample['callers']:
            pc = sample['callers'][-1] - 1
            owner = name(pc)
            bucket['owners'][leaf, owner] += 1
            bucket['sites'][leaf, owner, address(pc)] += 1
    windows = []
    for index, bucket in sorted(bins.items()):
        count = sum(bucket['leaf'].values())
        windows.append(dict(startWallSeconds=int(index) * 30, endWallSeconds=(int(index) + 1) * 30,
            samples=count, sampleCountCpuEstimateSeconds=count * int(header['period_us']) / 1000000,
            threadSamples=dict(bucket['threads']),
            leaves=[dict(function=f, samples=n, percent=100 * n / count)
                    for f, n in bucket['leaf'].most_common()],
            ownershipCallers=[dict(leaf=k[0], owner=k[1], samples=n, percent=100 * n / count)
                              for k, n in bucket['owners'].most_common()],
            ownershipReturnSites=[dict(leaf=k[0], owner=k[1], address=hex(k[2]) if k[2] else None, samples=n)
                                  for k, n in bucket['sites'].most_common()]))
    result = dict(kind='phase90-strict-prefix-windows', complete=True, targetComplete=False,
        emittedCCorrectnessProved=False, firstSampleMonotonicNs=first, periodUs=int(header['period_us']),
        rawMarks=marks, windows=windows, identities={
            'strictAnalysis': dict(file=str(a.analysis.resolve()), sha256=A.sha(a.analysis)),
            'method': dict(file=str(Path(__file__).resolve()), sha256=A.sha(__file__)),
            'ownershipMethod': dict(file=str(METHOD), sha256=A.sha(METHOD))},
        limitations=['30 s windows use monotonic wall time; they are not compiler-stage boundaries.',
            'Count times sampling period is an approximate sampled-thread CPU amount, not a phase clock.',
            'Physical callers only; musttail-erased Bend frames are not reconstructed.',
            'Accepted capture prefix remains an intentionally incomplete compiler run.'])
    with a.out.open('x') as stream:
        json.dump(result, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(windows=len(windows), samples=len(samples), targetComplete=False)))


if __name__ == '__main__':
    main()
