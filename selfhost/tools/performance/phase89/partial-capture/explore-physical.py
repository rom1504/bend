#!/usr/bin/env python3
"""Unqualified, offline physical-PC description; never accepts a capture."""
import argparse
import collections
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
METHOD = ROOT / 'selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py'
spec = importlib.util.spec_from_file_location('symbols', METHOD)
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)
OWNERSHIP = {'term_drop', 'span_fade', 'rfc_wrap'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['samples', 'binary', 'process', 'out']:
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    assert not args.out.exists(), 'Preserve earlier analysis'
    lines = args.samples.read_text().splitlines()
    assert lines[0] == 'BEND_OWNERSHIP_CPU_SAMPLES_V1' and lines[-1] == 'END'
    mi, si, ki = [lines.index(x) for x in ['MAPS', 'SAMPLES', 'MARKS']]
    header = dict(line.split('\t', 1) for line in lines[1:mi])
    binary = args.binary.resolve()
    assert A.sha(binary) == header['target_sha256']
    assert Path(header['exe']).resolve() == binary
    process = json.loads(args.process.read_bytes())
    assert process['returncode'] == 77 and str(binary) in process['command']
    mappings = []
    for line in lines[mi + 1:si]:
        f = line.split(maxsplit=5)
        low, high = [int(x, 16) for x in f[0].split('-')]
        if len(f) == 6 and f[5] == str(binary):
            mappings.append(dict(start=low, end=high, offset=int(f[2], 16)))
    segments = A.load_segments(binary)

    def address(pc):
        for mapping in mappings:
            if mapping['start'] <= pc < mapping['end']:
                return A.virtual_address(pc, mapping, segments)
        return None

    rows = []
    for line in lines[si + 1:ki]:
        f = line.split('\t')
        assert len(f) == 6
        rows.append((int(f[1]), int(f[2], 16),
                     [int(x, 16) - 1 for x in f[3:] if int(x, 16)]))
    assert len(rows) == int(header['samples']) and rows
    addresses = {va for _, pc, callers in rows for p in [pc, *callers]
                 if (va := address(p)) is not None}
    symbols = A.symbolize(binary, addresses)

    def describe(pc):
        return symbols.get(address(pc), [dict(function='[outside]')])[0]['function']

    leaves, owners, sites = (collections.Counter() for _ in range(3))
    bins = collections.defaultdict(collections.Counter)
    site_bins = collections.defaultdict(collections.Counter)
    first = min(x[0] for x in rows)
    for mono, pc, callers in rows:
        leaf = describe(pc)
        window = (mono - first) // 10**10
        leaves[leaf] += 1
        bins[window][leaf] += 1
        if leaf in OWNERSHIP and callers:
            owner = describe(callers[-1])
            owners[leaf, owner] += 1
            key = (leaf, owner, address(callers[-1]))
            sites[key] += 1
            site_bins[window][key] += 1

    def top(counter):
        return [dict(function=name, samples=n, percent=100 * n / sum(counter.values()))
                for name, n in counter.most_common()]

    overruns = int(header['overruns'])
    report = dict(schema='phase89-unqualified-physical-description-v1', qualified=False,
        targetComplete=False, emittedCCorrectnessProved=False,
        rejection='Original strict partial analyzer rejects any timer overrun; unchanged.',
        header=header, sampleCount=len(rows), overruns=overruns,
        unrecordedExpirationFraction=overruns / (len(rows) + overruns),
        rawMarks=[list(map(int, line.split('\t'))) for line in lines[ki + 1:-1]],
        leaf=top(leaves), windows=[dict(startSeconds=int(i) * 10,
            samples=sum(c.values()), leaf=top(c)) for i, c in sorted(bins.items())],
        physicalOwners=[dict(leaf=k[0], owner=k[1], samples=n)
                        for k, n in owners.most_common()],
        ownershipReturnSites=[dict(leaf=k[0], owner=k[1], address=hex(k[2]) if k[2] else None,
            samples=n, frames=symbols.get(k[2]),
            windows={str(i): c[k] for i, c in sorted(site_bins.items())})
            for k, n in sites.most_common()],
        identities={name: dict(file=str(path.resolve()), sha256=A.sha(path))
            for name, path in dict(samples=args.samples, binary=binary, process=args.process,
                method=Path(__file__), symbolMethod=METHOD).items()},
        limitations=['This description does not qualify, repair or replace the rejected capture.',
            'Stopped first-request prefix, not completed stage, compilation speed or correctness evidence.',
            'Only bounded physical return addresses; no reconstruction of musttail-erased Bend callers.',
            'Windows start at first sample; they are not inferred parser/checker/backend phase boundaries.',
            'Leaf sample fractions and caller fractions are not removable-time forecasts.'])
    with args.out.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(qualified=False, samples=len(rows), overruns=overruns)))


if __name__ == '__main__':
    main()
