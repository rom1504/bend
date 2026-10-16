#!/usr/bin/env python3
"""Root-only final B1/B2 borrowed-call programs, original plans and exact outputs."""
import argparse
import json
from pathlib import Path
import shutil
import time
from borrowed_support import S, ROOT, small, micro, mechanism, flags, control_cases


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for name in ['b1-build', 'b2-build', 'backend-policy', 'small', 'out']: p.add_argument('--' + name, type=Path, required=True)
    p.add_argument('--micro-report', type=Path, action='append', default=[])
    a = p.parse_args(); out = a.out.resolve(); assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    b = S.Bindings(); ctx = S.baseline(b); producers = {}
    for stage, path in [('b1', a.b1_build), ('b2', a.b2_build)]:
        receipt = S.read(path); producers[stage] = S.authenticate(receipt['binary'], stage, receipt['source'], path, b, ctx)
    source = producers['b1']['source']; assert source == producers['b2']['source']; policy = S.backend_policy(a.backend_policy, source, b)
    qp, plan, pp, ep, static = small(b, a.small, source)
    cases = control_cases(b, plan, ep)
    cases += [micro(b, file, source) for file in a.micro_report]
    assert len({case['id'] for case in cases}) == len(cases)
    if static: assert any('static' in case['id'] and '10000000\n' in case['stdout'] for case in cases), 'Include the completed static-root micro receipt'
    out.mkdir(parents=True); S.freeze_methods(out, b); reference = S.baseline_producer(ctx, 'b2')
    report = dict(kind='phase99-final-image-borrowed-controls', complete=False, passed=False, inputsUnchanged=False,
        executionPerformed=False, imageQualified=False, source=source, producers=producers, referenceProducer=reference,
        backendPolicy=policy, smallQualification=qp, originalPlan=pp, originalEmission=ep, cases=cases,
        rows=[], programs=[], inputs=[], method=S.pin(__file__), allTrivialAlternative=static)
    def save(): report['inputs'] = list(b.rows.values()); S.S.save(out / 'report.json', report)
    def guarded(guard, argv, folder, seconds):
        assert shutil.disk_usage(ROOT).free > 210 * 1024**2
        command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase99', 'taskset', '-c', '3', *map(str, argv)]
        process = guard.run(command, folder, time.monotonic() + seconds)
        return dict(command=command, process=process, raw=[b.bind(folder / name) for name in ['process.json', 'stdout.log', 'stderr.log']],
                    passed=S.bounded_exit(process, 0))
    save()
    try:
        with S.S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for index, case in enumerate(cases):
                directory = out / (str(index).zfill(2) + '-' + case['id']); directory.mkdir()
                report['executionPerformed'] = True; save()
                old = S.run_request(guard, ctx, reference, case['source'], directory / 'reference', seconds=60, capture_reference_diagnostic=True)
                old.update(id=case['id'], stage='reference'); report['rows'].append(old); save(); assert old['passed']
                b.bind(old['output']); b.bind(old['diagnosticFile']); assert flags(old['output']['file']) == case['expectedFlags']
                common = None
                for stage in ['b1', 'b2']:
                    row = S.run_request(guard, ctx, producers[stage], case['source'], directory / stage, seconds=60,
                                        oracle=common, expected_diagnostic=old['diagnostic'])
                    row.update(id=case['id'], stage=stage); report['rows'].append(row); save(); assert row['passed']
                    c = b.bind(row['output']); row['flags'] = flags(c['file'])
                    assert row['flags'] == case['expectedFlags'] and row['flags']['READONLY_OBSERVERS'] == 1
                    assert row['flags']['TYPED_SCALARS'] == row['flags']['SCALAR_ARRAYS'] == case['scalar']
                    row['mechanism'] = mechanism(b, c, case, static)
                    b.bind(row['diagnosticFile']); common = common or c; save()
                product = dict(id=case['id'], c=common, passed=False, runtimeArgs=case['runtimeArgs'])
                report['programs'].append(product); save(); cc = ctx['clang']['file']; binary = directory / 'program'
                product['build'] = guarded(guard, [cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-O2', common['file'], '-o', binary, '-lm', '-pthread'], directory / 'clang', 60)
                save(); assert product['build']['passed']; product['binary'] = b.bind(binary)
                product['run'] = guarded(guard, [binary, *case['runtimeArgs']], directory / 'run', 30)
                save(); assert product['run']['passed']
                for stream in ['stdout', 'stderr']:
                    file = directory / 'run' / (stream + '.log'); product[stream] = b.bind(file)
                    assert file.read_bytes() == case[stream].encode(), (case['id'], stream)
                product.update(passed=True, fullOutputExact=True); save()
                print(json.dumps(dict(case=case['id'], stageCExact=True, fullOutputExact=True)), flush=True)
        assert len(report['rows']) == 3 * len(cases) and len(report['programs']) == len(cases)
        b.unchanged(); report.update(complete=True, passed=True, inputsUnchanged=True)
    except BaseException as error: report['error'] = repr(error); raise
    finally: save()


if __name__ == '__main__': main()
