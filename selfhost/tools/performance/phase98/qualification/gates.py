#!/usr/bin/env python3
"""Root-only serial live/cache+rejection or45-source exact-output qualification."""
import argparse
import json
from pathlib import Path
import sys
from support import Bindings, ROOT, S, authenticate, baseline, freeze_methods, pin, read, run_request


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--stage', choices=['b1', 'b2'], required=True)
    p.add_argument('--source', type=Path, required=True, help='Compiler Bend source bound by build receipt')
    p.add_argument('--build-receipt', type=Path, required=True)
    p.add_argument('--suite', choices=['controls', 'broad45'], required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); ctx = baseline(b); freeze_methods(out, b)
    producer = authenticate(a.binary, a.stage, a.source, a.build_receipt, b, ctx)
    cases = []
    if a.suite == 'controls':
        origin = b.bind(ROOT / 'selfhost/build/phase90/native07-qualification01/report.json')
        old = read(origin['file']); assert old['complete'] and old['passed'] and old['inputsUnchanged']
        for row in old['compilerRows']:
            assert row['passed'] and row['exactC']
            cases.append(dict(name=row['name'], source=b.bind(row['source']), live=row['mode'] == 'live', oracle=row['oracle'], oracleReceipt=origin))
        assert len(cases) == 8
        origin = b.bind(ROOT / 'selfhost/build/phase92/conformance01/diagnostics/report.json')
        old = read(origin['file']); assert old['complete'] and old['passed'] and old['inputsUnchanged']
        negatives = [r for r in old['rows'] if r['role'] == 'b1']
        assert len(negatives) == 3
        for i, row in enumerate(negatives):
            assert row['passed'] and row['outputAbsent']
            cases.append(dict(name='negative-' + str(i), source=b.bind(row['source']), live=False,
                              negative=row['diagnostic'], oracleReceipt=origin))
    else:
        origin = b.bind(ROOT / 'selfhost/build/phase92/broad02/report.json')
        old = read(origin['file']); assert old['complete'] and old['passed'] and old['inputsUnchanged']
        assert len(old['cases']) == 45
        for row in old['cases']:
            cases.append(dict(name=row['name'], source=b.bind(row['source']), live=False,
                              oracle=row['oracle'], oracleReceipt=origin, originalExpectedStdout=row['expectedStdout']))
    report = dict(kind='phase98-private-native-qualification-gates', complete=False, passed=False, producer=producer,
                  suite=a.suite, cases=cases, rows=[], executionPerformed=False, inputs=list(b.rows.values()),
                  scope='Exact complete emitted-C hash/size and full diagnostics. No generated-program execution here; unchanged native69 harness is separate.')
    def save(): S.save(out / 'report.json', report)
    save()
    try:
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for i, case in enumerate(cases):
                report['executionPerformed'] = True; save()
                row = run_request(guard, ctx, producer, case['source'], out / (str(i).zfill(2) + '-' + case['name'].replace('/', '_')),
                                  seconds=60, live=case['live'], oracle=case.get('oracle'), negative=case.get('negative'))
                row['name'] = case['name']; report['rows'].append(row); save()
                assert row['passed'], case['name']
        b.unchanged(); report['inputsUnchanged'] = True
        report['complete'] = True; report['passed'] = True
        report['counts'] = dict(exactC=sum(r.get('exactC', False) for r in report['rows']),
                               rejections=sum('expectedDiagnostic' in r for r in report['rows']))
    except BaseException as e:
        report['passed'] = False; report['complete'] = False; report['error'] = repr(e)
        raise
    finally: save()
    print(json.dumps({k:report.get(k) for k in ['complete', 'passed', 'suite', 'counts', 'error']}))
    sys.exit(0 if report['passed'] else 1)


if __name__ == '__main__': main()
