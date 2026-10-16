#!/usr/bin/env python3
"""Serial saved-C experiment runner; reuse authenticated application fixtures."""
import argparse
import json
from pathlib import Path
import statistics
import sys
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/phase100'))
import run as R
ACQUISITIONS = dict(zip(R.APPS, ['source-acquire01', 'image-acquire01', 'dependency-acquire02']))


def preparation(path, options, out):
    module = R.module('p102_transform', path)
    files = sorted(p for p in path.parent.rglob('*') if p.is_file() and p.suffix in ('.py', '.c', '.json', '.bend'))
    pins = [R.pin(p) for p in files]
    for p in files:
        dest = out / 'method' / p.relative_to(path.parent)
        dest.parent.mkdir(parents=True, exist_ok=True); dest.write_bytes(p.read_bytes())
    return module, dict(entry=R.pin(path), options=options, inputs=pins)


def build(folder, c, context):
    binary = folder / 'candidate.program'; clang = context['clang']; R.verify(clang)
    job, child = R.guarded(folder / 'build', [clang['file'], '-isystem',
        str(Path(clang['file']).parents[1] / 'include/clang'), '-std=c11', '-O3',
        str(c), '-o', str(binary), '-lpthread', '-lm'])
    return dict(c=R.pin(c), binary=R.pin(binary), build=job,
                buildSeconds=child['processSeconds'], buildRssKiB=child['maxRssKiB'])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--transform', type=Path, required=True)
    p.add_argument('--options', default='{}')
    p.add_argument('--apps', default=','.join(R.APPS))
    p.add_argument('--fixtures', type=Path, nargs='+', required=True)
    p.add_argument('--cases', default='')
    p.add_argument('--rounds', type=int, default=4)
    p.add_argument('--threads', default='1')
    p.add_argument('--reuse', type=Path)
    a = p.parse_args(); assert 1 <= a.rounds <= 12
    out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    module, prepared = preparation(a.transform.resolve(), json.loads(a.options), out)
    report = dict(complete=False, started=time.time(), method=R.pin(__file__), preparation=prepared,
                  products={}, cases=[], records=[], summary=[],
                  scope='Saved installed-B2 C intervention; not a compiler image or release.')
    (out / 'snapshot-run.py').write_bytes(Path(__file__).read_bytes())
    def save(): R.save(out / 'report.json', report)
    save()
    try:
        cases = {}
        report['fixtures'] = [R.pin(path) for path in a.fixtures]
        for path in a.fixtures:
            f = R.read(path); assert f['complete'] and all(r['passed'] for r in f['records'])
            for c in f['cases']:
                if c['app'] not in a.apps.split(',') or (a.cases and c['id'] not in a.cases.split(',')): continue
                for item in [c['expected'], *c['inputs']]: R.verify(item)
                key = c['app'], c['id']
                if key in cases: assert c['expected']['sha256'] == cases[key]['expected']['sha256']
                cases[key] = c
        assert cases
        if a.cases: assert set(a.cases.split(',')) == {c['id'] for c in cases.values()}
        old = R.read(a.reuse) if a.reuse else None
        if old:
            assert old['complete'] and old['preparation'] == prepared
            report['reuse'] = R.pin(a.reuse)
        for app in a.apps.split(','):
            if not any(key[0] == app for key in cases): continue
            acquired_path = ROOT / 'selfhost/build/phase100' / ACQUISITIONS[app] / 'report.json'
            acquired = R.read(acquired_path); assert acquired['complete']
            original = next(v for v in acquired['apps'] if v['id'] == app)
            R.verify(original['source'])
            for product in original['products'].values():
                R.verify(product['c']); R.verify(product['binary'])
            directory = out / app; directory.mkdir()
            own = original['products']['b2']
            if old:
                assert old['products'][app]['baseline']['c'] == own['c']
                product = old['products'][app]['candidate']
                R.verify(product['c']); R.verify(product['binary'])
            else:
                code, rewrites = module.transform(Path(own['c']['file']).read_text(), **prepared['options'])
                c = directory / 'candidate.c'; c.write_text(code)
                report['products'][app] = dict(candidate=dict(c=R.pin(c), rewrites=rewrites)); save()
                product = build(directory, c, acquired['context']); product['rewrites'] = rewrites
            report['products'][app] = dict(acquired=R.pin(acquired_path), source=original['source'],
                baseline=own, upstream=original['products']['upstream'], candidate=product)
            save()
        for (app, cid), case in cases.items():
            report['cases'].append(case); save()
            expected = Path(case['expected']['file']).read_bytes()
            workers = a.threads.split(',') if case.get('parallel') else ['1']
            for threads in workers:
                cpu = {'1':'3', '2':'2,3', '4':'0,1,2,3'}[threads]
                for rnd in range(a.rounds):
                    roles = ['baseline', 'candidate', 'upstream']
                    if rnd % 2: roles.reverse()
                    for role in roles:
                        label = f'{app}-{cid}-t{threads}-r{rnd}-{role}'; folder = out / label
                        binary = report['products'][app][role]['binary']; R.verify(binary)
                        record = dict(app=app, case=cid, threads=int(threads), round=rnd, role=role, passed=False)
                        report['records'].append(record); save()
                        record['job'], child = R.guarded(folder, [binary['file'], '--threads', threads,
                            '--gpu', 'off', '--', *case['argv']], seconds=30, cpu=cpu)
                        record.update(seconds=child['processSeconds'], rssKiB=child['maxRssKiB'],
                            stdout=R.pin(folder/'stdout.log'), stderr=R.pin(folder/'stderr.log'))
                        record['passed'] = (folder/'stdout.log').read_bytes() == expected and not child['stderr']
                        save(); assert record['passed'], label
                records = [r for r in report['records'] if (r['app'],r['case'],r['threads']) == (app,cid,int(threads))]
                medians = {role: statistics.median(r['seconds'] for r in records if r['role']==role) for role in roles}
                memory = {role: statistics.median(r['rssKiB'] for r in records if r['role']==role) for role in roles}
                summary = dict(app=app, case=cid, threads=int(threads), medians=medians, rssKiB=memory,
                    candidateOverBaseline=medians['candidate']/medians['baseline'],
                    candidateOverUpstream=medians['candidate']/medians['upstream'])
                report['summary'].append(summary); save(); print(json.dumps(summary), flush=True)
        for case in cases.values():
            for item in [case['expected'], *case['inputs']]: R.verify(item)
        for item in [report['method'], *prepared['inputs'], *report['fixtures']]: R.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error); raise
    finally:
        report['finished'] = time.time(); save()


if __name__ == '__main__': main()
