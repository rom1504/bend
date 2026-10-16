#!/usr/bin/env python3
"""Serial general chunk-String intervention and complete application comparison."""
import argparse
from collections import defaultdict
from pathlib import Path
import statistics
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R
P = R.module('p101_prepare', Path(__file__).with_name('prepare.py'))
ACQUISITIONS = dict(zip(R.APPS, ['source-acquire01', 'image-acquire01', 'dependency-acquire02']))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--apps', default=','.join(R.APPS))
    p.add_argument('--fixtures', type=Path, nargs='+', required=True)
    p.add_argument('--cases', default='')
    p.add_argument('--rounds', type=int, default=4)
    p.add_argument('--threads', default='1')
    p.add_argument('--mode', choices=['input', 'cons', 'all'], default='all')
    p.add_argument('--reuse', type=Path)
    p.add_argument('--append', action='store_true')
    p.add_argument('--compare', action='store_true')
    p.add_argument('--chunk-class', type=int, default=6, choices=range(3, 11))
    a = p.parse_args()
    assert 1 <= a.rounds <= 12
    out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    report = dict(complete=False, started=time.time(), method=R.pin(__file__),
                  preparation=R.pin(P.__file__), runtime=R.pin(Path(__file__).with_name('chunk-runtime.c')),
                  mode=a.mode, append=a.append, compare=a.compare, chunkClass=a.chunk_class, products={}, cases=[], records=[], summary=[],
                  scope='General generated-C intervention on installed-B2 output. No new compiler image or release.')
    def save(): R.save(out / 'report.json', report)
    report['appendRuntime'] = R.pin(Path(__file__).with_name('chunk-append.c'))
    report['compareRuntime'] = R.pin(Path(__file__).with_name('chunk-compare.c'))
    for item in [report['method'], report['preparation'], report['runtime'], report['appendRuntime'], report['compareRuntime']]:
        (out / ('snapshot-' + Path(item['file']).name)).write_bytes(Path(item['file']).read_bytes())
    save()
    try:
        cases = {}
        report['fixtures'] = [R.pin(path) for path in a.fixtures]
        for path in a.fixtures:
            f = R.read(path); assert f['complete'] and all(row['passed'] for row in f['records'])
            for c in f['cases']:
                if c['app'] in a.apps.split(',') and (not a.cases or c['id'] in a.cases.split(',')):
                    for item in [c['expected'], *c['inputs']]: R.verify(item)
                    key = c['app'], c['id']
                    if key in cases:
                        assert c['expected']['sha256'] == cases[key]['expected']['sha256']
                    cases[key] = c
        assert cases
        if a.cases: assert set(a.cases.split(',')) == {c['id'] for c in cases.values()}
        old = R.read(a.reuse) if a.reuse else None
        if old:
            assert old['complete'] and old['mode'] == a.mode and old['chunkClass'] == a.chunk_class
            assert old.get('append', False) == a.append and old['appendRuntime'] == report['appendRuntime']
            assert old.get('compare', False) == a.compare and old['compareRuntime'] == report['compareRuntime']
            assert old['runtime'] == report['runtime'] and old['preparation'] == report['preparation']
            report['reuse'] = R.pin(a.reuse)
        for app in a.apps.split(','):
            acquired_path = ROOT / 'selfhost/build/phase100' / ACQUISITIONS[app] / 'report.json'
            acquired = R.read(acquired_path); assert acquired['complete']
            original = next(v for v in acquired['apps'] if v['id'] == app)
            R.verify(original['source'])
            for product in original['products'].values():
                R.verify(product['c']); R.verify(product['binary'])
            directory = out / app; directory.mkdir()
            own = original['products']['b2']
            if old:
                product = old['products'][app]['candidate']
                R.verify(product['c']); R.verify(product['binary'])
            else:
                code, rewrites = P.transform(Path(own['c']['file']).read_text(), a.mode, a.append, a.compare)
                c = directory / 'candidate.c'; c.write_text(code)
                binary = directory / 'candidate.program'
                clang = acquired['context']['clang']; R.verify(clang)
                product = dict(c=R.pin(c), rewrites=rewrites)
                report['products'][app] = dict(candidate=product)
                save()
                product['build'], _ = R.guarded(directory / 'build', [clang['file'],
                    '-isystem', str(Path(clang['file']).parents[1] / 'include/clang'),
                    '-std=c11', '-O3', '-DP101_CHUNK_CLASS=' + str(a.chunk_class), str(c),
                    '-o', str(binary), '-lpthread', '-lm'])
                product['binary'] = R.pin(binary)
            report['products'][app] = dict(acquired=R.pin(acquired_path), source=original['source'],
                baseline=own, upstream=original['products']['upstream'], candidate=product)
            save()
        for (app, cid), case in cases.items():
            report['cases'].append(case); save()
            expected = Path(case['expected']['file']).read_bytes()
            workers = a.threads.split(',') if case.get('parallel') else ['1']
            for threads in workers:
                cpu = {'1': '3', '2': '2,3', '4': '0,1,2,3'}[threads]
                for rnd in range(a.rounds):
                    roles = ['baseline', 'candidate', 'upstream']
                    if rnd % 2: roles.reverse()
                    for role in roles:
                        label = f'{app}-{cid}-t{threads}-r{rnd}-{role}'
                        folder = out / label
                        binary = report['products'][app][role]['binary']; R.verify(binary)
                        record = dict(app=app, case=cid, threads=int(threads), round=rnd, role=role, passed=False)
                        report['records'].append(record); save()
                        record['job'], child = R.guarded(folder, [binary['file'], '--threads', threads,
                            '--gpu', 'off', '--', *case['argv']], seconds=30, cpu=cpu)
                        record.update(seconds=child['processSeconds'], rssKiB=child['maxRssKiB'],
                                      stdout=R.pin(folder / 'stdout.log'), stderr=R.pin(folder / 'stderr.log'))
                        record['passed'] = (folder / 'stdout.log').read_bytes() == expected and not child['stderr']
                        save(); assert record['passed'], label
                records = [r for r in report['records'] if (r['app'],r['case'],r['threads']) == (app,cid,int(threads))]
                medians = {role: statistics.median(r['seconds'] for r in records if r['role'] == role) for role in roles}
                memory = {role: statistics.median(r['rssKiB'] for r in records if r['role'] == role) for role in roles}
                summary = dict(app=app, case=cid, threads=int(threads), medians=medians, rssKiB=memory,
                    candidateOverBaseline=medians['candidate']/medians['baseline'],
                    candidateOverUpstream=medians['candidate']/medians['upstream'])
                report['summary'].append(summary); save(); print(R.json.dumps(summary), flush=True)
        for case in cases.values():
            for item in [case['expected'], *case['inputs']]: R.verify(item)
        for item in [report['method'], report['preparation'], report['runtime'], report['appendRuntime'], report['compareRuntime'], *report['fixtures']]: R.verify(item)
        report['complete'] = True
    except BaseException as e:
        report['error'] = repr(e); raise
    finally:
        report['finished'] = time.time(); save()


if __name__ == '__main__': main()
