#!/usr/bin/env python3
"""Prepare independent genuine-B2 self-check/fixed-point jobs, without execution."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
RAW = ROOT / 'selfhost/build/phase66'
TOOLS = ROOT / 'selfhost/tools/performance'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--image-pins', type=Path, required=True)
p.add_argument('--methods', type=Path, required=True)
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
    assert str(file) not in inputs or inputs[str(file)] == actual
    inputs[str(file)] = actual
    return actual


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


out, target = a.out.resolve(), a.plan.resolve()
assert all(file.is_relative_to(RAW) and not file.exists() for file in [out, target])
methods = a.methods.resolve(strict=True)
assert methods.parent == RAW
method = read(methods / 'methods.json')
assert method['kind'] == 'phase66-final-qualification-methods' and method['complete']
assert not method['targetsExecuted']
factory = Path(__file__).with_name('make-method.py')
assert pin(factory)['sha256'] == '9cf3a9f7902414145223aa4ce7447ad7eab87812b21d65462007aef9d861f566'
assert method['producer'] == pin(factory)
for row in method['rows']:
    text = Path(pin(row['parent'])['file']).read_text()
    for edit in row['edits']:
        assert text.count(edit['old']) == edit['occurrences']
        text = text.replace(edit['old'], edit['new'])
    assert Path(pin(row['output'])['file']).read_text() == text
image = read(a.image_pins)
assert image['kind'] == 'phase56-direct-image-pins'
producer = Path(__file__).parent.parent / 'prepare-bootstrap.py'
assert pin(producer)['sha256'] == 'ac3a0be6991ed85e5603bf8b5de96cc480b539f1a2f76d38577ea27a82ad7a3d'
assert pin(image['producer']) == pin(producer)
for key in ['plan', 'attempt', 'emission', 'comparison', 'source', 'b1', 'b2',
            'runtime', 'rootsReference', 'admission']:
    pin(image[key])
attempt = read(image['attempt'])
assert attempt['checked'] and attempt['config']['strictExact']
assert attempt['artifactKind'] == 'derived-b1' and attempt['node']['version'] == 'v24.18.0'
assert pin(attempt['api']) == image['b1']
assert read(attempt['derivationReport'])['transform']['version'] == 7
bootstrap = read(attempt['bootstrapReport'])
assert bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
assert bootstrap['baseSha256'] == '99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'
assert pin(bootstrap['source']) == image['source']
assert bootstrap['exports'] == image['roots'] and len(image['roots']) == 99
assert len(set(image['roots'])) == 99
snapshot = Path(attempt['snapshot']['root'])
assert pin(snapshot / 'src/runtime/js/direct.mjs') == image['runtime']
assert pin(read(image['admission'])['driver'])['sha256'] == pin(snapshot / 'tools/typed-driver.mjs')['sha256']
validation = read(Path(image['attempt']['file']).parent / 'validation-001/report.json')
assert validation['complete'] and validation['pass'] and validation['strictExact']
assert pin(validation['attempt']) == image['attempt']
assert pin(validation['api']) == image['b1']
assert validation['selected']['exactDifferences'] == 0
emission, comparison = read(image['emission']), read(image['comparison'])
assert emission['complete'] and emission['pass'] and comparison['complete'] and comparison['pass']
assert comparison['observations'] == 8
assert emission['subject']['attempt'] == image['attempt']
assert emission['generator']['api'] == image['b1'] and pin(emission['module']) == image['b2']
tiny = read(emission['qualification'])
assert tiny['complete'] and tiny['pass'] and tiny['splitEqualsUnsplit'] and tiny['planEqualsCompatibility']
node = pin(attempt['node'])['file']
guard = TOOLS / 'phase32/bounded-run.py'
pin(guard)
commands = []
for name, relative, expectation in [
    ('self-check', 'qualification/self-check.mjs',
     dict(freshTypeCheck=True, expectedUnsafeProofTrustRefusal=True, mathematicalProof=False)),
    ('fixed-point', 'bootstrap/reproduce.mjs', dict(b2EqualsB3=True, completeModuleBytes=True)),
]:
    script = methods / relative
    pin(script)
    commands.append(dict(name=name, command=list(map(str, [
        'python3', '-B', guard, '--seconds', 300, '--rss-mib', 2048,
        '--available-mib', 4096, out / (name + '-supervisor'), '--', 'taskset', '-c', 3,
        node, '--stack-size=4096', '--max-old-space-size=1024', script,
        a.image_pins.resolve(), out / name])),
        expected=expectation, guard='One outer ExecutionGuard; no nested guard.'))
pin(__file__)
for row in list(inputs.values()):
    pin(row)
result = dict(kind='phase66-independent-selfhosting-plan', complete=True, executed=False,
              cwd=str(ROOT), out=str(out), producer=pin(__file__), imagePins=pin(a.image_pins),
              attempt=image['attempt'], methods=pin(methods / 'methods.json'),
              inputs=list(inputs.values()), commands=commands,
              scope='Two independent root-run gates for the actual emitted B2. Each creates its own private ordinary-driver cache; no checked B2 receipt is invented. Fresh own-source type acceptance and the unsafe proof-trust verdict stay separate from complete B2/B3 byte equality. Semantic reference acquisition and latency measurement are not prerequisites or outcomes of these jobs.')
target.parent.mkdir(parents=True, exist_ok=True)
with target.open('x') as stream:
    stream.write(json.dumps(result, indent=2) + '\n')
print(json.dumps(dict(plan=pin(target), jobs=2, executed=False)))
