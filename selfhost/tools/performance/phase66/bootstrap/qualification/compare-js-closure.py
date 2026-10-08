#!/usr/bin/env python3
"""Prove exact JavaScript closure identity across two real checked snapshots."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT / 'selfhost/build/phase66'
PIN = '059266225b77c8ca256ac6b25ee5c21449bab151'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--baseline', type=Path, required=True)
p.add_argument('--candidate', type=Path, required=True)
p.add_argument('--native-manifest', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if item:
        assert row['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert file.stat().st_size == item['bytes'], file
    assert str(file) not in inputs or inputs[str(file)] == row
    inputs[str(file)] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def inspect(directory):
    identity = pin(directory / 'attempt.json')
    attempt = read(identity)
    assert attempt['kind'] == 'bend-development-attempt' and attempt['checked']
    assert attempt['artifactKind'] == 'derived-b1' and attempt['config']['strictExact']
    assert attempt['node']['version'] == 'v24.18.0'
    for key in ['api', 'checkedApi', 'runtime', 'base', 'node', 'bootstrapReport', 'derivationReport']:
        pin(attempt[key])
    validation_pin = pin(directory / 'validation-001/report.json')
    validation = read(validation_pin)
    assert validation['complete'] and validation['pass'] and validation['strictExact']
    assert pin(validation['attempt']) == identity
    assert pin(validation['api']) == pin(attempt['api'])
    assert validation['selected']['exactDifferences'] == 0
    bootstrap = read(attempt['bootstrapReport'])
    assert bootstrap['revision'] == PIN and bootstrap['provenance']['verifiedAfterBuild']
    assert bootstrap['provenance']['upstream']['trackedSourcesClean']
    assert bootstrap['apiSha256'] == attempt['checkedApi']['sha256']
    source = pin(dict(file=bootstrap['source'], sha256=bootstrap['sourceSha256']))
    derivation = read(attempt['derivationReport'])
    assert derivation['complete'] and not derivation['newBootstrap']
    assert derivation['transform']['version'] == 7
    assert pin(derivation['original']['api']) == pin(attempt['checkedApi'])
    assert pin(derivation['original']['bootstrapReport']) == pin(attempt['bootstrapReport'])
    assert pin(derivation['output']) == pin(attempt['api'])
    pin(derivation['toolSnapshot'])
    snapshot = Path(attempt['snapshot']['root']).resolve(strict=True)
    files = {}
    for row in attempt['snapshot']['sources']:
        frozen = pin(row['frozen'])
        relative = str(Path(frozen['file']).relative_to(snapshot))
        assert relative not in files
        assert row['original']['sha256'] == frozen['sha256']
        files[relative] = frozen
    manifest = read(snapshot / 'src/compiler.json')
    assert manifest['upstream'] == PIN and manifest['targetVersion'] == '2.0.36'
    return dict(identity=identity, attempt=attempt, validation=validation_pin,
                bootstrap=bootstrap, source=source, derivation=derivation, files=files)


baseline, candidate = inspect(a.baseline.resolve(strict=True)), inspect(a.candidate.resolve(strict=True))
assert baseline['identity'] != candidate['identity'], 'Both real attempts must remain distinct.'
assert baseline['attempt']['config'] == candidate['attempt']['config']
assert baseline['files'].keys() == candidate['files'].keys(), 'Snapshot membership changed.'
assert baseline['source']['sha256'] == candidate['source']['sha256']
for key in ['api', 'checkedApi', 'runtime', 'base', 'node']:
    assert baseline['attempt'][key]['sha256'] == candidate['attempt'][key]['sha256'], key
assert baseline['derivation']['transform'] == candidate['derivation']['transform']
assert baseline['bootstrap']['exports'] == candidate['bootstrap']['exports']
modules = lambda record: [(row['file'], row['sha256']) for row in record['bootstrap']['modules']]
assert modules(baseline) == modules(candidate)
native_manifest_pin = pin(a.native_manifest)
native_manifest = read(native_manifest_pin)
declared = {}
for row in native_manifest['files']:
    relative = str(Path(row['relative']).relative_to('selfhost'))
    assert relative.startswith('src/runtime/native/') and relative not in declared
    declared[relative] = pin(row['after'])
assert declared
changes = []
unchanged = []
for relative in sorted(baseline['files']):
    before, after = baseline['files'][relative], candidate['files'][relative]
    if before['sha256'] == after['sha256']:
        unchanged.append(relative)
        continue
    assert relative in declared, 'Unexpected non-admitted snapshot delta: ' + relative
    assert after['sha256'] == declared[relative]['sha256']
    changes.append(dict(relative=relative, before=before, after=after))
assert {row['relative'] for row in changes} == declared.keys()
assert all(relative in unchanged for relative in [
    'src/compiler.json', 'src/runtime.mjs', 'src/runtime/js/direct.mjs',
    'src/runtime/js/effs/manifest.json', 'tools/typed-driver.mjs',
    'tools/base-cache-graph.mjs', 'tools/compiler-abi.mjs', 'tools/native-build.mjs',
    'tools/stage0-library.mjs', 'tools/development/equality.mjs',
    'tools/development/workflow.mjs', 'tools/development/release.mjs'])
assert all(relative in unchanged for relative in baseline['files'] if relative.endswith('.bend'))
pin(__file__)
for row in list(inputs.values()):
    pin(row)
out = a.out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
result = dict(kind='phase66-exact-javascript-closure-reuse-eligibility', complete=True,
              dataOnly=True, targetExecuted=False, producer=pin(__file__),
              baseline=baseline['identity'], candidate=candidate['identity'],
              baselineValidation=baseline['validation'], candidateValidation=candidate['validation'],
              upstream=PIN, sourceSha256=candidate['source']['sha256'],
              api=pin(candidate['attempt']['api']), checkedApi=pin(candidate['attempt']['checkedApi']),
              nativeManifest=native_manifest_pin, changes=changes,
              unchangedSnapshotFiles=unchanged, inputs=list(inputs.values()),
              eligibleForExactJavaScriptReuse=True, nativeQualificationTransferred=False,
              scope='Two genuine checked attempts with fresh strict validation remain distinct. Every frozen file outside the explicit native runtime delta, every Bend module, assembled source, raw/derived API, Base, Node, host tool and JavaScript provider is byte-identical. This permits separately joined completed JavaScript/interpreter/compiler evidence to cover the successor. It does not invent a B2 bootstrap receipt, mark any pending test passed, transfer native output or performance evidence, or admit installation. Fresh native and installed-release gates remain mandatory.')
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    stream.write(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(output=pin(out), nativeChanges=len(changes), unchanged=len(unchanged), targetExecuted=False)))
