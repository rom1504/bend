#!/usr/bin/env python3
"""Offline physical-PC bins from an intentionally stopped ownership capture."""
import argparse
import collections
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
spec = importlib.util.spec_from_file_location('symbols', ROOT / 'selfhost/tools/performance/phase68/parity-survey/sample-analysis-v2.py')
A = importlib.util.module_from_spec(spec)
spec.loader.exec_module(A)


def require(ok, message):
    if not ok:
        raise ValueError(message)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['samples', 'binary', 'table', 'stderr', 'process', 'out']:
        p.add_argument('--' + name, type=Path, required=True)
    a = p.parse_args()
    require(not a.out.exists(), 'Output must be fresh')
    process = json.loads(a.process.read_bytes())
    require(process.get('returncode') == 77 and 'stoppedFor' not in process
            and 'error' not in process, 'Expected intentional watchdog exit77 before outer guard')
    stderr = a.stderr.read_text()
    require(stderr.count('BEND_CAPTURE_STOP seconds=') == 1 and ' exit=77 tid=' in stderr,
            'Missing or ambiguous watchdog stop marker')
    lines = a.samples.read_text().splitlines()
    require(lines[0] == 'BEND_OWNERSHIP_CPU_SAMPLES_V1' and lines[-1] == 'END', 'Incomplete raw capture')
    mi, si, ki = (lines.index(x) for x in ['MAPS', 'SAMPLES', 'MARKS'])
    header = dict(line.split('\t', 1) for line in lines[1:mi])
    header = {k: int(v) if v.isdigit() else v for k, v in header.items()}
    require(header['pid'] == header['tid'] and header['handler_intact'] == 1, 'Invalid sampler identity/handler')
    require(all(header[k] == 0 for k in ['dropped', 'overruns', 'thread_overflow',
            'thread_clock_failures', 'timer_disarm_failures']), 'Lost, delayed or unaccounted samples')
    require(header['threads_ready'] == header['threads_allocated'], 'Uninitialized sampled thread')
    table = json.loads(a.table.read_bytes())
    binary = a.binary.resolve()
    require(A.sha(binary) == table['binary_sha256'] == header['target_sha256']
            and Path(header['exe']).resolve() == binary, 'Wrong image/unwind table')
    require(str(binary) in process['command'], 'Guard does not bind sampled executable')
    maps = []
    for line in lines[mi + 1:si]:
        fields = line.split(maxsplit=5)
        lo, hi = (int(x, 16) for x in fields[0].split('-'))
        maps.append(dict(start=lo, end=hi, permissions=fields[1], offset=int(fields[2], 16),
                         path=fields[5] if len(fields) > 5 else ''))
    samples = []
    for line in lines[si + 1:ki]:
        fields = line.split('\t')
        require(len(fields) == 6, 'Bad sample row')
        samples.append(dict(tid=int(fields[0]), mono=int(fields[1]), pc=int(fields[2], 16)))
    require(len(samples) == header['samples'] and samples and all(s['mono'] > 0 for s in samples),
            'Empty or incomplete sample rows')
    marks = []
    for line in lines[ki + 1:-1]:
        fields = list(map(int, line.split('\t')))
        require(len(fields) == 4 and fields[0] == len(marks), 'Bad phase marker')
        marks.append(dict(index=fields[0], tid=fields[1], mono=fields[2], cpu=fields[3]))
    require(all(x['mono'] < y['mono'] for x, y in zip(marks, marks[1:])), 'Unordered phase marks')
    segments = A.load_segments(binary)
    main_maps = [m for m in maps if m['path'] and Path(m['path']).resolve() == binary]

    def address(pc):
        for mapping in main_maps:
            if mapping['start'] <= pc < mapping['end']:
                return A.virtual_address(pc, mapping, segments)
        return None

    addresses = {v for s in samples if (v := address(s['pc'])) is not None}
    symbols = A.symbolize(binary, addresses)

    def describe(pc):
        virtual = address(pc)
        if virtual is not None:
            return symbols[virtual][0]['function']
        return next(('[outside] ' + m['path'] for m in maps if m['start'] <= pc < m['end']), '[unmapped]')

    first = min(s['mono'] for s in samples)
    bins = collections.defaultdict(collections.Counter)
    totals = collections.Counter()
    for sample in samples:
        name = describe(sample['pc'])
        totals[name] += 1
        bins[(sample['mono'] - first) // 10000000000][name] += 1

    def top(counter):
        return [dict(function=name, samples=count, percent=100 * count / sum(counter.values()))
                for name, count in counter.most_common(30)]

    report = dict(schema='phase89-stopped-physical-pc-v1', complete=True,
        diagnosticStopped=True, targetComplete=False, emittedCCorrectnessProved=False,
        header=header, rawMarks=marks, firstSampleMonotonicNs=first, sampleCount=len(samples),
        threadSampleCounts=dict(collections.Counter(s['tid'] for s in samples)),
        processCpuCoverageRatio=header['sampled_thread_cpu_ns'] / header['process_cpu_ns'],
        leafFunctions=top(totals), windows=[dict(startSeconds=10 * int(i), endSeconds=10 * int(i + 1),
            samples=sum(counter.values()), leafFunctions=top(counter)) for i, counter in sorted(bins.items())],
        identities={name: dict(file=str(getattr(a, name).resolve()), sha256=A.sha(getattr(a, name)))
                    for name in ['samples', 'binary', 'table', 'stderr', 'process']},
        limitations=['Intentional incomplete compiler request; no emitted-C correctness or speed result.',
            'Windows begin at first recorded sample, not at compiler-entry or a completed phase boundary.',
            'Raw IO.now marks are retained; no complete-request phase attribution is claimed.',
            'Physical leaf PCs only; musttail-erased Bend callers are not reconstructed.',
            'Watchdog exits from a non-main thread; final_tid need not equal initial tid.',
            'Coverage is reported for the captured prefix and is not full-request coverage.'])
    report['identities']['analyzer'] = dict(file=str(Path(__file__).resolve()), sha256=A.sha(__file__))
    with a.out.open('x') as stream:
        json.dump(report, stream, indent=2)
        stream.write('\n')
    print(json.dumps(dict(diagnosticStopped=True, samples=len(samples), windows=len(bins))))


if __name__ == '__main__':
    main()
