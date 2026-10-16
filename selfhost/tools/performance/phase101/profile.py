#!/usr/bin/env python3
"""Root-only native app CPU profiles; unchanged ELF, frozen full-output oracle."""
import argparse
import collections
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PERF = ROOT / 'selfhost/tools/performance'
sys.path.insert(0, str(PERF / 'phase100'))
import run as R

ANALYSIS = PERF / 'phase68/parity-survey/sample-analysis-v2.py'
SAMPLER = PERF / 'phase68/parity-survey/sample-preload-threads.c'
A = R.module('phase101_sample_analysis', ANALYSIS)


def decode(name):
    """Decode byte-number C identifiers without changing the raw symbol evidence."""
    def replace(match):
        try:
            return ''.join(chr(int(n)) for n in match[0].strip('_').split('_'))
        except (ValueError, OverflowError):
            return match[0]
    return re.sub(r'(?:\d+_){3,}', replace, name)


def ranked(counter, total):
    return [dict(name=name, decoded=decode(name), samples=count,
                 percent=100 * count / total)
            for name, count in counter.most_common()]


def analyze(path, binary):
    header, maps, pcs = A.parse(path)
    assert Path(header['exe']).resolve() == Path(binary['file'])
    assert header['overruns'] == 0, 'Timer overruns: retain as exploratory, retry a slower period'
    coverage = A.coverage_summary(header)
    assert coverage['near_complete_process_cpu_coverage'], coverage
    segments = A.load_segments(binary['file'])
    rows, addresses = [], set()
    for pc, count in pcs.items():
        mapping = next((m for m in maps if m['start'] <= pc < m['end']), None)
        address = (A.virtual_address(pc, mapping, segments)
                   if mapping and mapping['path'] == header['exe'] else None)
        if address is not None:
            addresses.add(address)
        rows.append(dict(pc=hex(pc), address=address, samples=count,
                         mapping=mapping['path'] if mapping else '<unmapped>'))
    symbols = A.symbolize(binary['file'], addresses)
    counts = collections.Counter()
    for row in rows:
        if row['address'] is not None:
            frames = symbols[row['address']]
            name = frames[0]['function'] if frames else '??'
            row.update(symbol=name, frames=frames)
        else:
            name = '<mapping:' + row['mapping'] + '>'
        counts[name] += row['samples']
    return dict(header=header, coverage=coverage, leaves=ranked(counts, header['samples']),
                pcs=rows), counts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--app', choices=R.APPS, required=True)
    parser.add_argument('--acquired', type=Path, required=True)
    parser.add_argument('--fixtures', type=Path, required=True)
    parser.add_argument('--case', required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--roles', default='b2')
    parser.add_argument('--periods', default='8000,13000')
    parser.add_argument('--rounds', type=int, default=12)
    parser.add_argument('--minimum-samples', type=int, default=300)
    args = parser.parse_args()
    roles, periods = args.roles.split(','), list(map(int, args.periods.split(',')))
    assert set(roles) <= {'b2', 'upstream'} and len(set(roles)) == len(roles)
    assert 1 <= args.rounds <= 40 and args.minimum_samples >= 100
    assert periods and len(set(periods)) == len(periods) and all(250 <= p <= 100000 for p in periods)
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase101')
    out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='phase101-unchanged-app-profile', complete=False, started=time.time(),
                  records=[], summaries=[], scope='Physical sampled instruction, all created threads; '
                  'one runtime worker. Startup, IO and shutdown included. No dynamic call stack, '
                  'allocation census or source-line attribution. Profile clocks are not speed measurements.')
    R.save(out / 'report.json', report)
    try:
        acquired, fixtures = R.read(args.acquired), R.read(args.fixtures)
        assert acquired['complete'] and fixtures['complete']
        assert fixtures['kind'] == 'phase100-applications-measure'
        assert all(r['passed'] for r in fixtures['records'])
        apps = [a for a in acquired['apps'] if a['id'] == args.app]
        cases = [c for c in fixtures['cases'] if c['app'] == args.app and c['id'] == args.case]
        assert len(apps) == len(cases) == 1
        app, case = apps[0], cases[0]
        assert app['complete'] and app['sameNativeC']
        # Bind the frozen oracle to the same exact acquisition, rather than merely
        # accepting another successful run with a coincidentally identical case ID.
        acquisition = R.pin(args.acquired)
        assert acquisition in (fixtures['acquired'] if isinstance(fixtures['acquired'], list) else [fixtures['acquired']])
        clang = acquired['context']['clang']
        pins = [R.pin(__file__), R.pin(R.__file__), R.pin(ANALYSIS), R.pin(SAMPLER),
                acquisition, R.pin(args.fixtures), app['source'], case['expected'],
                *case['inputs'], clang, R.pin(shutil.which('readelf')),
                R.pin(shutil.which('addr2line')), R.pin(PERF / 'phase86/guard.py'),
                R.pin(PERF / 'phase46/execute.py')]
        for role in roles:
            pins += [app['products'][role]['binary'], app['products'][role]['c']]
        for item in pins:
            R.verify(item)
        report.update(inputs=pins, app=args.app, case=case, rounds=args.rounds,
                      periodsUs=periods, roles=roles, minimumPooledSamples=args.minimum_samples)
        R.save(out / 'report.json', report)
        library = out / 'sampler.so'
        report['samplerBuild'], _ = R.guarded(out / 'sampler-build', [clang['file'],
            '-isystem', str(Path(clang['file']).parents[1] / 'include/clang'),
            '-O2', '-Wall', '-Wextra', '-Werror', '-fPIC', '-shared', str(SAMPLER),
            '-o', str(library), '-pthread', '-ldl', '-lrt'])
        report['sampler'] = R.pin(library)
        expected = Path(case['expected']['file']).read_text()
        buckets = collections.defaultdict(collections.Counter)
        for period in periods:
            for rnd in range(args.rounds):
                for role in (roles if rnd % 2 == 0 else list(reversed(roles))):
                    binary = app['products'][role]['binary']
                    label = f'{role}-p{period}-r{rnd}'
                    samples = out / (label + '.samples')
                    argv = ['env', 'LD_PRELOAD=' + str(library),
                            'BEND_SAMPLE_OUT=' + str(samples), 'BEND_SAMPLE_PERIOD_US=' + str(period),
                            binary['file'], '--threads', '1', '--gpu', 'off', '--', *case['argv']]
                    row = dict(role=role, periodUs=period, round=rnd, binary=binary, complete=False)
                    report['records'].append(row)
                    R.save(out / 'report.json', report)
                    row['job'], child = R.guarded(out / label, argv, seconds=30, cpu='3')
                    row['outputCorrect'] = child['stdout'] == expected and not child['stderr']
                    assert row['outputCorrect'], 'Frozen full-output oracle mismatch'
                    row['samples'] = R.pin(samples)
                    data, counts = analyze(samples, binary)
                    destination = out / (label + '-analysis.json')
                    R.save(destination, data)
                    row.update(analysis=R.pin(destination), sampleCount=data['header']['samples'],
                               coverage=data['coverage'], complete=True)
                    buckets[(role, period)].update(counts)
                    buckets[(role, 'all')].update(counts)
                    R.save(out / 'report.json', report)
                    print(R.json.dumps(dict(role=role, periodUs=period, round=rnd,
                                            samples=row['sampleCount'], correct=True)), flush=True)
        for (role, period), counts in buckets.items():
            total = sum(counts.values())
            report['summaries'].append(dict(role=role, periodUs=period, samples=total,
                                            leaves=ranked(counts, total)))
            if period == 'all':
                assert total >= args.minimum_samples, (role, 'Insufficient pooled samples', total)
        for item in pins + [report['sampler']]:
            R.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['finished'] = time.time()
        R.save(out / 'report.json', report)


if __name__ == '__main__':
    main()
