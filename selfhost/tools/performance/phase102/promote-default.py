#!/usr/bin/env python3
"""Check/apply exact candidate04 selection, or collect its actual default smoke."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import stat
import sys
import tempfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
NATIVE = ROOT / 'selfhost/tools/native'
DEFAULT = NATIVE / 'selection.json'
SOURCE = '63ef222c4c6de73bb54c8e51d3b0a0552979b5791ea98e64d1098051a9cda237'
PREVIOUS = '0ec0287c1c5e0b877b16a10e451bce4eb1fffa7b3795fcf634d742ea50772fdf'


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec); spec.loader.exec_module(value)
    return value


N = module('phase102_promotion_host', NATIVE / 'launch.py')
A = module('phase102_promotion_assets', NATIVE / 'assets.py')


def read(record):
    N.verify(record)
    return json.loads(Path(record['file']).read_text())


def save(path, value):
    with path.open('x') as stream:
        json.dump(value, stream, indent=2); stream.write('\n')


def gates(args):
    selection = args.selection.resolve(strict=True)
    assert selection != DEFAULT and selection.is_relative_to(ROOT / 'selfhost/build/phase99')
    release, binding = N.load(selection)
    assert binding['stage'] == 'b2' and release['source']['sha256'] == SOURCE
    assert release['inputsUnchanged'] and release['qualified'] and not release['defaultSelection']
    for stage in ('b1', 'b2'):
        assert N.load(selection, stage=stage)[0] == release
    cli_pin = N.pin(args.cli_report); cli = read(cli_pin)
    assert cli['kind'] == 'bend-native-public-cli-controls' and cli['version'] == 1
    assert cli['complete'] and cli['passed'] and cli['inputsUnchanged']
    assert cli['admission'] == binding
    names = {stage + '-' + case for stage in ('b1', 'b2')
             for case in ('cached-small', 'live-file-io', 'repeated-map')}
    names |= {'existing-output-refusal', 'changed-manifest-refusal', 'invalid-source'}
    assert len(cli['rows']) == 9 and {row['name'] for row in cli['rows']} == names
    pins = [N.pin(__file__), N.pin(NATIVE / 'launch.py'), N.pin(NATIVE / 'assets.py'),
            binding['selection'], binding['admission'], cli_pin]
    for record in cli['inputs']:
        N.verify(record); pins.append(record)
    for row in cli['rows']:
        assert row['passed']
        for key in ('request', 'stdout', 'stderr'):
            N.verify(row[key]); pins.append(row[key])
    capsule_pin = N.pin(args.capsule); capsule = read(capsule_pin)
    assert capsule['kind'] == 'bend-native-public-assets-capsule' and capsule['version'] == 1
    assert capsule['complete'] and capsule['targetJobsRun'] == 0
    assert capsule['method'] == A.identity(NATIVE / 'assets.py')
    archive = A.bound(capsule['archive']); manifest_path = A.bound(capsule['manifest'])
    manifest = json.loads(manifest_path.read_text())
    assert manifest['complete'] and manifest['canonicalRoot'] == str(ROOT)
    assert manifest['selection'] == A.identity(selection)
    assert manifest['admission'] == A.identity(binding['admission']['file'])
    rows, capsule_binding = A.selection(selection)
    assert capsule_binding == binding and manifest['files'] == rows
    assert manifest['rawBytes'] == sum(row['bytes'] for row in rows)
    A.check_archive(archive, rows)
    pins.extend([capsule_pin, N.pin(archive), N.pin(manifest_path)])
    acceptance_pin = N.pin(args.performance_acceptance); acceptance = read(acceptance_pin)
    assert acceptance['kind'] == 'phase102-native-performance-acceptance'
    assert acceptance['complete'] and acceptance['accepted'] and acceptance['inputsUnchanged']
    assert acceptance['source'] == release['source'] and not acceptance.get('error')
    assert isinstance(acceptance['decision'], str) and acceptance['decision'].strip()
    assert acceptance['evidence'] and len({row['file'] for row in acceptance['evidence']}) == len(acceptance['evidence'])
    pins.append(acceptance_pin)
    for record in acceptance['evidence']:
        N.verify(record); pins.append(record)
        if Path(record['file']).suffix == '.json':
            evidence = read(record)
            assert evidence['complete'] and not evidence.get('error'), 'Incomplete performance evidence'
    return release, binding, pins, acceptance_pin, acceptance, len(rows)


def promote(args):
    release, binding, pins, acceptance_pin, acceptance, capsule_files = gates(args)
    old = DEFAULT.read_bytes(); old_mode = stat.S_IMODE(DEFAULT.stat().st_mode)
    assert not DEFAULT.is_symlink() and hashlib.sha256(old).hexdigest() == PREVIOUS
    new = Path(binding['selection']['file']).read_bytes()
    result = dict(kind='phase102-candidate04-default-promotion', complete=False,
        targetsRun=False, applied=False, method=N.pin(__file__), source=release['source'],
        staged=binding, previousSelection=N.pin(DEFAULT), previousMode=old_mode,
        cliReport=N.pin(args.cli_report), stagedCapsule=N.pin(args.capsule),
        capsuleFiles=capsule_files, capsuleMissingFiles=0,
        performanceAcceptance=acceptance_pin, performanceEvidence=acceptance['evidence'],
        performanceAccepted=True, performanceDecision=acceptance['decision'],
        performanceScope='Coordinator decision bound to this exact qualified source and completed evidence; no new statistical or universal performance proof.',
        inputs=pins)
    for record in pins:
        N.verify(record)
    assert DEFAULT.read_bytes() == old and stat.S_IMODE(DEFAULT.stat().st_mode) == old_mode
    assert Path(binding['selection']['file']).read_bytes() == new
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    if args.mode == 'check':
        out.mkdir(parents=True)
        result.update(complete=True, inputsUnchanged=True, scope='Read-only qualification/CLI/capsule/default preflight; selection was not changed.')
        save(out / 'report.json', result)
    else:
        out.mkdir(parents=True)
        backup = out / 'previous-selection.json'
        with backup.open('xb') as stream:
            stream.write(old); stream.flush(); os.fsync(stream.fileno())
            os.fchmod(stream.fileno(), old_mode)
        result['previousSelectionBackup'] = N.pin(backup)
        save(out / 'prepared.json', result)
        with tempfile.NamedTemporaryFile(prefix='.phase102-selection-', dir=DEFAULT.parent, delete=False) as stream:
            stream.write(new); stream.flush(); os.fchmod(stream.fileno(), old_mode); os.fsync(stream.fileno())
            temporary = Path(stream.name)
        try:
            for stage in ('b1', 'b2'):
                assert N.load(args.selection, stage=stage)[0] == release
            assert DEFAULT.read_bytes() == old and stat.S_IMODE(DEFAULT.stat().st_mode) == old_mode
            assert Path(binding['selection']['file']).read_bytes() == new
            for record in pins:
                N.verify(record)
            os.replace(temporary, DEFAULT)
        finally:
            temporary.unlink(missing_ok=True)
        for stage in ('b1', 'b2'):
            assert N.load(DEFAULT, stage=stage)[0] == release
        assert DEFAULT.read_bytes() == new and stat.S_IMODE(DEFAULT.stat().st_mode) == old_mode
        result.update(complete=True, applied=True, inputsUnchanged=True,
            selected=N.pin(DEFAULT), scope='Atomic conditional pointer replacement only. Actual default smoke and stable-default capsule remain separate.')
        save(out / 'report.json', result)
    print(json.dumps(dict(complete=True, applied=result['applied'], report=N.pin(out / 'report.json'))))


def verify_smoke(args):
    promotion_pin = N.pin(args.promotion); promotion = read(promotion_pin)
    assert promotion['complete'] and promotion['applied'] and promotion['source']['sha256'] == SOURCE
    assert N.pin(DEFAULT) == promotion['selected']
    release, binding = N.load(DEFAULT)
    assert binding['stage'] == 'b2' and release['source'] == promotion['source']
    stderr_pin = N.pin(args.stderr); stdout_pin = N.pin(args.stdout)
    assert Path(stdout_pin['file']).read_bytes() == b''
    paths = re.findall(r'^Request evidence: (.+)$', Path(stderr_pin['file']).read_text(), re.M)
    assert len(paths) == 1
    directory = Path(paths[0]); assert directory.parent == ROOT / 'selfhost/build/native/requests'
    request_pin = N.pin(directory / 'report.json'); request = read(request_pin)
    assert request['kind'] == 'bend-native-compiler-request' and request['complete']
    assert request['selection'] == binding and request['stage'] == 'b2'
    assert request['calls'] == 1 and request['live'] is False and request['repeatedCEqual']
    process = request['process']
    assert process['complete'] and process['returncode'] == 0 and not process.get('stoppedFor') and not process.get('interrupted')
    assert json.loads((directory / 'guard/process.json').read_text()) == process
    control_pins = release['receipts']['controls']; assert len(control_pins) == 1
    controls = read(control_pins[0])
    expected = [row for row in controls['rows'] if row['stage'] == 'b2' and row['name'] == 'cached-small']
    assert len(expected) == 1; expected = expected[0]
    assert request['source'] == expected['source'] and len(request['outputs']) == 1
    actual = N.pin(args.output); assert request['output'] == actual
    for record in [actual, *request['outputs'], expected['output']]:
        N.verify(record)
        assert all(record[key] == expected['output'][key] for key in ('sha256', 'bytes'))
    assert Path(actual['file']).read_bytes() == Path(expected['output']['file']).read_bytes()
    argv = N.native_args(release, expected['source']['file'], directory / 'program', 1, False, 'b2')
    assert process['command'][-len(argv):] == argv
    diagnostic = re.sub(r'^(?:base_prepare_ms=\d+|runtime_prepare_ms=\d+|request=\d+ request_ms=\d+ consumed_chars=\d+)\n', '',
                        (directory / 'guard/stderr.log').read_text(), flags=re.M)
    assert diagnostic == expected['diagnostic'] and (directory / 'guard/stdout.log').read_bytes() == b''
    pins = [N.pin(__file__), promotion_pin, binding['selection'], binding['admission'],
            stderr_pin, stdout_pin, request_pin, actual, *control_pins, expected['output']]
    pins.extend(N.pin(directory / 'guard' / name) for name in ('process.json', 'stdout.log', 'stderr.log'))
    for record in pins:
        N.verify(record)
    assert N.load(DEFAULT) == (release, binding)
    out = args.out.resolve(); assert out.is_relative_to(ROOT / 'selfhost/build/phase99') and not out.exists()
    out.mkdir(parents=True)
    report = dict(kind='phase102-candidate04-default-smoke', complete=True, passed=True,
        targetsRun=False, source=release['source'], selection=binding, request=request_pin,
        output=actual, fullCExact=True, fullDiagnosticExact=True, inputsUnchanged=True,
        inputs=pins, scope='Data-only verification of the recorded actual public request using the stable default pointer; the coordinator ran that request separately.')
    save(out / 'report.json', report)
    print(json.dumps(dict(complete=True, passed=True, request=request_pin, report=N.pin(out / 'report.json'))))


def main():
    parser = argparse.ArgumentParser(description=__doc__); sub = parser.add_subparsers(dest='mode', required=True)
    for mode in ('check', 'apply'):
        current = sub.add_parser(mode)
        for key in ('selection', 'cli-report', 'capsule', 'performance-acceptance', 'out'):
            current.add_argument('--' + key, type=Path, required=True)
    smoke = sub.add_parser('verify-smoke')
    for key in ('promotion', 'stdout', 'stderr', 'output', 'out'):
        smoke.add_argument('--' + key, type=Path, required=True)
    args = parser.parse_args()
    if args.mode == 'verify-smoke': verify_smoke(args)
    else: promote(args)


if __name__ == '__main__': main()
