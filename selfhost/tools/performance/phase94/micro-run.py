#!/usr/bin/env python3
"""Serial native helper microbenchmarks; not end-to-end compiler measurements."""
import argparse, importlib.util, json, math, re, shutil, statistics, sys, time
from pathlib import Path
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
HERE = ROOT / 'selfhost/tools/performance/phase94'
spec = importlib.util.spec_from_file_location('program_support', HERE.parent/'programs/support.py')
S = importlib.util.module_from_spec(spec); spec.loader.exec_module(S)
CASES = [(16, 1, 1), (64, 0, 1), (256, 1, 0), (1024, 3, 1)]
ROLES = ['baseline', 'candidate']
LIMIT = 5_000_000

def oracle(size, mask, binding):
    rows = [v for v in range(size - 1, -1, -1) if mask & v == 0]
    live = mask & binding == 0
    acc = 7 if live else (31 * binding + 7) & 0xffffffff
    for value in rows + ([binding] if live else []):
        acc = (acc * 31 + value) & 0xffffffff
    return acc

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--products', type=Path, default=ROOT/'selfhost/build/phase94/micro03')
    p.add_argument('--scaling', action='store_true', help='Also run doubled counts on the first case')
    a = p.parse_args(); out = a.out.resolve(); products = a.products.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase94') and not out.exists()
    out.mkdir(parents=True)
    report = dict(complete=False, kind='phase94-helper-microbenchmark', started=time.time(), inputs=[],
                  scope='Native helper plus checksum fold; excludes setup/startup, includes timed checksum printing. No end-to-end compiler claim.',
                  targetMs=200, rounds=3, maxRepetitions=LIMIT, cases=[], records=[], scaling=[])
    pins = {}
    def bind(file, expected=None):
        got = S.identity(file)
        if expected:
            assert got['sha256'] == expected['sha256'] and got['bytes'] == expected['bytes'], str(file)
        pins[got['path']] = got; report['inputs'] = list(pins.values())
        return got
    def save(): S.save(out/'report.json', report)
    try:
        for file in [Path(__file__), HERE/'micro-template.bend', HERE/'acquire.mjs', HERE.parent/'programs/support.py']:
            bind(file)
        for role in ROLES:
            folder = products/role; acquisition = folder/'report.json'; bind(acquisition)
            receipt = json.loads(acquisition.read_text())
            assert receipt['complete'] and receipt['holes'] == 0
            for item in [receipt['source'], receipt['c'], receipt['method'], receipt['host'],
                         *receipt['loadedFiles'], *receipt['upstream']['inputs']]:
                bind(item['file'], item)
            assert Path(receipt['source']['file']).resolve() == products/(role+'.bend')
            assert Path(receipt['c']['file']).resolve() == folder/'program.c'
            bind(folder/'program')
        save()
        with S.ExecutionGuard(rss_mib=1024, available_mib=4096) as guard:
            def sample(case, role, n, stage, rnd=None):
                assert 1 <= n <= LIMIT and shutil.disk_usage(ROOT).free > 160*1024**2
                binary = products/role/'program'; assert S.identity(binary) == pins[str(binary)]
                directory = out/f'{len(report["records"]):03d}-{stage}-{role}'
                command = ['bash','-c','ulimit -f 65536; ulimit -c 0; exec "$@"','phase94',
                           'taskset','-c','3',str(binary),'--threads','1','--gpu','off','--',str(n),*map(str,case)]
                proc = guard.run(command, directory, time.monotonic()+15)
                row = dict(case=list(case), role=role, repetitions=n, stage=stage, round=rnd, process=proc,
                           directory=str(directory), correct=False, raw=[])
                report['records'].append(row)
                for name in ['process.json','stdout.log','stderr.log']:
                    if (directory/name).exists(): row['raw'].append(S.identity(directory/name))
                save()
                assert proc['complete'] and not proc.get('stoppedFor'), row
                stdout = (directory/'stdout.log').read_text(); stderr = (directory/'stderr.log').read_text()
                match = re.fullmatch(r'([0-9]+)\n([0-9]+)\n([0-9]+)\n', stdout)
                assert match and not stderr, (row, stdout, stderr)
                value, total, ms = map(int, match.groups()); expected = oracle(*case)
                row.update(checksum=value, total=total, elapsedMs=ms, expected=expected,
                           correct=value == expected and total == (expected*n)&0xffffffff)
                save(); assert row['correct'] and 0 <= ms <= proc['wallSeconds']*1000+2, row
                return row
            for index, case in enumerate(CASES):
                n = 1000
                for attempt in range(12):
                    trials = [sample(case, role, n, 'pilot' if attempt == 0 else 'calibrate') for role in ROLES]
                    fast = min(r['elapsedMs'] for r in trials)
                    if fast >= 200: break
                    assert n < LIMIT, ('Unmeasurable within repetition cap', case, trials)
                    n = min(LIMIT, max(n+1, min(n*16, math.ceil(n*250/max(1, fast)))))
                else: raise AssertionError(('Calibration exhausted', case))
                measured = []
                for rnd in range(3):
                    for role in ROLES if (index+rnd)%2 == 0 else ROLES[::-1]:
                        r = sample(case, role, n, 'measure', rnd+1); measured.append(r)
                        assert r['elapsedMs'] >= 200, ('Below 200ms; retain and recalibrate', r)
                stats = {}
                for role in ROLES:
                    values = [r['elapsedMs']*1000/n for r in measured if r['role'] == role]
                    stats[role] = dict(medianUs=statistics.median(values), minUs=min(values), maxUs=max(values))
                result = dict(args=list(case), repetitions=n, oracle=oracle(*case), roles=stats,
                              candidateOverBaseline=stats['candidate']['medianUs']/stats['baseline']['medianUs'])
                report['cases'].append(result); save(); print(json.dumps(result), flush=True)
                if a.scaling and index == 0:
                    assert 2*n <= LIMIT, 'Doubled-count scaling exceeds repetition cap'
                    for role in ROLES:
                        r = sample(case, role, 2*n, 'scaling')
                        ratio = r['elapsedMs']/(stats[role]['medianUs']*n/1000)
                        report['scaling'].append(dict(role=role, repetitions=2*n, elapsedMs=r['elapsedMs'], doubleCountRatio=ratio))
                        save(); assert 1.5 <= ratio <= 2.5, ('Work scaling needs investigation', role, ratio)
        for item in pins.values(): assert S.identity(item['path']) == item, item
        report.update(complete=True, inputsUnchanged=True)
    except BaseException as exc:
        report['error'] = repr(exc); raise
    finally:
        report['finished'] = time.time(); save()

if __name__ == '__main__': main()
