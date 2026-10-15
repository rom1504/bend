#!/usr/bin/env python3
"""Root-only final B1/B2 full-value controls, using unchanged frozen source/oracles."""
import argparse
import json
from pathlib import Path
import re
import shutil
import time
from support import Bindings, ROOT, S, authenticate, backend_policy, baseline, baseline_producer, freeze_methods, pin, read, run_request
from final_control_plan import load_cases, native_flags


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--b1-build', type=Path, required=True)
    p.add_argument('--b2-build', type=Path, required=True)
    p.add_argument('--backend-policy', type=Path, required=True)
    p.add_argument('--backend-controls', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); ctx = baseline(b); freeze_methods(out, b); producers = {}
    for stage, path in [('b1', a.b1_build), ('b2', a.b2_build)]:
        receipt = read(path)
        producers[stage] = authenticate(receipt['binary'], stage, receipt['source'], path, b, ctx)
    source = producers['b1']['source']; assert source == producers['b2']['source']
    policy = backend_policy(a.backend_policy, source, b)
    evidence_pin = b.bind(a.backend_controls); evidence = read(evidence_pin['file'])
    assert evidence['kind'] == 'phase98-backend-specific-qualification'
    assert evidence['complete'] and evidence['passed'] and evidence['inputsUnchanged'] and not evidence.get('error')
    assert evidence['source'] == source and evidence['backendPolicy'] == policy and evidence['imageQualified'] is False
    for item in evidence['inputs']: b.bind(item)
    plans, cases = load_cases(evidence, b)
    corpus = next(case for case in cases if case['id'] == 'full-string-corpus')
    assert len(corpus['expectedStdout'].encode()) == 120386
    assert len(json.loads(corpus['expectedStdout'])) == 1444
    reference = baseline_producer(ctx, 'b2')
    report = dict(kind='phase98-final-image-native-controls', complete=False, passed=False, inputsUnchanged=False,
                  executionPerformed=False, imageQualified=False, source=source, producers=producers,
                  referenceProducer=reference, backendPolicy=policy, backendControls=evidence_pin,
                  originalPlans=plans, originalSelections=evidence['finalImageControlPlans'], cases=cases, rows=[], programs=[], method=pin(__file__), inputs=[],
                  scope='Five unchanged Bend sources and complete original outputs, including the owning origin-swap refusal. Independent baseline B2 freezes each diagnostic; final B1/B2 must agree on whole C and exact diagnostic. One matched unpatched O2 build and execution per shared C. Original certificate, provider-refusal and raw API controls remain separate evidence; this report alone does not qualify an image.')
    def save():
        report['inputs'] = list(b.rows.values()); S.save(out / 'report.json', report)
    def guarded(guard, argv, destination, seconds):
        assert shutil.disk_usage(ROOT).free > 210 * 1024**2
        command = ['bash', '-c', 'ulimit -f 65536; ulimit -c 0; exec "$@"', 'phase98', 'taskset', '-c', '3', *map(str, argv)]
        process = guard.run(command, destination, time.monotonic() + seconds)
        return dict(command=command, process=process,
                    raw=[b.bind(destination / n) for n in ['process.json', 'stdout.log', 'stderr.log']],
                    passed=bool(process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and not process.get('interrupted')))
    save()
    try:
        with S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
            for index, case in enumerate(cases):
                directory = out / (str(index).zfill(2) + '-' + case['id']); directory.mkdir()
                report['executionPerformed'] = True; save()
                old = run_request(guard, ctx, reference, case['source'], directory / 'reference', seconds=60,
                                  capture_reference_diagnostic=True)
                old.update(id=case['id'], stage='reference'); report['rows'].append(old); save()
                assert old['passed'] and not old['process'].get('interrupted'), (case['id'], 'reference')
                b.bind(old['output']); b.bind(old['diagnosticFile']); common = None
                for stage in ['b1', 'b2']:
                    row = run_request(guard, ctx, producers[stage], case['source'], directory / stage, seconds=60,
                                      oracle=common, expected_diagnostic=old['diagnostic'])
                    row.update(id=case['id'], stage=stage); report['rows'].append(row); save()
                    assert row['passed'] and not row['process'].get('interrupted'), (case['id'], stage)
                    actual = b.bind(row['output']); b.bind(row['diagnosticFile'])
                    row['sameCAsHistorical'] = all(actual[k] == old['output'][k] for k in ['sha256', 'bytes'])
                    flags = native_flags(actual['file'])
                    row['flags'] = flags
                    assert flags['READONLY_OBSERVERS'] == 1
                    assert flags['TYPED_SCALARS'] == flags['SCALAR_ARRAYS'] == case['scalar']
                    assert flags['UNSHARED_ARRAYS'] == 0
                    if 'declinedOwner' in case:
                        symbol = 'NF_FID_' + ''.join(str(ord(c)) + '_' for c in '$observer.' + case['declinedOwner'])
                        assert symbol not in Path(actual['file']).read_text()
                        row['owningObserverDeclined'] = True
                    if common is None: common = actual
                    save()
                product = dict(id=case['id'], c=common, passed=False, runtimeArgs=['--threads', '1', '--gpu', 'off'])
                report['programs'].append(product); save()
                cc = ctx['clang']['file']; binary = directory / 'program'
                product['build'] = guarded(guard, [cc, '-isystem', str(Path(cc).parents[1] / 'include/clang'), '-O2', common['file'], '-o', binary, '-lm', '-pthread'], directory / 'clang', 60)
                save(); assert product['build']['passed'], case['id']
                product['binary'] = b.bind(binary)
                product['run'] = guarded(guard, [binary, *product['runtimeArgs']], directory / 'run', 30)
                save(); assert product['run']['passed'], case['id']
                for stream in ['stdout', 'stderr']:
                    actual = directory / ('run/' + stream + '.log'); product[stream] = b.bind(actual)
                    assert actual.read_bytes() == case['expected' + stream.title()].encode(), (case['id'], stream)
                product['fullOutputExact'] = product['passed'] = True; save()
                print(json.dumps(dict(case=case['id'], stageCExact=True, fullOutputExact=True)), flush=True)
        assert len(report['rows']) == 15 and len(report['programs']) == 5
        assert all(row['exactC'] for row in report['rows'] if row['stage'] == 'b2')
        b.unchanged(); report.update(inputsUnchanged=True, complete=True, passed=True,
                                    counts=dict(referenceEmissions=5, finalImageEmissions=10, stageCEqualities=5,
                                                nativeBuilds=5, fullOutputExecutions=5, corpusPairs=1444, corpusFields=14))
    except BaseException as error:
        report.update(complete=False, passed=False, error=repr(error)); raise
    finally: save()
    print(json.dumps({k:report[k] for k in ['complete', 'passed', 'imageQualified', 'counts']}))


if __name__ == '__main__': main()
