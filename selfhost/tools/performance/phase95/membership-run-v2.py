#!/usr/bin/env python3
"""Measure exact extracted membership helpers; independent repetition calibration."""
import argparse, importlib.util, json, math, statistics, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
HERE = ROOT / 'selfhost/tools/performance/phase95'
spec = importlib.util.spec_from_file_location('support', HERE.parent/'programs/support.py')
S = importlib.util.module_from_spec(spec); spec.loader.exec_module(S)
CASES = [(8, 0), (128, 0), (1024, 0), (128, 1), (128, 2), (128, 3)]
ROLES = ['baseline', 'candidate']
LIMIT = 20_000_000


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--products', type=Path, default=ROOT/'selfhost/build/phase95/membership03')
    a = p.parse_args(); out = a.out.resolve(); products = a.products.resolve()
    assert not out.exists(); out.mkdir(parents=True)
    report = dict(complete=False, cases=[], records=[], scaling=[], inputs=[],
                  scope='Extracted helper with shared roots; includes loop/checksum printing and final release, excludes input construction. Not compiler speed.',
                  targetMs=200, rounds=3, calibration='Independent repetitions per role, normalized by invocation count.')
    pins = {}
    def bind(path, expected=None):
        v = S.identity(path)
        if expected: assert all(v[k] == expected[k] for k in ['sha256', 'bytes'])
        pins[v['path']] = v; report['inputs'] = list(pins.values()); return v
    def save(): S.save(out/'report.json', report)
    try:
        for path in [Path(__file__), HERE/'acquire.mjs', HERE.parent/'programs/support.py']:
            bind(path)
        for role in ROLES:
            receipt = products/role/'report.json'; bind(receipt); d = json.loads(receipt.read_text())
            assert d['complete'] and d['holes'] == 0
            for v in [d['source'], d['c'], d['method'], d['host'], *d['loadedFiles'], *d['upstream']['inputs']]:
                bind(v['file'], v)
            assert Path(d['source']['file']) == HERE/'membership01/frozen03'/(role+'.bend')
            bind(products/role/'program')
        save()
        with S.ExecutionGuard(rss_mib=1024, available_mib=4096) as guard:
            def sample(case, role, repetitions, stage, rnd=None):
                binary = products/role/'program'; assert S.identity(binary) == pins[str(binary)]
                folder = out/f'{len(report["records"]):03d}-{stage}-{role}'
                cmd = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase95',
                       'taskset', '-c', '3', str(binary), '--threads', '1', '--gpu', 'off', '--',
                       str(repetitions), *map(str, case)]
                job = guard.run(cmd, folder, time.monotonic()+15)
                row = dict(case=list(case), role=role, repetitions=repetitions, stage=stage,
                           round=rnd, process=job, directory=str(folder), correct=False)
                report['records'].append(row); save()
                assert job['complete'] and not job.get('stoppedFor')
                lines = (folder/'stdout.log').read_text().splitlines()
                assert len(lines)==3 and all(x.isdigit() for x in lines) and not (folder/'stderr.log').read_bytes()
                value, total, ms = map(int, lines); expected = 53 if case[1]==2 or case[0]==0 else 97
                row.update(value=value, expected=expected, total=total, elapsedMs=ms,
                           correct=value==expected and total==(expected*repetitions)&0xffffffff)
                save(); assert row['correct'] and ms <= job['wallSeconds']*1000+2
                return row
            for index, case in enumerate(CASES):
                counts = {}
                for role in ROLES:
                    n = 100
                    for attempt in range(12):
                        row = sample(case, role, n, 'pilot' if attempt==0 else 'calibrate')
                        if row['elapsedMs'] >= 250: break
                        assert n < LIMIT
                        n = min(LIMIT, max(n+1, min(n*16, math.ceil(n*300/max(1,row['elapsedMs'])))))
                    else: raise AssertionError(('calibration exhausted',case,role))
                    counts[role] = n
                measured = []
                for rnd in range(3):
                    for role in ROLES if (rnd+index)%2==0 else ROLES[::-1]:
                        row = sample(case, role, counts[role], 'measure', rnd+1)
                        assert row['elapsedMs'] >= 200, ('below timer floor', row)
                        measured.append(row)
                stats = {}
                for role in ROLES:
                    values = [r['elapsedMs']*1000/r['repetitions'] for r in measured if r['role']==role]
                    stats[role] = dict(repetitions=counts[role], medianUs=statistics.median(values), minUs=min(values), maxUs=max(values))
                result = dict(args=list(case), roles=stats, candidateOverBaseline=stats['candidate']['medianUs']/stats['baseline']['medianUs'])
                report['cases'].append(result); save(); print(json.dumps(result), flush=True)
                if index==0:
                    for role in ROLES:
                        assert 2*counts[role] <= LIMIT
                        row = sample(case, role, 2*counts[role], 'scaling')
                        ratio = row['elapsedMs']/(stats[role]['medianUs']*counts[role]/1000)
                        report['scaling'].append(dict(role=role, doubleCountRatio=ratio)); save()
                        assert 1.5 <= ratio <= 2.5
        for v in pins.values(): assert S.identity(v['path']) == v
        report.update(complete=True, inputsUnchanged=True)
    except BaseException as error:
        report['error'] = repr(error); raise
    finally:
        save()


if __name__ == '__main__': main()
