#!/usr/bin/env python3
"""Offline, exclusive physical ownership totals and ten-second request windows."""
import argparse, collections, importlib.util, json, pathlib, sys
sys.dont_write_bytecode = True
ROOT = pathlib.Path(__file__).resolve().parents[4]
METHOD = ROOT / 'selfhost/tools/performance/phase88/ownership/analyze.py'
spec = importlib.util.spec_from_file_location('ownership', METHOD)
O = importlib.util.module_from_spec(spec); spec.loader.exec_module(O)
A = O.A


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--capture', type=pathlib.Path, required=True)
    p.add_argument('--out', type=pathlib.Path, required=True)
    a = p.parse_args(); capture = a.capture.resolve()
    assert not a.out.exists(), 'Preserve earlier analysis'
    report = json.loads((capture / 'report.json').read_bytes())
    assert all(report[k] for k in ['complete', 'compilationPassed', 'diagnosticUsable', 'inputsUnchanged'])
    assert report['samplingLossFree'] and report['analyzerAccepted'] and report['role'] == 'b1'
    prior = json.loads((capture / 'analysis.json').read_bytes())
    header, maps, samples, marks = O.read_samples(capture / 'samples.txt')
    assert all(header[k] == 0 for k in ['overruns', 'dropped', 'thread_overflow',
        'thread_clock_failures', 'timer_disarm_failures'])
    assert prior['header'] == header
    binary = pathlib.Path(report['context']['roles']['b1']['admission']['binary']['file'])
    assert A.sha(binary) == prior['identities']['binary_sha256'] == header['target_sha256']
    assert A.sha(capture / 'samples.txt') == prior['identities']['samples_sha256']
    assert A.sha(capture / 'analysis.json') == report['analysis']['sha256']
    segments = A.load_segments(binary)
    mappings = [m for m in maps if m['path'] and pathlib.Path(m['path']).resolve() == binary]
    def address(pc):
        return next((A.virtual_address(pc, m, segments) for m in mappings if m['start'] <= pc < m['end']), None)
    addresses = {v for s in samples for pc in [s['pc'], *[r - 1 for r in s['callers']]]
                 if (v := address(pc)) is not None}
    symbols = A.symbolize(binary, addresses)
    def function(pc): return symbols.get(address(pc), [dict(function='[outside]')])[0]['function']
    phase_rows = [r for r in prior['phases'] if r['name'].startswith('request-')]
    rows = []
    for s in samples:
        phase = next((r for r in phase_rows if r['start_ns'] <= s['mono'] < r['end_ns']), None)
        if not phase: continue
        leaf = function(s['pc']); chain = [(function(r - 1), address(r - 1)) for r in s['callers']]
        owner = None
        if leaf in O.OWNERSHIP:
            owner = chain[-1][0] if chain and chain[-1][0] not in O.OWNERSHIP and not chain[-1][0].startswith('[') else '[unresolved]'
        rows.append(dict(phase=phase['name'], window=(s['mono'] - phase['start_ns']) // 10**10,
                         leaf=leaf, owner=owner, chain=tuple(chain)))
    families = {'nb_contains': 'WL_FID_NB_CONTAINS', 'has_name': 'WL_FID_HAS_NAME',
        'nt_choose': 'WL_FID_NT_CHOOSE', 'kc': 'WL_FID_KC', 'tg': 'spin_1',
        'ks': 'spin_33', 'p88_string_eq': 'spin_2'}
    def summarize(selected):
        leaf = collections.Counter(r['leaf'] for r in selected)
        owner = collections.Counter(r['owner'] for r in selected if r['owner'])
        sites = collections.Counter((r['leaf'], r['chain']) for r in selected if r['owner'])
        n = len(selected)
        def ranked(counter):
            return [dict(function=k, samples=v, percent=100 * v / n) for k, v in counter.most_common()]
        helpers = {}
        for name, symbol in families.items():
            matches = lambda k: k == symbol or (symbol.startswith('WL_') and k.startswith(symbol + '_'))
            direct = sum(v for k, v in leaf.items() if matches(k))
            cleanup = sum(v for k, v in owner.items() if matches(k))
            helpers[name] = dict(physicalLeafSamples=direct, physicalCleanupSamples=cleanup,
                                 combinedExclusiveSamples=direct + cleanup)
        return dict(samples=n, ownershipSamples=sum(owner.values()),
            ownershipRecovered=sum(v for k, v in owner.items() if k != '[unresolved]'),
            leaf=ranked(leaf), physicalOwners=ranked(owner), helpers=helpers,
            returnSites=[dict(leaf=k[0], chain=[dict(function=f, address=hex(addr) if addr is not None else None)
                for f, addr in k[1]], samples=v) for k, v in sites.most_common()])
    phases = []
    for phase in phase_rows:
        selected = [r for r in rows if r['phase'] == phase['name']]
        summary = summarize(selected)
        assert summary['samples'] == phase['samples'] and summary['ownershipSamples'] == phase['ownership_samples']
        windows = [dict(startSeconds=10 * i, endSeconds=min(10 * (i + 1),
            (phase['end_ns'] - phase['start_ns']) / 1e9), **summarize([r for r in selected if r['window'] == i]))
            for i in sorted({r['window'] for r in selected})]
        phases.append(dict(name=phase['name'], reportedMs=phase['reported_ms'], **summary, windows=windows))
    build = json.loads(pathlib.Path(report['context']['build']['file']).read_bytes())
    c_file, bend_file = (pathlib.Path(build[k]['file']) for k in ['c', 'source'])
    assert all(A.sha(pathlib.Path(build[k]['file'])) == build[k]['sha256'] for k in ['c', 'source'])
    c_lines, bend_lines = c_file.read_text().splitlines(), bend_file.read_text().splitlines()
    mapping = {}
    for name, symbol in families.items():
        needle = 'INLINE Term ' + symbol + '(' if symbol.startswith('spin_') else 'WL_CASE(' + symbol[3:] + ')'
        c_line = next(i for i, line in enumerate(c_lines, 1) if line.strip().startswith(needle))
        bend_line = next(i for i, line in enumerate(bend_lines, 1) if line.startswith('def ' + name + '('))
        mapping[name] = dict(symbol=symbol, cLine=c_line, bendLine=bend_line)
    files = [capture / x for x in ['report.json', 'analysis.json', 'samples.txt', 'guard/process.json', 'guard/stderr.log']]
    files += [pathlib.Path(__file__), METHOD, A.__file__, binary, c_file, bend_file]
    result = dict(schema='phase95-exclusive-physical-callers-v1', qualifiedCapture=True,
        periodUs=header['period_us'], allRequestPhases=summarize(rows), phases=phases,
        sourceMapping=mapping, identities=[dict(file=str(pathlib.Path(f).resolve()), sha256=A.sha(f)) for f in files],
        limitations=['Only this completed loss-free capture; sample counts are not invocation/allocation counts.',
            'Physical cleanup samples belong to exactly one nearest recovered owner; no nested inclusive sums.',
            'The combined helper counts add disjoint own-leaf and attributed-cleanup samples only.',
            'Musttail-erased logical callers cannot be inferred from a shared helper such as spin_2.',
            'Ten-second bins begin at the existing request clock mark; they are not compiler stage boundaries.',
            'spin_1/2/33 mappings are specific to this exact generated C: tg/string equality/ks.',
            'All sample fractions include profiler overhead; no optimization speed estimate follows.'])
    with a.out.open('x') as stream: json.dump(result, stream, indent=2); stream.write('\n')
    print(json.dumps(dict(requestSamples=len(rows), physicalCleanupSamples=result['allRequestPhases']['ownershipSamples'], out=str(a.out))))


if __name__ == '__main__': main()
