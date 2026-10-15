#!/usr/bin/env python3
"""Offline sampler binding and strict complete-request ownership windows."""
import argparse
import collections
import importlib.util
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
METHOD = ROOT / 'selfhost/tools/performance/phase88/ownership/analyze.py'
spec = importlib.util.spec_from_file_location('ownership', METHOD)
M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)
A = M.A


def pin(path):
    path = Path(path).resolve()
    return dict(file=str(path), bytes=path.stat().st_size, sha256=A.sha(path))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--preparation', type=Path, required=True)
    p.add_argument('--bind-sampler', action='store_true')
    p.add_argument('--binding', type=Path)
    p.add_argument('--analysis', type=Path)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); assert not a.out.exists()
    prep = json.loads(a.preparation.read_text())
    assert prep['complete'] and not prep['targetsRun']
    for item in prep['inputs']: assert pin(item['file']) == item
    table = json.loads(Path(prep['table']['file']).read_text())
    assert table['binary_sha256'] == prep['image']['sha256']
    assert table['header_sha256'] == prep['header']['sha256']
    build_path = Path(prep['samplerBuildGuard']) / 'process.json'
    build = json.loads(build_path.read_text())
    assert build['complete'] and build['returncode'] == 0 and not build.get('stoppedFor')
    build_command = prep['commands']['buildSampler']
    build_target = build_command[build_command.index('--') + 1:]
    assert build['command'][-len(build_target):] == build_target
    sampler = pin(prep['samplerPath'])
    if a.bind_sampler:
        assert a.binding is None and a.analysis is None
        report = dict(kind='phase98-origin-b1-sampler-binding', complete=True, targetsRun=False,
                      preparation=pin(a.preparation), method=pin(__file__), sampler=sampler,
                      buildGuard=pin(build_path), image=prep['image'], table=prep['table'], header=prep['header'])
    else:
        assert a.binding and a.analysis
        binding = json.loads(a.binding.read_text())
        assert binding['complete'] and binding['preparation'] == pin(a.preparation)
        assert binding['method'] == pin(__file__) and binding['sampler'] == sampler
        assert binding['buildGuard'] == pin(build_path)
        capture = Path(prep['captureDirectory']); process_path = capture / 'guard/process.json'
        process = json.loads(process_path.read_text())
        assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor')
        assert not process.get('interrupted') and not process.get('error')
        capture_command = prep['commands']['capture']
        target = capture_command[capture_command.index('--') + 1:]
        assert process['command'][-len(target):] == target
        output = pin(capture / 'program.1.c')
        assert all(output[k] == prep['oracle']['c'][k] for k in ['bytes', 'sha256'])
        stderr_path = capture / 'guard/stderr.log'; stderr = stderr_path.read_text()
        # Exact existing qualification/support.py strip_clocks expression.
        clock_line = r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n'
        assert re.sub(clock_line, '', stderr, flags=re.M) == Path(prep['oracle']['diagnostic']['file']).read_text()
        assert not (capture / 'guard/stdout.log').read_bytes()
        samples_path = capture / 'samples.txt'; binary = Path(prep['image']['file'])
        analysis = json.loads(a.analysis.read_text())
        expected_ids = dict(binary_sha256=A.sha(binary), samples_sha256=A.sha(samples_path),
                            table_sha256=A.sha(prep['table']['file']), stderr_sha256=A.sha(stderr_path),
                            analyzer_sha256=A.sha(METHOD))
        assert analysis['schema'] == 'phase88-ownership-analysis-v1' and analysis['identities'] == expected_ids
        header, mappings, samples, marks = M.read_samples(samples_path)
        assert analysis['header'] == header and analysis['marks'] == marks
        assert all(header[k] == 0 for k in ['overruns', 'dropped', 'thread_overflow', 'thread_clock_failures', 'timer_disarm_failures'])
        assert header['threads_allocated'] == header['threads_ready']
        assert 0 <= header['threads_ended'] <= header['threads_ready']
        assert header['target_sha256'] == table['binary_sha256'] == prep['image']['sha256']
        assert Path(header['exe']).resolve() == binary and header['period_us'] == prep['periodUs']
        coverage = A.coverage_summary(header)
        assert coverage == analysis['coverage'] and coverage['usable_for_process_cpu_attribution']
        phases = M.make_phases(marks, stderr)
        request = [phase for phase in phases if phase['name'].startswith('request-')]
        assert len(request) == 1 and request[0]['name'] == 'request-1'
        request = request[0]
        selected = [s for s in samples if request['start_ns'] <= s['mono'] < request['end_ns']]
        accepted_phase = next(x for x in analysis['phases'] if x['name'] == 'request-1')
        assert len(selected) == accepted_phase['samples']
        segments = A.load_segments(binary)
        mappings = [m for m in mappings if m['path'] and Path(m['path']).resolve() == binary]

        def address(pc):
            for mapping in mappings:
                if mapping['start'] <= pc < mapping['end']:
                    return A.virtual_address(pc, mapping, segments)
            return None

        addresses = {v for s in selected for pc in [s['pc'], *(r - 1 for r in s['callers'])]
                     if (v := address(pc)) is not None}
        symbols = A.symbolize(binary, addresses)

        def name(pc):
            return symbols.get(address(pc), [dict(function='[outside]')])[0]['function']

        bins = collections.defaultdict(lambda: dict(leaf=collections.Counter(), owners=collections.Counter(), sites=collections.Counter()))
        for sample in selected:
            bucket = bins[(sample['mono'] - request['start_ns']) // 30000000000]
            leaf = name(sample['pc']); bucket['leaf'][leaf] += 1
            if leaf in M.OWNERSHIP:
                chain = [(name(pc - 1), address(pc - 1)) for pc in sample['callers']]
                resolved = bool(chain and chain[-1][0] not in M.OWNERSHIP and not chain[-1][0].startswith('['))
                owner = chain[-1][0] if resolved else '[unresolved physical owner]'
                bucket['owners'][leaf, owner] += 1
                bucket['sites'][leaf, tuple(chain)] += 1
        windows = []
        for index, bucket in sorted(bins.items()):
            count = sum(bucket['leaf'].values())
            windows.append(dict(startRequestWallSeconds=index * 30,
                endRequestWallSeconds=min((index + 1) * 30, request['wall_ms'] / 1000), samples=count,
                precision='low sample count' if count < 200 else 'sampling estimate',
                leaves=[dict(function=f, samples=n, percent=100*n/count) for f, n in bucket['leaf'].most_common()],
                ownershipCallers=[dict(leaf=k[0], physicalOwner=k[1], samples=n, percentWindow=100*n/count) for k, n in bucket['owners'].most_common()],
                ownershipReturnSites=[dict(leaf=k[0], chain=[dict(function=f, address=hex(addr) if addr is not None else None) for f, addr in k[1]], samples=n) for k, n in bucket['sites'].most_common()]))
        assert sum(x['samples'] for x in windows) == len(selected)
        for item in prep['inputs']: assert pin(item['file']) == item
        assert pin(prep['samplerPath']) == sampler
        report = dict(kind='phase98-origin-b1-complete-request-windows', complete=True, targetsRun=False,
                      targetComplete=True, fullCExact=True, diagnosticExact=True, zeroLoss=True,
                      preparation=pin(a.preparation), binding=pin(a.binding), analysis=pin(a.analysis), method=pin(__file__),
                      process=pin(process_path), samples=pin(samples_path), output=output, request=request,
                      requestSamples=len(selected), coverage=coverage, windows=windows,
                      limitations=['Derived from Phase90 windows aggregation with the unchanged Phase88 full-capture reader, coverage and symbolizer.',
                                   'Windows begin at the validated request IO.now mark and exclude Base, runtime setup and output writing.',
                                   'Thirty-second wall windows are not compiler-stage boundaries; the last window is clipped to request completion.',
                                   'Physical ownership callers only; musttail-eliminated ancestors and inline operations are not reconstructed.',
                                   'Profiler clocks are diagnostic, not speed estimates. This capture alone cannot quantify a causal B1/B2 speed difference.'])
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, kind=report['kind'], out=str(a.out))))


if __name__ == '__main__': main()
