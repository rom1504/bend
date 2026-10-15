#!/usr/bin/env python3
"""Run the actual admitted native CLI serially against its completed control products."""
import argparse, importlib.util, json, re, subprocess, sys
from pathlib import Path
sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('native_release_cli', HERE/'launch.py')
N = importlib.util.module_from_spec(spec); spec.loader.exec_module(N)


def same(a, b): return all(a[k] == b[k] for k in ['sha256', 'bytes'])


def diagnostics(text):
    return re.sub(r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n', '', text, flags=re.M)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for key in ['selection', 'controls', 'out']: parser.add_argument(key, type=Path)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(N.ROOT/'selfhost/build/phase98'); out.mkdir(parents=True, exist_ok=False)
    report = dict(kind='bend-native-public-cli-controls', version=1, complete=False, passed=False, rows=[], method=N.pin(__file__))
    def save(): (out/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    save()
    try:
        release, binding = N.load(args.selection)
        assert binding['stage'] == 'b2', 'This default-stage control expects qualified B2 selection'
        control_pin = N.pin(args.controls); controls = json.loads(args.controls.read_text())
        assert control_pin in release['receipts']['controls']
        assert controls['kind'] == 'phase98-changed-backend-gates' and controls['suite'] == 'controls'
        assert controls['complete'] and controls['passed'] and controls['inputsUnchanged']
        cases = {(row['stage'], row['name']):row for row in controls['rows']}
        inputs = [N.pin(file) for file in [__file__, HERE/'launch.py', N.ROOT/'selfhost/native.py', N.GUARD, N.SUPPORT]]
        inputs += [binding['selection'], binding['admission'], control_pin]
        for stage in ['b1', 'b2']:
            assert N.load(args.selection, stage=stage)[0] == release
            for key in ['stage', 'source', 'binary', 'argvSentinel']:
                assert controls['producers'][stage][key] == release['stages'][stage][key]
            for name in ['cached-small', 'live-file-io', 'cached-map_closed', 'negative-0']:
                row = cases[stage, name]; assert row['passed']
                inputs.append(N.verify(row['source']))
                if 'output' in row: inputs.append(N.verify(row['output']))
        report.update(admission=binding, inputs=inputs); save()
        def invoke(name, source, target, stage=None, extra=(), selection=None):
            command = [sys.executable, '-B', str(N.ROOT/'selfhost/native.py'), source['file'], '-o', str(target),
                '--selection', str((selection or args.selection).resolve()), '--seconds', '60', *extra]
            if stage: command.extend(['--stage', stage])
            report['current'] = name; save()
            child = subprocess.run(command, capture_output=True, text=True, timeout=90)
            (out/(name+'.stdout')).write_text(child.stdout); (out/(name+'.stderr')).write_text(child.stderr)
            assert not child.stdout and 'Request evidence: ' in child.stderr
            directory = Path(child.stderr.rsplit('Request evidence: ', 1)[1].strip())
            assert directory.is_relative_to(N.ROOT/'selfhost/build/native/requests')
            rp = N.pin(directory/'report.json'); request = json.loads(Path(rp['file']).read_text())
            row = dict(name=name, command=command, returncode=child.returncode, request=rp, passed=False,
                stdout=N.pin(out/(name+'.stdout')), stderr=N.pin(out/(name+'.stderr')))
            report['rows'].append(row); save(); return row, request, directory
        for stage in ['b1', 'b2']:
            for name, origin, extra, count in [('cached-small', 'cached-small', [], 1),
                    ('live-file-io', 'live-file-io', ['--live'], 1),
                    ('repeated-map', 'cached-map_closed', ['--calls', '5'], 5)]:
                case = cases[stage, origin]; target = out/(stage+'-'+name+'.c')
                # The first B2 request exercises selection's default; others name their stage.
                selected = None if stage == 'b2' and name == 'cached-small' else stage
                row, request, directory = invoke(stage+'-'+name, case['source'], target, selected, extra)
                assert row['returncode'] == 0 and request['complete'] and request['stage'] == stage
                assert request['calls'] == count and request['repeatedCEqual'] and len(request['outputs']) == count
                assert same(N.pin(target), case['output'])
                assert all(same(N.verify(item), case['output']) for item in request['outputs'])
                process = request['process']; assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor')
                argv = N.native_args(release, case['source']['file'], directory/'program', count, '--live' in extra, stage)
                assert process['command'][-len(argv):] == argv
                assert diagnostics((directory/'guard/stderr.log').read_text()) == case['diagnostic']
                row.update(passed=True, output=N.pin(target), calls=count, allOutputsExact=True); save()
        existing = out/'b2-cached-small.c'; before = N.pin(existing); small = cases['b2', 'cached-small']
        row, request, directory = invoke('existing-output-refusal', small['source'], existing)
        assert row['returncode'] == 1 and not request['complete'] and 'Output already exists' in request['error']
        assert 'process' not in request and not (directory/'guard').exists() and N.pin(existing) == before
        row.update(passed=True, targetExecuted=False, existingOutputUnchanged=True); save()
        bad = json.loads(args.selection.read_text()); bad['admission']['sha256'] = '0'*64
        bad_pointer = out/'changed-selection.json'; bad_pointer.write_text(json.dumps(bad, indent=2)+'\n')
        target = out/'changed-selection.c'; row, request, directory = invoke('changed-manifest-refusal', small['source'], target, selection=bad_pointer)
        assert row['returncode'] == 1 and not request['complete'] and 'Artifact changed:' in request['error']
        assert 'process' not in request and not (directory/'guard').exists() and not target.exists()
        row.update(passed=True, targetExecuted=False, changedSelection=N.pin(bad_pointer)); save()
        negative = cases['b2', 'negative-0']; target = out/'invalid-source.c'
        row, request, directory = invoke('invalid-source', negative['source'], target)
        process = request['process']; assert row['returncode'] == 1 and not request['complete'] and not target.exists()
        assert process['returncode'] == 1 and not process.get('stoppedFor') and not process.get('interrupted')
        assert isinstance(process.get('finished'), (int, float)) and isinstance(process.get('wallSeconds'), (int, float))
        assert diagnostics((directory/'guard/stderr.log').read_text()) == negative['diagnostic']
        assert not (directory/'program.1.c').exists()
        row.update(passed=True, expectedRejectionObserved=True, outputAbsent=True); save()
        for item in inputs: N.verify(item)
        assert N.load(args.selection) == (release, binding)
        for stage in ['b1', 'b2']: assert N.load(args.selection, stage=stage)[0] == release
        report.pop('current', None); report.update(complete=True, passed=True, inputsUnchanged=True); save()
    except Exception as error:
        report['error'] = str(error); save(); raise
    print(json.dumps(dict(complete=True, passed=True, controls=len(report['rows']), report=N.pin(out/'report.json'))))


if __name__ == '__main__': main()
