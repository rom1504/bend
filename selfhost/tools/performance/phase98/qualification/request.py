#!/usr/bin/env python3
"""Root-only one guarded candidate/reference compilation request."""
import argparse
import json
from pathlib import Path
import sys
from support import Bindings, S, authenticate, backend_policy, baseline, baseline_producer, freeze_methods, pin, read, run_request


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path)
    p.add_argument('--stage', choices=['b1', 'b2'])
    p.add_argument('--compiler-source', type=Path)
    p.add_argument('--build-receipt', type=Path)
    p.add_argument('--baseline', choices=['b1', 'b2'])
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--purpose', choices=['reference', 'compare', 'changed-backend'], required=True)
    p.add_argument('--oracle-report', type=Path)
    p.add_argument('--backend-policy', type=Path)
    p.add_argument('--live', action='store_true')
    p.add_argument('--seconds', type=int, default=300)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); ctx = baseline(b); freeze_methods(out, b)
    if a.baseline:
        assert not any([a.binary, a.stage, a.compiler_source, a.build_receipt])
        producer = baseline_producer(ctx, a.baseline)
    else:
        assert all([a.binary, a.stage, a.compiler_source, a.build_receipt])
        producer = authenticate(a.binary, a.stage, a.compiler_source, a.build_receipt, b, ctx)
    source = b.bind(a.source); oracle = None; expected_diagnostic = None
    report = dict(kind='phase98-native-qualification-request', complete=False, passed=False, executionPerformed=False,
                  producer=producer, source=source, purpose=a.purpose, method=pin(__file__), inputs=list(b.rows.values()),
                  imageQualified=False, wholeCompilerProved=False,
                  scope='Self/request artifact comparison only. Unsafe-dependency diagnostics remain explicit; image qualification additionally requires semantic gates.')
    if a.purpose in ['compare', 'changed-backend']:
        assert a.oracle_report
        report['oracleReport'] = b.bind(a.oracle_report)
        old = read(a.oracle_report)
        assert old['kind'] == report['kind'] and old['complete'] and old['passed'] and old['inputsUnchanged']
        assert old['source'] == source
        assert old['producer']['binary'] != producer['binary'], 'Reference must have a distinct producer image'
        for row in old['inputs']: b.bind(row)
        reference_c = b.bind(old['row']['output'])
        b.bind(old['row']['diagnosticFile'])
        expected_diagnostic = old['row']['diagnostic']
        assert Path(old['row']['diagnosticFile']['file']).read_text() == expected_diagnostic
        if a.purpose == 'changed-backend':
            assert not a.baseline and producer['stage'] == 'b1' and producer['source'] == source
            assert old['purpose'] == 'reference' and old['producer'].get('historicalBaseline') and old['producer']['stage'] == 'b2'
            assert a.backend_policy
            report['backendPolicy'] = backend_policy(a.backend_policy, source, b)
            report['independentReferenceC'] = reference_c
            report['semanticQualificationRequired'] = True
            report['exactCRequired'] = False
        else:
            oracle = reference_c
            if old['purpose'] == 'changed-backend':
                assert not a.baseline and producer['stage'] == 'b2' and producer['source'] == source
                assert old['producer']['stage'] == 'b1' and old['producer']['source'] == source
                assert a.backend_policy
                report['backendPolicy'] = backend_policy(a.backend_policy, source, b)
                assert report['backendPolicy'] == old['backendPolicy']
                report['candidateFixedPointRequired'] = True
            else:
                assert old['purpose'] == 'reference' and old['producer'].get('historicalBaseline')
                assert not a.backend_policy
    else:
        assert not a.oracle_report and not a.backend_policy and a.baseline, 'References use an independent maintained baseline'
    def save():
        report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    save()
    try:
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            report['executionPerformed'] = True; save()
            report['row'] = run_request(guard, ctx, producer, source, out / 'execution', a.seconds, a.live, oracle,
                                        expected_diagnostic=expected_diagnostic, capture_reference_diagnostic=a.purpose == 'reference')
        if a.purpose == 'changed-backend':
            actual = report['row'].get('output')
            report['row']['sameCAsIndependentBaseline'] = bool(actual and all(actual[k] == reference_c[k] for k in ['sha256', 'bytes']))
            report['row']['changedCIntent'] = report['backendPolicy']
        b.unchanged(); report['inputsUnchanged'] = True
        report['passed'] = report['row']['passed']; report['complete'] = True
    except BaseException as e:
        report['passed'] = False; report['complete'] = False; report['error'] = repr(e)
        raise
    finally: save()
    print(json.dumps({k:report.get(k) for k in ['complete', 'passed', 'purpose', 'error']}))
    sys.exit(0 if report['passed'] else 1)


if __name__ == '__main__': main()
