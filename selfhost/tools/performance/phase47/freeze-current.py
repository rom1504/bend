#!/usr/bin/env python3
"""Publish fresh portable benchmark bundles; no compiler or generated execution.

Run on CPU0 only after timed work has stopped. The unchanged Phase44 freezer
audits the full candidate acquisition; its original outputs remain preserved.
This tool neither installs a compiler nor asserts release qualification.
"""
import argparse
import copy
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
TOOLS = HERE.parent
sys.path.insert(0, str(TOOLS / 'programs'))
from run import load_bundle, relative_path
from support import identity


def save(file, value):
    with Path(file).open('x') as stream:
        json.dump(value, stream, indent=2)
        stream.write('\n')


def inventory(directory):
    rows = []
    for file in sorted(Path(directory).rglob('*')):
        assert not file.is_symlink(), file
        if file.is_file():
            rows.append(identity(file))
    return rows


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--from', dest='origin', type=Path, required=True)
    p.add_argument('--attempt', type=Path, required=True)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True, help='Fresh candidate bundle directory')
    p.add_argument('--baseline-out', type=Path, required=True, help='Fresh baseline bundle directory')
    p.add_argument('--method-out', type=Path, required=True, help='Fresh preserved freezer output directory')
    p.add_argument('--catalog', type=Path, default=TOOLS / 'phase37/catalog.json')
    p.add_argument('--expected-api', required=True)
    p.add_argument('--expected-runtime', required=True)
    p.add_argument('--baseline-api', default='e77c504a9c91d9ae9d43e52f4f4899711eb7a8ebe707ee565348df2708488b4c')
    p.add_argument('--baseline-runtime', default='4f057842e476d01be5cfa06ad7984fea55ad2537b2fe6e861965a782e8b94c26')
    p.add_argument('--label', required=True, help='Descriptive benchmark-candidate label; not an installation claim')
    a = p.parse_args()
    assert os.sched_getaffinity(0) == {0}, 'Run with taskset -c 0 after timed work ends'
    origin, baseline, catalog_file = [x.resolve(strict=True) for x in [a.origin, a.baseline, a.catalog]]
    attempt_file = (a.attempt / 'attempt.json' if a.attempt.is_dir() else a.attempt).resolve(strict=True)
    out, baseline_out, method = [x.resolve() for x in [a.out, a.baseline_out, a.method_out]]
    destinations = [out, baseline_out, method]
    assert len(set(destinations)) == 3
    for target in destinations:
        assert not target.exists(), 'Output must be fresh: ' + str(target)
        assert not target.is_relative_to(TOOLS / 'phase45'), 'Phase45 bundles are immutable'
        for other in destinations:
            assert target == other or not target.is_relative_to(other), 'Overlapping outputs'
        assert not target.is_relative_to(origin.parent) and not target.is_relative_to(baseline.parent)
    freezer = TOOLS / 'phase44/products/freeze-candidate-v1.py'
    pins = {}

    def pin(file, expected=None):
        row = identity(file)
        if expected:
            assert row['sha256'] == expected['sha256']
            assert 'bytes' not in expected or row['bytes'] == expected['bytes']
        assert row['path'] not in pins or pins[row['path']] == row
        pins[row['path']] = row
        return row

    for file in [__file__, freezer, TOOLS / 'programs/run.py', TOOLS / 'programs/support.py',
                 TOOLS / 'programs/prepare.py', attempt_file, origin, baseline, catalog_file, sys.executable]:
        pin(file)
    read = lambda f: json.loads(Path(f).read_text())
    attempt, catalog, base_manifest = read(attempt_file), read(catalog_file), read(baseline)
    assert attempt['checked'] is True
    assert attempt['api']['sha256'] == a.expected_api and attempt['runtime']['sha256'] == a.expected_runtime
    for key in ['api', 'runtime', 'base']:
        pin(attempt[key]['file'], attempt[key])
    assert len(catalog['cases']) == 45 and len(base_manifest['cases']) == 45
    assert 'archive' in base_manifest and 'provenance' in base_manifest
    checks = []
    base_bundle = load_bundle(baseline, catalog, pin(catalog_file)['sha256'], catalog['cases'], ['baseline', 'typescript'], checks)
    for row in checks:
        pin(row['path'], row)
    base_compiler = base_bundle['roles']['baseline']['compiler']
    assert base_compiler['api']['sha256'] == a.baseline_api and base_compiler['runtime']['sha256'] == a.baseline_runtime
    assert base_bundle['roles']['typescript']['compiler']['kind'] == 'checked-pinned-typescript'
    assert base_bundle['roles']['typescript']['compiler']['upstreamCommit'] == catalog['upstreamCommit']
    base_provenance = relative_path(baseline.parent, base_manifest['provenance']['path'])
    pin(base_provenance, base_manifest['provenance'])
    assert read(base_provenance)['complete'] is True
    protected = {str(p.parent): inventory(p.parent) for p in (TOOLS / 'phase45').glob('*/manifest.json')}
    command = [sys.executable, str(freezer), '--from', str(origin), '--attempt', str(attempt_file),
               '--catalog', str(catalog_file), '--out', str(method)]
    completed = subprocess.run(command, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert completed.returncode == 0, completed.stderr
    original = read(method / 'manifest.json')
    method_pins = inventory(method)
    for row in method_pins:
        pin(row['path'], row)
    assert original['preservation']['byteExact'] and original['preservation']['reopenedVerified']
    compiler = original['roles']['candidate']['compiler']
    assert compiler['api']['sha256'] == a.expected_api and compiler['runtime']['sha256'] == a.expected_runtime
    assert read(method / 'provenance.json')['attempt']['sha256'] == pin(attempt_file)['sha256']
    out.mkdir(parents=True)
    baseline_out.mkdir(parents=True)
    for name in ['manifest.json', base_manifest['archive']['path'], base_manifest['provenance']['path']]:
        source = relative_path(baseline.parent, name)
        target = relative_path(baseline_out, name)
        target.parent.mkdir(parents=True, exist_ok=True)
        assert not target.exists()
        shutil.copyfile(source, target)
        assert pin(source)['sha256'] == pin(target)['sha256']
    for source, name in [('programs.tar.gz', 'programs.tar.gz'), ('provenance.json', 'provenance.json'),
                         ('manifest.json', 'freeze-candidate-manifest.json')]:
        shutil.copyfile(method / source, out / name)
        assert pin(method / source)['sha256'] == pin(out / name)['sha256']
    relative = lambda f: {**identity(f), 'path': Path(f).relative_to(out).as_posix()}
    derived = copy.deepcopy(original)
    derived['roles']['candidate']['label'] = a.label
    derivation = dict(kind='phase47-portable-candidate-label-derivation', complete=True,
        producer=pin(__file__), originalManifest=relative(out / 'freeze-candidate-manifest.json'),
        originalLabel=original['roles']['candidate']['label'], newLabel=a.label,
        attempt=pin(attempt_file), api=attempt['api'], runtime=attempt['runtime'],
        scope='Only the role label and labelDerivation pointer differ from the audited freezer manifest. No compilation, generated execution, installation or release qualification is asserted.')
    save(out / 'label-derivation.json', derivation)
    derived['labelDerivation'] = relative(out / 'label-derivation.json')
    save(out / 'manifest.json', derived)
    restored = copy.deepcopy(derived)
    restored.pop('labelDerivation')
    restored['roles']['candidate']['label'] = derivation['originalLabel']
    assert restored == original
    verified = []
    load_bundle(out / 'manifest.json', catalog, pin(catalog_file)['sha256'], catalog['cases'], ['candidate'], verified)
    load_bundle(baseline_out / 'manifest.json', catalog, pin(catalog_file)['sha256'], catalog['cases'], ['baseline', 'typescript'], verified)
    for row in verified:
        pin(row['path'], row)
    for file, row in pins.items():
        assert identity(file) == row, 'Input changed: ' + file
    for directory, rows in protected.items():
        assert inventory(directory) == rows, 'Phase45 bundle changed'
    save(out / 'publication.json', dict(kind='phase47-portable-benchmark-publication', complete=True,
        compilerExecuted=False, generatedProgramsExecuted=False, compilerInstalledByTool=False,
        producer=pin(__file__), attempt=pin(attempt_file), api=attempt['api'], runtime=attempt['runtime'],
        points=45, runtimeModules=len({r['modules']['candidate']['sha256'] for r in derived['cases']}),
        methodManifest=pin(method / 'manifest.json'), candidateManifest=pin(out / 'manifest.json'),
        baselineManifest=pin(baseline_out / 'manifest.json'), archive=pin(out / 'programs.tar.gz'),
        preservation=original['preservation'], inputs=list(pins.values()),
        baselineCopies=inventory(baseline_out), candidateFiles=inventory(out),
        protectedBefore=protected, protectedUnchanged=True,
        freezerCommand=command, freezerStdout=completed.stdout, freezerStderr=completed.stderr,
        scope='Data-only portable benchmark packaging and all45 reader verification. Historical method output and labels preserved. Compiler installation and qualification remain separate receipts.'))
    print(json.dumps(dict(complete=True, points=45, current=str(out / 'manifest.json'),
                          baseline=str(baseline_out / 'manifest.json'), archive=identity(out / 'programs.tar.gz'))))


if __name__ == '__main__':
    main()
