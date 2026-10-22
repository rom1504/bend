"""Paired selector transfer screen; root-only CPU3 execution, outside original45."""
import argparse
import importlib.util
import os
from pathlib import Path
import re
import statistics
import subprocess
import time

ROOT = Path(__file__).resolve().parents[6]
ORACLE = ROOT / 'selfhost/tools/performance/phase112/benchmark45/run.py'
spec = importlib.util.spec_from_file_location('phase126_transfer_oracle', ORACLE)
O = importlib.util.module_from_spec(spec)
spec.loader.exec_module(O)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate-emission', type=Path, required=True)
    parser.add_argument('--parent-emission', type=Path, required=True)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--label', required=True)
    args = parser.parse_args()
    assert sorted(os.sched_getaffinity(0)) == [3], 'Root serial CPU3 lane required'
    assert re.fullmatch(r'[a-z0-9][a-z0-9_-]*', args.label)
    out = args.out.resolve()
    assert not out.exists() and out.is_relative_to(ROOT / 'selfhost/build/phase126')
    selection_file = ROOT / 'implementation/phase125/candidate.json'
    selection, manifest = O.read(selection_file), O.read(args.manifest)
    assert selection['complete'] and selection['nativeQualified']
    runtime = selection['runtime']
    O.verify(runtime)
    cases = manifest['cases']
    assert len(cases) == 1, 'This frozen transfer has one workload'
    case = cases[0]
    assert case['name'] == 'p126-routing1024'
    assert case['runtimeArgs'] == [17, 99] and case['repetitions'] == 2000 and case['warmups'] == 2
    assert case['expectedStdout'] == '1964461478\n' and case['ratioEligible'] is False
    O.verify(case['source'])
    O.verify(case['expectedStdoutEvidence'])
    assert Path(case['expectedStdoutEvidence']['file']).read_text() == case['expectedStdout']
    builder = ROOT / 'selfhost/tools/performance/phase123/build-aligned.py'
    inputs = [O.pin(__file__), O.pin(ORACLE), O.pin(builder), O.pin(selection_file),
              O.pin(args.manifest), runtime, case['source'], case['expectedStdoutEvidence'],
              *manifest.get('inputs', [])]
    inputs.extend([selection['api'], selection['source']])
    for item in inputs:
        O.verify(item)
    out.mkdir(parents=True)
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    report = dict(kind='phase126-paired-selector-transfer-screen', complete=False, inputs=inputs,
                  label=args.label, runtime=runtime, builds=[], rows=[], rounds=3,
                  source=case['source'], runtimeArgs=case['runtimeArgs'], repetitions=2000, warmups=2,
                  scope='New independently specified transfer workload, outside original45. '
                        'No upstream reference or broad parity score. Both checked QBE products '
                        'use the same selected Phase125 runtime and aligned build method. '
                        'Original Phase93 complete-result/count oracle is unchanged.')
    save = lambda: O.save(out / 'report.json', report)
    save()
    started = time.monotonic()
    products = {}
    try:
        for role, file in [('parent', args.parent_emission), ('candidate', args.candidate_emission)]:
            emission = O.read(file)
            assert emission['complete']
            assert emission['kind'] == 'phase118-request-bound-integrated-emission'
            report['inputs'].extend([O.pin(file), *emission['inputs'], emission['runtime']])
            for item in emission['inputs'] + [emission['runtime']]:
                O.verify(item)
            assert all(emission['runtime'][k] == runtime[k] for k in ('bytes', 'sha256'))
            if role == 'parent':
                assert emission['api'] == selection['api'] and emission['source'] == selection['source']
            api_report_file = Path(emission['api']['file']).parent / 'report.json'
            api_pin = O.pin(api_report_file)
            assert any(x['file'] == api_pin['file'] and x['sha256'] == api_pin['sha256'] for x in emission['inputs'])
            api_report = O.read(api_report_file)
            assert api_report['complete'] and api_report['checked'] and api_report['api'] == emission['api']
            assert any(x['file'] == emission['source']['file'] and x['sha256'] == emission['source']['sha256'] for x in api_report['inputs'])
            matches = [x for x in emission['cases'] if x['name'] == case['name']]
            assert len(matches) == 1
            emitted = matches[0]
            assert emitted['source'] == case['source'] and emitted['verified'] and emitted['parentVerified']
            O.verify(emitted['qbe'])
            report['inputs'].extend([api_pin, emitted['qbe']])
            destination = ROOT / 'selfhost/build/phase111' / ('p126-transfer-' + args.label + '-' + role)
            assert not destination.exists()
            command = ['python3', '-B', str(builder), '--source', emitted['qbe']['file'],
                       '--runtime', runtime['file'], '--out', str(destination), '--seconds', '30']
            build_row = dict(role=role, command=command, qbe=emitted['qbe'], runtime=runtime)
            report['builds'].append(build_row)
            save()
            begin = time.monotonic()
            child = subprocess.run(command, capture_output=True, timeout=100)
            for stream in ('stdout', 'stderr'):
                path = out / (role + '.build.' + stream)
                path.write_bytes(getattr(child, stream))
                build_row[stream] = O.pin(path)
            build_row.update(status=child.returncode, seconds=time.monotonic() - begin)
            if (destination / 'report.json').exists():
                build_row['report'] = O.pin(destination / 'report.json')
            save()
            assert child.returncode == 0
            build = O.read(destination / 'report.json')
            assert build['complete'] and build['kind'] == 'phase123-branch-aligned-qbe-build'
            assert not build['perProgramC'] and not build['cproc'] and build['cachedRuntime']
            for item in build['inputs']:
                O.verify(item)
            assert runtime in build['inputs'] and emitted['qbe'] in build['inputs']
            report['inputs'].extend([build_row['report'], *build['inputs'], build['binary']])
            products[role] = build['binary']
            save()
        for round_index in range(3):
            roles = ['parent', 'candidate'] if round_index % 2 == 0 else ['candidate', 'parent']
            for role in roles:
                binary = products[role]
                O.verify(binary)
                command = [binary['file'], '--threads', '1', '--gpu', 'off', '--',
                           '2000', '2', '17', '99']
                row = dict(name=case['name'], role=role, round=round_index, binary=binary, command=command)
                report['rows'].append(row)
                save()
                begin = time.monotonic()
                child = subprocess.run(command, capture_output=True, timeout=30)
                wall = time.monotonic() - begin
                stem = role + '-' + str(round_index)
                for stream in ('stdout', 'stderr'):
                    path = out / (stem + '.' + stream)
                    path.write_bytes(getattr(child, stream))
                    row[stream] = O.pin(path)
                row.update(status=child.returncode, wallSeconds=wall)
                save()
                row['elapsedMs'] = O.observation(child.stdout, child.stderr, child.returncode, case, wall)
                row['correct'] = True
                save()
                print(role, round_index, row['elapsedMs'], flush=True)
        assert len(report['rows']) == 6 and all(x.get('correct') for x in report['rows'])
        medians = {role: statistics.median(x['elapsedMs'] for x in report['rows'] if x['role'] == role)
                   for role in products}
        report['summary'] = dict(medianElapsedMs=medians,
            candidateOverParent=medians['candidate'] / medians['parent'] if medians['parent'] else None,
            medianWallSeconds={role: statistics.median(x['wallSeconds'] for x in report['rows'] if x['role'] == role)
                               for role in products},
            observations=6, qualification='Exact result + 2 warmup and 2000 timed successes for every observation.')
        for item in report['inputs']:
            O.verify(item)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['seconds'] = time.monotonic() - started
        save()


if __name__ == '__main__':
    main()
