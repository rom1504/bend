#!/usr/bin/env python3
"""Snapshot and build the experimental Bend IR producer; never changes a release."""
import argparse
import importlib.util
import json
import sys
import time
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('phase106_campaign', HERE / 'campaign.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
pin, read, save = C.pin, C.read, C.save


def verify(item):
    assert pin(item['file']) == item, ('changed input', item['file'])


def same_content(actual, expected):
    assert all(actual[k] == expected[k] for k in ('bytes', 'sha256')), ('content mismatch', actual, expected)


def prepare(out, checked_source=None):
    assert not out.exists(), 'Use a fresh output directory'
    out.mkdir(parents=True)
    report = dict(kind='phase106-bend-ir-producer', version=1, complete=False,
                  prepared=False, started=time.time(), method=pin(__file__),
                  scope='Native Bend-produced experimental IR constructor/verifier/emitter. '
                  'Not a new installed compiler, whole-compiler backend or bootstrap fixed point.')
    save(out / 'report.json', report)
    try:
        sources = [HERE / 'ir' / (name + '.bend') for name in
                   ['model', 'optimize', 'verify', 'json', 'c', 'workloads']]
        sources += [HERE / 'laws/bridge.bend', HERE / 'ir/main.bend']
        report['sourceInputs'] = [pin(p) for p in sources]
        snapshot = out / 'source'
        snapshot.mkdir()
        for index, source in enumerate(sources):
            (snapshot / (str(index) + '-' + source.name)).write_bytes(source.read_bytes())
        text = 'import Base\n\n' + '\n\n'.join(p.read_text() for p in sources)
        source = out / 'producer.bend'
        source.write_text(text)
        report['source'] = pin(source)
        if checked_source:
            report['checkedSource'] = pin(checked_source)
            same_content(report['source'], report['checkedSource'])
            report['checkedSourceScope'] = 'Exact source correspondence only; caller retains its check verdict.'

        release_dir = ROOT / 'selfhost/tools/native/releases/phase103-cli01'
        native_record = release_dir / 'records/native.json'
        native = read(native_record)
        assert native['complete'] and native['generatedCUnmodified']
        compiler = (ROOT / 'selfhost/bend').resolve(strict=True)
        report['compiler'] = pin(compiler)
        same_content(report['compiler'], native['binary'])
        report['toolchain'] = native['toolchain']
        report['startup'] = native['startup']
        verify(report['toolchain']); verify(report['startup'])
        report['nativeRecord'] = pin(native_record)
        package = release_dir / 'receipt.json'
        receipt = read(package)
        assert receipt['complete'] and receipt['kind'] == 'phase103-native-cli-package'
        report['packageReceipt'] = pin(package)
        report['assets'] = []
        for item in receipt['files']:
            if item['file'].startswith('assets/'):
                actual = pin(compiler.parent / item['file'])
                same_content(actual, item)
                report['assets'].append(actual)
        assert len(report['assets']) == 16
        report['methods'] = [pin(HERE / 'campaign.py'),
                             pin(HERE.parent / 'phase86/guard.py'),
                             pin(HERE.parent / 'phase46/execute.py'),
                             pin(HERE.parent / 'programs/support.py')]
        report['prepared'] = True
        report['preparedAt'] = time.time()
        unchanged(report)
    except Exception as error:
        report['error'] = str(error)
        raise
    finally:
        save(out / 'report.json', report)
    return report


def unchanged(report):
    for key in ['method', 'source', 'compiler', 'toolchain', 'startup', 'nativeRecord', 'packageReceipt']:
        verify(report[key])
    for item in report['sourceInputs'] + report['assets'] + report['methods']:
        verify(item)
    if 'checkedSource' in report:
        verify(report['checkedSource'])


def build(out):
    report = read(out / 'report.json')
    assert report['prepared'] and not report['complete'] and 'error' not in report
    jobs = C.Jobs(out)
    try:
        unchanged(report)
        report['buildStarted'] = time.time()
        save(out / 'report.json', report)
        generated = out / 'producer.c'
        emitted = jobs.run('native-emission',
                           [report['compiler']['file'], report['source']['file'], '-o', generated],
                           seconds=120)
        assert emitted['stdout'] == '', 'Native CLI unexpectedly wrote stdout'
        report['generatedC'] = pin(generated)
        report['emissionSeconds'] = emitted['processSeconds']
        report['emissionReceipt'] = pin(out / 'jobs/native-emission.child.json')
        save(out / 'report.json', report)
        clang = Path(report['toolchain']['file'])
        include = clang.parents[1] / 'include/clang'
        assert include.is_dir()
        binary = out / 'producer'
        # The existing adapter keeps one argv[0] slot for this native runtime,
        # forces one worker/GPU off, and forwards c/json/workload/policy intact.
        argv = [clang, '-O2', '-isystem', include, '-DBEND_NATIVE_HOST=1',
                '-DBEND_IMAGE_C=' + json.dumps(str(generated)), report['startup']['file'],
                '-lm', '-pthread', '-o', binary]
        linked = jobs.run('producer-build', argv, seconds=180)
        report['binary'] = pin(binary)
        report['buildSeconds'] = linked['processSeconds']
        report['buildReceipt'] = pin(out / 'jobs/producer-build.child.json')
        report['buildCommand'] = list(map(str, argv))
        unchanged(report)
        verify(report['generatedC'])
        report.update(complete=True, inputsUnchanged=True, generatedCUnmodified=True)
    except Exception as error:
        report['error'] = str(error)
        raise
    finally:
        report['finished'] = time.time()
        report['jobs'] = jobs.rows
        save(out / 'report.json', report)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['prepare', 'build', 'all'])
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--checked-source', type=Path)
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase106')
    if args.action in ('prepare', 'all'):
        prepare(out, args.checked_source)
    else:
        assert args.checked_source is None, '--checked-source belongs to prepare/all'
    if args.action in ('build', 'all'):
        build(out)
    print(json.dumps(dict(output=str(out / 'report.json'), complete=read(out / 'report.json')['complete'])))


if __name__ == '__main__':
    main()
