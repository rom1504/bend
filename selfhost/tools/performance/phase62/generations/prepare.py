#!/usr/bin/env python3
"""Materialize the frozen Phase61 method in Phase62; never execute a target."""
import argparse
import ast
import hashlib
import json
import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
PARENT = ROOT / 'selfhost/build/phase61/latency-method06'
RAW = ROOT / 'selfhost/build/phase62'
PINS = {
    'run.py': '89cfb11703db68afa2e7ace2818b684b9196406cd947b7350a80a95453478abc',
    'worker.mjs': '71106a64873d5001a19af8c47e6eb85592d93f07efc578b1cf31781941a953b8',
    'setup.mjs': '171b36cc8ceb283f22990751bd15587e3f525f0f46d1acf04cfcde08b2b6f5a6',
    'profile.mjs': 'f71444b4ab44ee49036d1cb70f06b6da9e28e71500619dbb378183ad3e26407b',
}
CASES = 'numeric-recurrence,test-map-set-ops,lexer,raytrace-active'


def identity(value):
    file = Path(value['file'] if isinstance(value, dict) else value).resolve(strict=True)
    result = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if isinstance(value, dict):
        assert result['sha256'] == value['sha256'], str(file)
    return result


def read(value):
    return json.loads(Path(identity(value)['file']).read_text())


def save(file, value):
    file.write_text(json.dumps(value, indent=2) + '\n')


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('out', type=Path)
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
method = out / 'method'
source_binding_id = identity(ROOT / 'selfhost/build/phase61/state08-b2-latency01/bindings.json')
source_binding = read(source_binding_id)
b2 = source_binding['roles']['candidate']
attempt = read(b2['attempt'])
boot = read(attempt['bootstrapReport'])
emission = read(b2['emission'])
source = identity(boot['source'])
assert attempt['checked'] is True and attempt['config']['profile'] == 'equality'
assert source['sha256'] == boot['sourceSha256'] == emission['checking']['sourceSha256']
assert identity(emission['subject']['source']) == source
assert identity(emission['subject']['attempt']) == identity(b2['attempt'])
assert identity(emission['generator']['attempt']) == identity(b2['attempt'])
assert identity(emission['generator']['api']) == identity(attempt['api'])
assert emission['complete'] is True and emission['pass'] is True
assert identity(attempt['api'])['sha256'] == '97f412afb692cc9f187144e418fb153f35f62fb6ff5eda698e28ebc3eaf260c8'
assert identity(emission['module'])['sha256'] == '23bd6a48b9ed48b58bdc81245c3e40978735f8386c3eb6029b92701511986477'
b1 = {k: v for k, v in b2.items() if k != 'emission'}
b1['kind'] = 'checked'
binding = dict(kind='phase61-compiler-image-bindings', version=1, comparison='fixed-source',
    roles=dict(b1=b1, b2=b2),
    outputPolicies={role: dict(kind='catalog', referenceRole='direct') for role in ['b1', 'b2']},
    scope='Same State08 Bend source: checked B1 equality-derived TS bootstrap versus genuine B2. '
          'This contrasts complete compiler images, including runtime/ABI/profile code, not isolated emitters. '
          'TS is the separate pinned hand-written implementation. No source changes or qualification inferred.')

# Only paths and the resulting profile identity change. Keep all schema, timing,
# profiling, admission, byte-oracle and resource-guard logic exactly as consumed.
texts, derivations = {}, []
for name in ['profile.mjs', 'run.py', 'worker.mjs', 'setup.mjs']:
    parent_id = identity(PARENT / name)
    assert parent_id['sha256'] == PINS[name]
    text = (PARENT / name).read_text()
    edits = []

    def edit(old, new, count):
        global text
        assert text.count(old) == count, (name, old, count, text.count(old))
        text = text.replace(old, new)
        edits.append(dict(old=old, new=new, count=count))

    if name == 'profile.mjs':
        edit(f'const rawRoot=path.resolve("{ROOT}/selfhost/build/phase61");',
             f'const rawRoot=path.resolve("{RAW}");', 1)
    if name == 'run.py':
        edit(str(PARENT), str(method), 4)
        edit("ROOT/'selfhost/build/phase61'", "ROOT/'selfhost/build/phase62'", 3)
        edit(PINS['profile.mjs'], hashlib.sha256(texts['profile.mjs'].encode()).hexdigest(), 1)
        ast.parse(text)
    if name == 'worker.mjs':
        edit(str(PARENT), str(method), 2)
    if name == 'setup.mjs':
        edit("boundary=path.join(root,'selfhost/build/phase61')",
             "boundary=path.join(root,'selfhost/build/phase62')", 1)
    texts[name] = text
    derivations.append(dict(parent=parent_id,
        output=dict(file=str(method / name), sha256=hashlib.sha256(text.encode()).hexdigest()), edits=edits))

method.mkdir(parents=True)
for name, text in texts.items():
    (method / name).write_text(text)
save(method / 'derivation.json', dict(kind='phase61-candidate-fast-loop-method',
    complete=True, **{'pass': True}, dataOnly=True, targetExecuted=False,
    producer=identity(__file__), parentDerivation=identity(PARENT / 'derivation.json'),
    derivations=derivations,
    scope='Phase62 writable-boundary relocation only; unchanged Phase61 method06 clocks, '
          'admission checks, profile schema/weight policy, full raw-output oracles and resource guard.'))
save(out / 'bindings.json', binding)
base = [sys.executable, str(method / 'run.py')]
common = ['--bindings', str(out / 'bindings.json')]
prepared = ['--preparations', str(out / 'preparation/report.json')]
commands = {
    'prepare': base + [str(out / 'preparation'), *common, '--roles', 'b1,b2,typescript',
        '--cases', 'all', '--prepare-only', '--seconds', '180'],
    'clean36': base + [str(out / 'clean36'), *common, *prepared, '--roles', 'b1,b2,typescript',
        '--cases', CASES, '--rounds', '3', '--warm-requests', '0', '--seconds', '180'],
}
for mode in ['cpu', 'allocation']:
    commands[mode + '46'] = base + [str(out / (mode + '46')), *common, *prepared,
        '--roles', 'b2,typescript', '--cases', 'all', '--rounds', '1',
        '--warm-requests', '0', '--mode', mode, '--seconds', '300']
save(out / 'recipe.json', dict(kind='phase62-same-source-generation-recipe', complete=True,
    **{'pass': True}, dataOnly=True, targetExecuted=False, producer=identity(__file__),
    parentBinding=source_binding_id, source=source, b1=identity(attempt['api']),
    b1Profile=attempt['config']['profile'], b1Derivation=identity(attempt['derivationReport']),
    b2=identity(emission['module']), bindings=identity(out / 'bindings.json'),
    method=identity(method / 'derivation.json'), commands=commands,
    note='CPU/allocation are diagnostic only; clean36 has three balanced role positions '
         'per source, fixed source order and zero later requests. Preparation covers all23.'))
(out / 'commands.txt').write_text('\n\n'.join('# ' + key + '\n' + shlex.join(value)
    for key, value in commands.items()) + '\n')
print(json.dumps(dict(recipe=identity(out / 'recipe.json'), commands=str(out / 'commands.txt'))))
