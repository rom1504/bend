#!/usr/bin/env python3
"""Alternate two already-built candidates on identical full-output fixtures."""
import argparse
from pathlib import Path
import statistics
import sys
import time
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/performance/phase100'))
import run as R


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--a', type=Path, required=True)
    p.add_argument('--b', type=Path, required=True)
    p.add_argument('--cases', required=True)
    p.add_argument('--rounds', type=int, default=6)
    p.add_argument('--threads', default='1,4')
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args(); assert 2 <= args.rounds <= 12
    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    reports = dict(a=R.read(args.a), b=R.read(args.b))
    assert all(v['complete'] for v in reports.values())
    pins = [R.pin(__file__), R.pin(args.a), R.pin(args.b)]
    cases = [c for c in reports['a']['cases'] if c['id'] in args.cases.split(',')]
    assert {c['id'] for c in cases} == set(args.cases.split(','))
    for case in cases:
        match = [c for c in reports['b']['cases'] if (c['app'],c['id']) == (case['app'],case['id'])]
        assert match == [case]
        pins += [case['expected'], *case['inputs']]
        for role in reports:
            product = reports[role]['products'][case['app']]
            pins += [product['source'], product['candidate']['c'], product['candidate']['binary']]
        assert reports['a']['products'][case['app']]['source'] == reports['b']['products'][case['app']]['source']
    pins = list({v['file']:v for v in pins}.values())
    for pin in pins: R.verify(pin)
    report = dict(complete=False, started=time.time(), inputs=pins, records=[], summary=[],
        roles=dict(a=str(args.a.resolve()), b=str(args.b.resolve())),
        scope='Contemporaneous alternating comparison of two frozen candidate products; full process and output, no build cost included.')
    def save(): R.save(out/'report.json', report)
    save()
    try:
        for case in cases:
            expected = Path(case['expected']['file']).read_bytes()
            for threads in (args.threads.split(',') if case.get('parallel') else ['1']):
                cpu = {'1':'3','2':'2,3','4':'0,1,2,3'}[threads]
                for rnd in range(args.rounds):
                    for role in ('ab' if rnd%2 == 0 else 'ba'):
                        folder = out/f'{case["app"]}-{case["id"]}-t{threads}-r{rnd}-{role}'
                        binary = reports[role]['products'][case['app']]['candidate']['binary']
                        row = dict(app=case['app'], case=case['id'], threads=int(threads), round=rnd, role=role, passed=False)
                        report['records'].append(row); save()
                        row['job'], child = R.guarded(folder,[binary['file'],'--threads',threads,'--gpu','off','--',*case['argv']],cpu=cpu)
                        row.update(seconds=child['processSeconds'], userSeconds=child['userSeconds'], rssKiB=child['maxRssKiB'],
                            stdout=R.pin(folder/'stdout.log'), stderr=R.pin(folder/'stderr.log'))
                        row['passed'] = Path(row['stdout']['file']).read_bytes() == expected and not child['stderr']
                        save(); assert row['passed']
                rows = [r for r in report['records'] if (r['app'],r['case'],r['threads']) == (case['app'],case['id'],int(threads))]
                medians = {role:statistics.median(r['seconds'] for r in rows if r['role']==role) for role in 'ab'}
                summary = dict(app=case['app'],case=case['id'],threads=int(threads),medians=medians,bOverA=medians['b']/medians['a'])
                report['summary'].append(summary);save();print(R.json.dumps(summary),flush=True)
        for pin in pins: R.verify(pin)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: report['finished'] = time.time(); save()


if __name__ == '__main__': main()
