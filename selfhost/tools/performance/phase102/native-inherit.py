#!/usr/bin/env python3
"""Bind native B1/B2 emissions to complete prior controls and application outputs.

Same unpatched C reuses its authenticated build and full execution captures.
Different C is built once and reruns every frozen payload. This is a semantic
inheritance gate, not native-image admission or a fresh performance benchmark.
"""
import argparse
import hashlib
import importlib.util
from pathlib import Path
import re
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('p102_inherit_reuse', HERE.parent / 'phase99/qualification/reuse.py')
Q = importlib.util.module_from_spec(spec)
spec.loader.exec_module(Q)
S = Q.support
R = S.module('p102_inherit_apps', HERE.parent / 'phase100/run.py')
CHECK = S.module('p102_inherit_check', HERE / 'check-emitted-v2.py')
G = CHECK.G


def same(left, right):
    return all(left[key] == right[key] for key in ('sha256', 'bytes'))


def job_evidence(bindings, job, argv, expected_exit=0, stdout=None, stderr=None):
    process = S.read(bindings.bind(job['guard'])['file'])
    assert process == job['process'] and S.bounded_exit(process, expected_exit)
    assert job['guardExit'] == (0 if expected_exit == 0 else 1)
    child_pin = bindings.bind(job['receipt'])
    child = S.read(child_pin['file'])
    assert child['command'] == list(map(str, argv)) and child['returncode'] == expected_exit
    execute = ROOT / 'selfhost/tools/performance/phase46/execute.py'
    bindings.bind(execute)
    assert process['command'][-len(argv):] == list(map(str, argv))
    assert process['command'][-len(argv)-2:-len(argv)] == [str(execute), child_pin['file']]
    folder = Path(job['guard']['file']).parent
    captures = {name:bindings.bind(folder / (name + '.log')) for name in ('stdout', 'stderr')}
    for name, expected in [('stdout', stdout), ('stderr', stderr)]:
        raw = Path(captures[name]['file']).read_bytes()
        assert raw.decode(errors='replace') == child[name]
        if expected is not None:
            assert raw == expected, (name, folder)
    return dict(guard=bindings.bind(job['guard']), child=child_pin, captures=captures), child


def build_evidence(bindings, product, clang):
    bindings.bind(product['c'])
    bindings.bind(product['binary'])
    argv = [clang['file'], '-isystem', str(Path(clang['file']).parents[1] / 'include/clang'),
            '-std=c11', '-O3', product['c']['file'], '-o', product['binary']['file'], '-lpthread', '-lm']
    evidence, child = job_evidence(bindings, product['build'], argv)
    return evidence


