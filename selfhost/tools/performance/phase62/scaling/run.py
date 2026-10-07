#!/usr/bin/env python3
"""Bounded synthetic scaling screen; root runs targets, ordinary prepared compilers."""
import argparse
import hashlib
import json
import statistics
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
sys.path.insert(0, str(ROOT / 'selfhost/tools/performance/programs'))
from support import ExecutionGuard, save


def identity(file):
    file = Path(file).resolve(strict=True)
    return dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())


def read(file):
    return json.loads(Path(file).read_text())


def balanced_sum(xs):
    if len(xs) == 1:
        return xs[0]
    middle = len(xs) // 2
    return f'U32.add({balanced_sum(xs[:middle])}, {balanced_sum(xs[middle:])})'


def fixtures(directory):
    rows = []
    for size in [8, 32, 128, 512]:
        source = 'import Base\n\n' + '\n'.join(
            f'def item_{i}(+x: U32) -> U32:\n  U32.add(x, {i})\n' for i in range(size))
        points = [dict(exportName=f'item_{i}', args=[7], expected=7+i) for i in range(size)]
        rows.append(dict(id=f'definitions-{size}', family='independent-definitions', size=size,
                         definitionCount=size, parameterWidth=1, text=source, points=points))
    for size in [2, 8, 32, 64]:
        params = ', '.join(f'+x{i}: U32' for i in range(size))
        args = list(range(1, size+1))
        body = balanced_sum([f'x{i}' for i in range(size)])
        definitions, points = [], []
        for index in range(8):
            definitions.append(f'def wide_{index}({params}) -> U32:\n  U32.add({body}, {index})\n')
            definitions.append(f'def probe_{index}() -> U32:\n  wide_{index}({", ".join(map(str,args))})\n')
            expected = size*(size+1)//2+index
            points += [dict(exportName=f'wide_{index}', args=args, expected=expected),
                       dict(exportName=f'probe_{index}', args=[], expected=expected)]
        rows.append(dict(id=f'width-{size}', family='ordinary-telescope-width', size=size,
                         definitionCount=16, parameterWidth=size,
                         text='import Base\n\n'+'\n'.join(definitions), points=points))
    directory.mkdir()
    for row in rows:
        file = directory/(row['id']+'.bend')
        file.write_text(row.pop('text'))
        row['source'] = {**identity(file), 'bytes': file.stat().st_size}
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('out', type=Path)
    parser.add_argument('--preparations', type=Path, required=True)
    parser.add_argument('--roles', default='b2,typescript')
    parser.add_argument('--cases', default='all')
    parser.add_argument('--rounds', type=int, default=1)
    parser.add_argument('--warm-requests', type=int, default=0)
    parser.add_argument('--seconds', type=int, default=90)
    parser.add_argument('--child-seconds', type=int, default=20)
    parser.add_argument('--prepare-only', action='store_true')
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase62') and not out.exists()
    assert 1 <= args.rounds <= 3 and 0 <= args.warm_requests <= 3
    assert 10 <= args.seconds <= 300 and 5 <= args.child_seconds <= 60
    roles = args.roles.split(',')
    assert len(roles) == len(set(roles)) and set(roles) <= {'b1', 'b2', 'typescript'}
    prep = read(args.preparations)
    assert prep['complete'] and prep['pass']
    config = read(prep['config']['file'])
    assert identity(prep['config']['file']) == prep['config']
    prepared = {}
    for role in roles:
        row = next(row for row in prep['preparations'] if row['observation']['role'] == role)
        assert row['success'] and identity(row['result']['file']) == row['result']
        prepared[role] = row['result']
    worker = HERE/'worker.mjs'
    inputs = [identity(__file__), identity(worker), identity(args.preparations), prep['config'],
              config['node'], identity(ROOT/'selfhost/tools/performance/programs/support.py')]
    for role in roles:
        p = read(prepared[role]['file'])
        inputs += [prepared[role], *[x['after'] for x in p.get('copies', [])],
                   *p.get('verification', {}).get('cacheFiles', [])]
    for name in ['bend.ts', 'comp.ts', 'base.bend']:
        inputs.append(identity(Path(config['upstream'])/'bend2'/name))
    inputs = list({x['file']: x for x in inputs}.values())

    def verify():
        for item in inputs:
            assert identity(item['file']) == {k: item[k] for k in ['file', 'sha256']}, item['file']

    verify()
    out.mkdir(parents=True)
    cases = fixtures(out/'sources')
    if args.cases != 'all':
        names = args.cases.split(',')
        assert set(names) <= {row['id'] for row in cases}
        cases = [row for row in cases if row['id'] in names]
    plan = dict(kind='phase62-synthetic-scaling-plan', cases=cases, roles=roles,
                upstream=config['upstream'], upstreamCommit=config['upstreamCommit'], node=config['node'],
                preparations=prepared, inputs=inputs, rounds=args.rounds,
                warmRequests=args.warm_requests, execArgv=['--stack-size=4096', '--max-old-space-size=1024'],
                scope='Prepared Base cache, fresh process per case/role/round. Import/API/compile clocks separate. '
                'Fresh exact numeric checks of every generated fixture export after all timing windows. '
                'Synthetic mechanisms only; no representative performance or asymptotic proof from one round.')
    save(out/'plan.json', plan)
    report = dict(kind='phase62-synthetic-scaling', complete=False, pass_=False,
                  plan=identity(out/'plan.json'), rows=[], failures=[], statistics=[],
                  prepareOnly=args.prepare_only)
    report['pass'] = report.pop('pass_')
    save(out/'report.json', report)
    if args.prepare_only:
        report.update(complete=True, **{'pass': True}, targetExecuted=False)
        save(out/'report.json', report)
        return
    started = time.monotonic()
    try:
        with ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for sample in range(args.rounds):
                for index, case in enumerate(cases):
                    offset = (index+sample) % len(roles)
                    for role in roles[offset:]+roles[:offset]:
                        prefix = out/f'{case["id"]}-{sample}-{role}'
                        request = dict(plan=report['plan'], case=case['id'], role=role, sample=sample,
                                       output=str(prefix)+'.mjs')
                        request_file, result_file = Path(str(prefix)+'.request.json'), Path(str(prefix)+'.result.json')
                        save(request_file, request)
                        execution = guard.run(['taskset', '-c', '3', config['node']['file'], *plan['execArgv'],
                                               str(worker), str(request_file), str(result_file)],
                                              str(prefix)+'-process',
                                              min(started+args.seconds, time.monotonic()+args.child_seconds))
                        observation = read(result_file) if result_file.exists() else None
                        success = bool(execution['complete'] and observation and observation.get('pass'))
                        row = dict(case=case['id'], role=role, sample=sample, success=success,
                                   observation=observation, execution=execution,
                                   result=identity(result_file) if result_file.exists() else None)
                        report['rows'].append(row)
                        if not success:
                            report['failures'].append(dict(case=case['id'], role=role, sample=sample,
                                                          error=(observation or {}).get('error') or execution.get('stoppedFor')))
                        save(out/'report.json', report)
                        if not success:
                            raise RuntimeError('Scaling screen stops after the first failed worker; see receipt')
        for case in cases:
            for role in roles:
                values = [row['observation'] for row in report['rows'] if row['case'] == case['id'] and row['role'] == role]
                report['statistics'].append(dict(case=case['id'], family=case['family'], size=case['size'], role=role,
                    firstRequestMs=statistics.median(x['firstRequestMs'] for x in values),
                    importApiAndFirstMs=statistics.median(x['importApiAndFirstMs'] for x in values)))
        verify()
        report.update(complete=True, **{'pass': True})
    except Exception as error:
        report['error'] = repr(error)
    finally:
        report['elapsedSeconds'] = time.monotonic()-started
        save(out/'report.json', report)
        print(json.dumps({k: report.get(k) for k in ['complete', 'pass', 'elapsedSeconds', 'error']}))
    if not report['pass']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
