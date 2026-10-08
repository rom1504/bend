#!/usr/bin/env python3
"""Prepare final new-upstream B1 or genuine-B2 gates; never run a target."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
TOOLS = ROOT / 'selfhost/tools/performance'
RAW = ROOT / 'selfhost/build/phase66'
PIN = '059266225b77c8ca256ac6b25ee5c21449bab151'
BASE = '99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'
FACTORY = Path(__file__).with_name('make-method.py')
FACTORY_SHA = '9cf3a9f7902414145223aa4ce7447ad7eab87812b21d65462007aef9d861f566'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('stage', choices=['checked', 'b2'])
p.add_argument('--methods', type=Path, required=True)
p.add_argument('--attempt', type=Path, required=True)
p.add_argument('--image-pins', type=Path)
p.add_argument('--program-manifest', type=Path)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--plan', type=Path, required=True)
a = p.parse_args()
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item.get('file', item.get('path')) if item else value).resolve(strict=True)
    actual = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if item:
        assert actual['sha256'] == item['sha256'], file
        if 'bytes' in item:
            assert file.stat().st_size == item['bytes'], file
    assert str(file) not in inputs or actual == inputs[str(file)]
    inputs[str(file)] = actual
    return actual


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def fresh(value):
    file = value.resolve()
    assert file.is_relative_to(RAW) and not file.exists(), file
    return file


out, plan_path = fresh(a.out), fresh(a.plan)
methods = a.methods.resolve(strict=True)
assert methods.parent == RAW
method = read(methods / 'methods.json')
assert method['kind'] == 'phase66-final-qualification-methods' and method['complete']
assert pin(FACTORY)['sha256'] == FACTORY_SHA
assert method['producer'] == pin(FACTORY)
assert method['targetsExecuted'] is False
for row in method['rows']:
    source = Path(pin(row['parent'])['file']).read_text()
    for edit in row['edits']:
        assert source.count(edit['old']) == edit['occurrences']
        source = source.replace(edit['old'], edit['new'])
    assert Path(pin(row['output'])['file']).read_text() == source
here = methods / 'qualification'
attempt_path = a.attempt.resolve(strict=True)
attempt_pin = pin(attempt_path / 'attempt.json')
attempt = read(attempt_pin)
assert attempt['checked'] and attempt['config']['strictExact']
assert attempt['artifactKind'] == 'derived-b1'
assert attempt['node']['version'] == 'v24.18.0'
for key in ['api', 'runtime', 'base', 'node', 'bootstrapReport', 'derivationReport']:
    pin(attempt[key])
bootstrap = read(attempt['bootstrapReport'])
assert bootstrap['revision'] == PIN and bootstrap['baseSha256'] == BASE
derivation = read(attempt['derivationReport'])
assert derivation['complete'] and derivation['transform']['version'] == 7
assert derivation['output']['sha256'] == attempt['api']['sha256']
validation = read(attempt_path / 'validation-001/report.json')
assert validation['complete'] and validation['pass'] and validation['strictExact']
assert pin(validation['attempt']) == attempt_pin
assert validation['api']['sha256'] == attempt['api']['sha256']
assert validation['selected']['exactDifferences'] == 0
node = attempt['node']['file']
snapshot = Path(attempt['snapshot']['root'])
assert read(snapshot / 'src/compiler.json')['upstream'] == PIN
for row in attempt['snapshot']['sources']:
    pin(row['frozen'])
reference_recipe = read(RAW / 'head-semantic-inputs/recipe.json')
assert reference_recipe['kind'] == 'phase66-fresh-head-semantic-references'
assert reference_recipe['complete'] and reference_recipe['targetExecuted'] is False
references = {}
for row in reference_recipe['catalogs']:
    catalog = read(row['catalog'])
    reference = read(row['targetManifest'])
    assert catalog['upstreamCommit'] == PIN
    assert reference['complete'] and reference['passed']
    assert reference['catalog'] == pin(row['catalog'])
    assert set(reference['roles']) == {'typescript'}
    references[row['name']] = dict(catalog=Path(row['catalog']['file']),
                                  manifest=Path(row['targetManifest']))
assert set(references) == {'source', 'numeric', 'composition', 'overapplication'}
catalog_path = RAW / 'head-ts-inputs/catalog.json'
catalog = read(catalog_path)
assert catalog['upstreamCommit'] == PIN and len(catalog['sets']['full']) == 45
assert pin(catalog_path)['sha256'] == 'd183b7d6a1acee6671c680530d944a1588dce211f65de55eba02397cc18338fd'
commands = []


def command(name, argv, **extra):
    commands.append(dict(name=name, command=list(map(str, argv)), **extra))


def bounded(name, script, args, seconds, expected):
    pin(script)
    guard = TOOLS / 'phase32/bounded-run.py'
    pin(guard)
    command(name, ['python3', '-B', guard, '--seconds', seconds, '--rss-mib', 2048,
                  '--available-mib', 4096, out / (name + '-supervisor'), '--',
                  'taskset', '-c', 3, node, '--stack-size=4096',
                  '--max-old-space-size=1024', script, *args],
            guard='One outer ExecutionGuard; target CPU3.', expected=expected)


image_pin = None
if a.stage == 'b2':
    assert a.image_pins and a.program_manifest
    image_pin = pin(a.image_pins)
    image = read(image_pin)
    assert image['kind'] == 'phase56-direct-image-pins'
    producer = Path(__file__).parent.parent / 'prepare-bootstrap.py'
    assert pin(producer)['sha256'] == 'ac3a0be6991ed85e5603bf8b5de96cc480b539f1a2f76d38577ea27a82ad7a3d'
    assert pin(image['producer']) == pin(producer)
    assert pin(image['attempt']) == attempt_pin
    assert image['b1'] == pin(attempt['api'])
    assert image['source']['sha256'] == bootstrap['sourceSha256']
    assert image['runtime'] == pin(snapshot / 'src/runtime/js/direct.mjs')
    assert image['roots'] == bootstrap['exports']
    for name in ['producer', 'plan', 'attempt', 'emission', 'comparison', 'source',
                 'b1', 'b2', 'runtime', 'rootsReference', 'admission']:
        pin(image[name])
    for name in ['emission', 'comparison']:
        receipt = read(image[name])
        assert receipt['complete'] and receipt['pass']
    admission = read(image['admission'])
    assert pin(admission['driver'])['sha256'] == pin(snapshot / 'tools/typed-driver.mjs')['sha256']
    bounded('self-check', here / 'self-check.mjs', [a.image_pins, out / 'self-check'],
            300, dict(freshTypeCheck=True, mathematicalProof=False))
    bounded('fixed-point', methods / 'bootstrap/reproduce.mjs',
            [a.image_pins, out / 'fixed-point'], 300, dict(b2EqualsB3=True))
else:
    assert a.image_pins is None and a.program_manifest is None

for name, count, seconds in [('source', 96, 180), ('numeric', 34, 120),
                              ('composition', 18, 90), ('overapplication', 2, 90)]:
    reference = references[name]
    acquisition = out / (name + '-acquisition')
    if a.stage == 'checked':
        script = TOOLS / 'phase52/acquire-semantics-v2.py'
        pin(script)
        command('acquire-' + name,
                ['python3', '-B', script, '--role', 'direct', '--selection',
                 attempt_path, '--catalog', reference['catalog'], '--out', acquisition],
                guard='Internal sole ExecutionGuard; serial CPU3 checked emissions.')
        manifest = acquisition / 'manifest.json'
        if name == 'source':
            join = Path(__file__).with_name('join-source.py')
            pin(join)
            command('join-source', ['python3', '-B', join, '--direct', manifest,
                                    '--typescript', reference['manifest'],
                                    '--out', out / 'source-join.json'], guard='Data only.')
            manifest = out / 'source-join.json'
        script = here / ('checked-' + name + '-controls.mjs')
    else:
        bounded('acquire-' + name, here / 'acquire.mjs',
                [a.image_pins, reference['catalog'], reference['manifest'], acquisition],
                300, dict(freshCheckedEmission=True))
        manifest = acquisition / 'manifest.json'
        script = here / (name + '-controls.mjs')
    arguments = [manifest, reference['manifest'], out / (name + '-controls')]
    if name == 'source':
        arguments = [manifest, out / 'source-controls']
    if name == 'numeric':
        standard = out / ('source-join.json' if a.stage == 'checked' else 'source-acquisition/manifest.json')
        arguments.insert(0, standard)
    bounded(name + '-controls', script, arguments, seconds,
            dict(candidateObservations=count, referencePasses='Measured, never inherited.'))

if a.stage == 'checked':
    maintained = TOOLS / 'phase47/qualify.py'
    acquisition = TOOLS / 'phase53/acquire.py'
    smoke = TOOLS / 'phase52/smoke.py'
    for script in [maintained, acquisition, smoke]:
        pin(script)
    command('maintained8', ['python3', '-B', maintained, attempt_path, out / 'maintained8'],
            guard='Internal sole ExecutionGuard.', expected=dict(suites=8))
    command('program45-acquisition', ['python3', '-B', acquisition, '--attempt', attempt_path,
            '--catalog', catalog_path, '--set', 'full', '--role', 'candidate', '--backend',
            'direct', '--cpu', 3, '--heap-mib', 1024, '--rss-mib', 2048,
            '--available-mib', 4096, '--node', node, '--out', out / 'program45'],
            guard='Internal sole ExecutionGuard.', expected=dict(sources=23, points=45))
    command('program45-smoke', ['python3', '-B', smoke, '--manifest', out / 'program45/manifest.json',
            '--catalog', catalog_path, '--out', out / 'program45-smoke', '--node', node],
            guard='Internal sole ExecutionGuard.', expected=dict(passed=True, points=45))
    baseline = ROOT / 'selfhost/build/phase58/checked-last01'
    assert read(baseline / 'attempt.json')['api']['sha256'] == '641381f638f1f4c1c8b349bef06502b42738c1c7feff0391f2e09b90f4ef282a'
    bounded('native3', here / 'native3.mjs', [baseline, attempt_path, out / 'native3'],
            300, dict(baselineOracles=3, candidateOracles=3, oldNewCByteEquality='Descriptive.'))
    commands[-1]['environment'] = read(TOOLS / 'phase55/semantic-plan-v1.json')['nativeEnvironment']
else:
    manifest = read(a.program_manifest)
    assert manifest['complete'] and manifest['upstreamCommit'] == PIN
    assert manifest['roles']['candidate']['compiler']['api']['sha256'] == attempt['api']['sha256']
    bounded('b2-program-equality', here / 'benchmark-equality.mjs',
            [a.image_pins, a.program_manifest, out / 'b2-program-equality'], 240,
            dict(rawByteEqualModules=23, pointByteEqual=45))

pin(__file__)
for row in list(inputs.values()):
    pin(row)
plan = dict(kind='phase66-final-qualification-launch-plan', complete=True, executed=False,
            cwd=str(ROOT), stage=a.stage, out=str(out), attempt=attempt_pin,
            imagePins=image_pin, methods=pin(methods / 'methods.json'),
            producer=pin(__file__), inputs=list(inputs.values()), commands=commands,
            resources=dict(cpu=3, heapMiB=1024, stackKiB=4096, treeRssMiB=2048,
                           availableMiB=4096, serial=True),
            scope='Fresh new-pin semantic references and unchanged independent candidate oracles. Counts overlap. Checked B1 and genuine emitted B2 are distinct. B2 own-source type acceptance retains the expected unsafe proof-trust refusal; fixed-point equality is a separate complete-byte check. Compiler latency, full new frontend/backend corpus, generated-program timing and release installation are separately admitted gates. No target or installation has run through this planner.')
plan_path.parent.mkdir(parents=True, exist_ok=True)
with plan_path.open('x') as stream:
    stream.write(json.dumps(plan, indent=2) + '\n')
print(json.dumps(dict(plan=pin(plan_path), commands=len(commands), executed=False)))