def baseline_diagnostic(bindings, context, source, product):
    """Find the exact retained request next to its baseline C; never guess text."""
    c = bindings.bind(product['c'])
    assert c['file'].endswith('.1.c')
    prefix = c['file'][:-4]
    expected = S.native_args(context, S.baseline_producer(context, 'b2'), source['file'], prefix)
    matches = []
    for child_path in Path(c['file']).parent.glob('*/child.json'):
        child = S.read(child_path)
        if child.get('command') == expected:
            matches.append(child_path)
    assert len(matches) == 1, ('Need exact retained Phase98 diagnostic request', c['file'], matches)
    folder = matches[0].parent
    job_pin = bindings.bind(folder.parent / (folder.name + '-job.json'))
    evidence, child = job_evidence(bindings, S.read(job_pin['file']), expected, stdout=b'')
    text = child['stderr']
    clocks = re.findall(r'^request=(\d+) request_ms=(\d+) consumed_chars=(\d+)$', text, re.M)
    assert len(clocks) == 1 and clocks[0][0] == '1'
    diagnostic = S.strip_clocks(text)
    unsafe = re.fullmatch(r'SOME PROOFS FAIL\nError: (\d+) defs rely on unsafe or foreign code:\n((?:- [^\n]+\n)+)\n', diagnostic)
    assert diagnostic == S.SUCCESS_DIAGNOSTIC or (unsafe and int(unsafe[1]) == len(unsafe[2].splitlines()))
    return dict(c=c, diagnostic=diagnostic, job=job_pin, evidence=evidence)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--b1-build', type=Path, required=True)
    parser.add_argument('--b2-build', type=Path, required=True)
    parser.add_argument('--backend-policy', type=Path, required=True)
    parser.add_argument('--controls', type=Path, required=True, help='Completed check-emitted.py report')
    parser.add_argument('--apps', type=Path, nargs='*', default=[], help='Completed application run.py reports')
    parser.add_argument('--check-only', action='store_true', help='Authenticate all prior evidence; execute no target')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    bindings = S.Bindings()
    context = Q.baseline(bindings)
    Q.freeze(out, bindings)
    bindings.bind(__file__)
    bindings.bind(HERE / 'check-emitted-v2.py')
    bindings.bind(HERE / 'guarded.py')
    bindings.bind(HERE / 'guard-long-args.py')
    bindings.bind(HERE.parent / 'phase100/run.py')
    (out / 'method.py').write_bytes(Path(__file__).read_bytes())
    report = dict(kind='phase102-native-semantic-inheritance', complete=False, passed=False,
        started=time.time(), executionPerformed=False, imageQualified=False, inputsUnchanged=False,
        method=bindings.bind(__file__), inputs=[], sources=[], obligations=[], inherited=[], fresh=[],
        scope='Exact native B1/B2 C and complete independent diagnostics. Same C inherits authenticated full outputs; changed C reruns all original payloads. No fresh runtime-speed or image-admission claim.')

    def save():
        report['inputs'] = list(bindings.rows.values())
        S.S.save(out / 'report.json', report)

    def load(path):
        pin = bindings.bind(path)
        value = S.read(pin['file'])
        assert value['complete'] and not value.get('error')
        bindings.tree(value)
        return pin, value

    producers = {}
    sources = {}

    def add_source(source, candidate, baseline, parent):
        key = source['file']
        bindings.bind(source)
        build = build_evidence(bindings, candidate, context['clang'])
        diagnostic = baseline_diagnostic(bindings, context, source, baseline)
        if key in sources:
            assert same(sources[key]['candidate']['c'], candidate['c'])
            assert sources[key]['reference']['diagnostic'] == diagnostic['diagnostic']
        else:
            sources[key] = dict(id=f'source-{len(sources):02d}', source=source, candidate=candidate,
                oldBuildEvidence=build, reference=diagnostic, parents=[], obligations=[])
        sources[key]['parents'].append(parent)
        return sources[key]

    oracle_dir = out / 'oracles'
    oracle_dir.mkdir()

    def output_pin(data):
        path = oracle_dir / hashlib.sha256(data).hexdigest()
        if not path.exists():
            path.write_bytes(data)
        assert path.read_bytes() == data
        return bindings.bind(path)

    def add_obligation(source, label, workers, argv, expected, stderr, status, old):
        assert old['passed']
        product = source['candidate']
        command = [product['binary']['file'], '--threads', str(workers), '--gpu', 'off', '--', *argv]
        evidence, child = job_evidence(bindings, old['job'], command, status, expected, stderr)
        item = dict(id=label, source=source['source'], workers=workers, argv=argv,
            expectedStdout=output_pin(expected), expectedStderr=output_pin(stderr), expectedExit=status,
            priorEvidence=evidence, priorObservation=old)
        source['obligations'].append(item)
        report['obligations'].append(item)

    save()
    try:
        for stage, path in [('b1', args.b1_build), ('b2', args.b2_build)]:
            build = S.read(path)
            producers[stage] = S.authenticate(build['binary'], stage, build['source'], path, bindings, context)
        assert producers['b1']['source'] == producers['b2']['source']
        policy = S.backend_policy(args.backend_policy, producers['b1']['source'], bindings)
        report.update(producers=producers, source=producers['b1']['source'], backendPolicy=policy)
        controls_pin, controls = load(args.controls)
        manifest_pin, manifest = load(controls['manifest'])
        report.update(controls=controls_pin, controlManifest=manifest_pin, applications=[])
        controls_by_source = {}
        for case in manifest['records']:
            controls_by_source.setdefault(case['source'], []).append(case)
        assert set(controls_by_source) == set(controls['products'])
        for source, cases in controls_by_source.items():
            old = controls['products'][source]
            selected = add_source(old['source'], old['variants']['candidate'], old['variants']['baseline'], controls_pin)
            selected['controlCases'] = cases
            for case in cases:
                expected = Path(bindings.bind(case['expected'])['file']).read_bytes() if 'expected' in case else case.get('stdout', '').encode()
                for workers in case.get('workers', [1]):
                    rows = [row for row in controls['executions'] if row['case'] == case['id'] and row['workers'] == workers and row['role'] == 'candidate']
                    assert len(rows) == 1
                    add_obligation(selected, 'control/' + case['id'], workers, case.get('argv', []), expected,
                                   case.get('stderr', '').encode(), case.get('returncode', 0), rows[0])
        for index, path in enumerate(args.apps):
            app_pin, app = load(path)
            report['applications'].append(app_pin)
            for name, old in app['products'].items():
                selected = add_source(old['source'], old['candidate'], old['baseline'], app_pin)
                records = [row for row in app['records'] if row['app'] == name and row['role'] == 'candidate']
                assert records
                for i, row in enumerate(records):
                    cases = [case for case in app['cases'] if (case['app'], case['id']) == (name, row['case'])]
                    assert len(cases) == 1
                    case = cases[0]
                    bindings.tree(case)
                    expected = Path(bindings.bind(case['expected'])['file']).read_bytes()
                    add_obligation(selected, f'app-{index}/{name}/{row["case"]}/sample-{i}', row['threads'],
                                   case['argv'], expected, b'', 0, row)
        report['sources'] = list(sources.values())
        save()
        if args.check_only:
            bindings.unchanged()
            report.update(complete=True, passed=True, inputsUnchanged=True, checkOnly=True)
            return
        for source in sources.values():
            directory = out / source['id']
            directory.mkdir()
            source['rows'] = []
            common = None
            with S.S.ExecutionGuard(rss_mib=2048, available_mib=4096) as guard:
                for stage in ('b1', 'b2'):
                    report['executionPerformed'] = True
                    save()
                    row = S.run_request(guard, context, producers[stage], source['source'], directory / stage,
                        seconds=60, oracle=common, expected_diagnostic=source['reference']['diagnostic'])
                    row['stage'] = stage
                    source['rows'].append(row)
                    save()
                    assert row['passed'] and not row['process'].get('interrupted')
                    bindings.tree(row)
                    if common is None:
                        common = bindings.bind(row['output'])
            source['c'] = common
            code = Path(common['file']).read_text()
            for case in source.get('controlCases', []):
                if case.get('requireBaselineCIdentity'):
                    assert same(common, source['reference']['c'])
                for field, present in [('requireTRMC', True), ('forbidTRMC', False)]:
                    for name in case.get(field, []):
                        symbol = 'NF_FID_' + ''.join(str(ord(char)) + '_' for char in name) + '_trmc'
                        assert (symbol in code) == present, (name, field)
            source['sameCAsPrior'] = same(common, source['candidate']['c'])
            if source['sameCAsPrior']:
                source['selectedProduct'] = source['candidate']
                for obligation in source['obligations']:
                    report['inherited'].append(dict(id=obligation['id'], workers=obligation['workers'],
                        source=source['source'], c=common, binary=source['candidate']['binary'],
                        priorEvidence=obligation['priorEvidence'], fullOutputExact=True))
            else:
                clang = context['clang']
                binary = directory / 'program'
                command = [clang['file'], '-isystem', Path(clang['file']).parents[1] / 'include/clang',
                           '-std=c11', '-O3', common['file'], '-o', binary, '-lpthread', '-lm']
                build, child = G.guarded(directory / 'build', command, seconds=60)
                product = dict(c=common, binary=bindings.bind(binary), build=build)
                source['selectedProduct'] = product
                build_evidence(bindings, product, clang)
                for i, obligation in enumerate(source['obligations']):
                    workers = obligation['workers']
                    command = [str(binary), '--threads', str(workers), '--gpu', 'off', '--', *obligation['argv']]
                    job, child = CHECK.execute(directory / f'run-{i:03d}', command,
                        {1:'3', 2:'2,3', 4:'0,1,2,3'}[workers], obligation['expectedExit'])
                    evidence, child = job_evidence(bindings, job, command, obligation['expectedExit'],
                        Path(obligation['expectedStdout']['file']).read_bytes(),
                        Path(obligation['expectedStderr']['file']).read_bytes())
                    report['fresh'].append(dict(id=obligation['id'], workers=workers, source=source['source'],
                        c=common, binary=product['binary'], evidence=evidence, fullOutputExact=True))
                    save()
            source['passed'] = True
            save()
        assert len(report['inherited']) + len(report['fresh']) == len(report['obligations'])
        bindings.unchanged()
        report.update(complete=True, passed=True, inputsUnchanged=True,
            counts=dict(sources=len(sources), nativeEmissions=2*len(sources),
                inheritedOutputs=len(report['inherited']), freshOutputs=len(report['fresh']),
                unchangedC=sum(row['sameCAsPrior'] for row in sources.values())))
    except BaseException as error:
        report['error'] = repr(error)
        raise
    finally:
        report['finished'] = time.time()
        save()
        print(S.json.dumps({key:report.get(key) for key in ('complete', 'passed', 'counts', 'error')}), flush=True)


if __name__ == '__main__':
    main()
