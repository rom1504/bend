#!/usr/bin/env python3
"""Profile frozen experiment ELFs without rebuilding or changing their code."""
import argparse
import collections
from pathlib import Path
import shutil
import sys
import time
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PERF = ROOT/'selfhost/tools/performance'
sys.path.insert(0, str(PERF/'phase100'))
import run as R
P = R.module('phase102_profile_analysis', PERF/'phase101/profile.py')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--screen', type=Path, required=True)
    p.add_argument('--app', required=True)
    p.add_argument('--case', required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--roles', default='candidate')
    p.add_argument('--rounds', type=int, default=24)
    p.add_argument('--periods', default='8000,13000')
    a = p.parse_args(); assert 1 <= a.rounds <= 40
    out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    screen = R.read(a.screen); assert screen['complete'] and all(r['passed'] for r in screen['records'])
    cases = [c for c in screen['cases'] if (c['app'],c['id']) == (a.app,a.case)]
    assert len(cases) == 1; case = cases[0]; products = screen['products'][a.app]
    acquired = R.read(products['acquired']['file']); R.verify(products['acquired'])
    clang = acquired['context']['clang']; roles = a.roles.split(','); periods = list(map(int,a.periods.split(',')))
    assert set(roles) <= {'baseline','candidate','upstream'} and len(set(roles)) == len(roles)
    assert len(set(periods)) == len(periods) and all(8000 <= n <= 100000 for n in periods)
    pins = [R.pin(__file__), R.pin(P.__file__), R.pin(P.ANALYSIS), R.pin(P.SAMPLER),
            R.pin(R.__file__), R.pin(a.screen), products['acquired'], products['source'],
            case['expected'], *case['inputs'], clang, R.pin(shutil.which('readelf')),
            R.pin(shutil.which('addr2line')), R.pin(PERF/'phase86/guard.py'), R.pin(PERF/'phase46/execute.py')]
    for role in roles: pins += [products[role]['c'],products[role]['binary']]
    for item in pins: R.verify(item)
    report = dict(complete=False, started=time.time(), inputs=pins, app=a.app, case=case,
                  roles=roles, periodsUs=periods, rounds=a.rounds, records=[], summaries=[],
                  scope='Unchanged ELF physical leaf samples, one worker, complete startup/input/output/shutdown. No call stack or allocation attribution; clocks are not clean speed measurements.')
    (out/'snapshot-profile.py').write_bytes(Path(__file__).read_bytes())
    def save(): R.save(out/'report.json', report)
    save()
    try:
        library = out/'sampler.so'
        report['samplerBuild'], _ = R.guarded(out/'sampler-build', [clang['file'], '-isystem',
            str(Path(clang['file']).parents[1]/'include/clang'), '-O2','-Wall','-Wextra','-Werror',
            '-fPIC','-shared',str(P.SAMPLER),'-o',str(library),'-pthread','-ldl','-lrt'])
        report['sampler'] = R.pin(library); buckets = collections.defaultdict(collections.Counter)
        expected = Path(case['expected']['file']).read_bytes()
        for period in periods:
            for rnd in range(a.rounds):
                for role in (roles if rnd%2 == 0 else list(reversed(roles))):
                    binary = products[role]['binary']; label = f'{role}-p{period}-r{rnd}'
                    samples = out/(label+'.samples'); directory = out/label
                    record = dict(role=role, periodUs=period, round=rnd, complete=False)
                    report['records'].append(record); save()
                    record['job'], child = R.guarded(directory, ['env','LD_PRELOAD='+str(library),
                        'BEND_SAMPLE_OUT='+str(samples),'BEND_SAMPLE_PERIOD_US='+str(period),binary['file'],
                        '--threads','1','--gpu','off','--',*case['argv']], seconds=30)
                    record['outputCorrect'] = (directory/'stdout.log').read_bytes() == expected and not child['stderr']
                    assert record['outputCorrect']
                    record['samples'] = R.pin(samples)
                    data, counts = P.analyze(samples,binary); dest = out/(label+'-analysis.json'); R.save(dest,data)
                    record.update(analysis=R.pin(dest), sampleCount=data['header']['samples'], coverage=data['coverage'], complete=True)
                    buckets[(role,period)].update(counts); buckets[(role,'all')].update(counts); save()
        for role in roles:
            for period in [*periods,'all']:
                counts = buckets[(role,period)]; total = sum(counts.values())
                if period == 'all': assert total >= 300, (role,total)
                summary = dict(role=role,periodUs=period,samples=total,leaves=P.ranked(counts,total))
                report['summaries'].append(summary)
                if period == 'all': print(R.json.dumps(dict(role=role,samples=total,leaves=summary['leaves'][:12])),flush=True)
        for item in [*pins,report['sampler']]: R.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: report['finished'] = time.time(); save()


if __name__ == '__main__': main()
