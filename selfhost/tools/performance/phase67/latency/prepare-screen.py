#!/usr/bin/env python3
"""Prepare two-source, two-role latency protection using the existing method."""
import argparse
import copy
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase67'
OLD = ROOT/'selfhost/build/phase66'
PARENT = OLD/'latency-method05'
inputs = {}


def pin(value):
    item = value if isinstance(value, dict) else None
    file = Path(item['file'] if item else value).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    if item:
        assert row['sha256'] == item['sha256'], file
    inputs[str(file)] = row
    return row


def read(value):
    return json.loads(Path(pin(value)['file']).read_text())


def write(file, value):
    file.parent.mkdir(parents=True, exist_ok=True)
    with file.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2)+'\n')


def method(out):
    if out.exists():
        d = read(out/'derivation.json')
        assert d['kind'] == 'phase67-path-only-latency-method'
        for row in d['derivations']:
            text = Path(pin(row['parent'])['file']).read_text()
            for edit in row['edits']:
                assert text.count(edit['old']) == edit['count']
                text = text.replace(edit['old'], edit['new'])
            assert Path(pin(row['output'])['file']).read_text() == text
        return pin(out/'derivation.json')
    parent = read(PARENT/'derivation.json')
    for row in parent['derivations']:
        pin(row['output'])
    rows = []
    for name in ['profile.mjs', 'setup.mjs', 'worker.mjs', 'run.py']:
        origin = pin(PARENT/name)
        text = (PARENT/name).read_text()
        edits = []
        def edit(old, new, count=None):
            nonlocal text
            count = text.count(old) if count is None else count
            assert count > 0 and text.count(old) == count, (name, old)
            text = text.replace(old, new)
            edits.append(dict(old=old, new=new, count=count))
        if str(PARENT) in text:
            edit(str(PARENT), str(out))
        if name == 'profile.mjs':
            edit(str(OLD), str(RAW), 1)
        if name == 'setup.mjs':
            edit("assert.ok(path.resolve(snapshot).startsWith(path.join(root,'selfhost/build/phase66')+path.sep));",
                 "assert.ok(['phase66','phase67'].some(p=>path.resolve(snapshot).startsWith(path.join(root,'selfhost/build',p)+path.sep)));", 1)
            edit("boundary=path.join(root,'selfhost/build/phase66')", "boundary=path.join(root,'selfhost/build/phase67')", 1)
        if name == 'run.py':
            edit("ROOT/'selfhost/build/phase66'", "ROOT/'selfhost/build/phase67'")
            edit(pin(PARENT/'profile.mjs')['sha256'], pin(out/'profile.mjs')['sha256'], 1)
        write(out/name, text)
        rows.append(dict(parent=origin, output=pin(out/name), edits=edits))
    write(out/'derivation.json', dict(kind='phase67-path-only-latency-method', complete=True,
        dataOnly=True, targetExecuted=False, producer=pin(__file__), parent=pin(PARENT/'derivation.json'),
        derivations=rows, scope='Output/method paths and exact profile hash only; admits both Phase66 baseline and Phase67 checked snapshot paths. Existing pinned upstream, historical verifiers and Base-product permissions are unchanged.'))
    return pin(out/'derivation.json')


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--attempt', type=Path, required=True)
p.add_argument('--closure', type=Path, required=True)
p.add_argument('--image', choices=['b1','b2'], required=True)
p.add_argument('--image-pins', type=Path)
p.add_argument('--b2-equality', type=Path)
p.add_argument('--method', type=Path, default=RAW/'latency-method01')
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out, method_dir = a.out.resolve(), a.method.resolve()
assert out.is_relative_to(RAW) and not out.exists() and method_dir.is_relative_to(RAW)
attempt_id = pin(a.attempt/'attempt.json')
attempt = read(attempt_id)
assert attempt['checked'] and attempt['config']['strictExact']
closure_id = pin(a.closure)
closure = read(closure_id)
assert closure['kind'] == 'phase67-nonnative-executable-closure' and closure['complete'] and closure['passed']
assert closure['candidate'] == attempt_id and closure['excludedPublicRoot'] == 'nc_compile'
assert len(closure['nonNativeRoots']) == 98
for row in closure['inputs']:
    pin(row)
old_binding = read(OLD/(a.image+'-07-full-latency/bindings.json'))
baseline = old_binding['roles']['candidate']
assert baseline['attempt'] == closure['baseline']
old_oracle_id = pin(OLD/(a.image+'-07-full-oracles.json'))
old_oracle = read(old_oracle_id)
assert old_oracle['complete'] and old_oracle['pass']
bootstrap = read(attempt['bootstrapReport'])
snapshot = Path(attempt['snapshot']['root'])
candidate = dict(kind='checked', attempt=attempt_id)
image = dict(api=pin(attempt['api']), source=pin(dict(file=bootstrap['source'],sha256=bootstrap['sourceSha256'])),
    base=pin(attempt['base']), runtime=pin(attempt['runtime']),
    directRuntime=pin(snapshot/'src/runtime/js/direct.mjs'), driver=pin(snapshot/'tools/typed-driver.mjs'))
qualification = closure_id
if a.image == 'b2':
    assert a.image_pins and a.b2_equality
    pins = read(a.image_pins)
    assert pins['attempt'] == attempt_id and pin(pins['b1']) == image['api']
    emission = read(pins['emission'])
    assert emission['complete'] and emission['pass'] and emission['generator']['attempt'] == attempt_id
    assert pin(emission['module']) == pin(pins['b2'])
    candidate.update(kind='direct', emission=pin(pins['emission']), admission=pin(pins['admission']), rootsReference=pin(pins['rootsReference']))
    image['api'] = pin(pins['b2'])
    equality = read(a.b2_equality)
    assert equality['complete'] and equality['pass'] and equality['counts']['rawByteEqualModules'] == 23
    assert equality['image']['api']['sha256'] == image['api']['sha256']
    assert equality['subject']['attempt'] == attempt_id
    for row in equality['inputs']:
        pin(row)
    qualification = pin(a.b2_equality)
else:
    assert not a.image_pins and not a.b2_equality
for key in ['base','runtime','directRuntime','driver']:
    assert image[key]['sha256'] == old_oracle['image'][key]['sha256']
cases = [copy.deepcopy(row) for row in old_oracle['cases'] if row['id'] in ['numeric-recurrence','test-map-set-ops']]
assert len(cases) == 2
for row in cases:
    pin(row['source']);pin(row['output'])
    if a.image == 'b2':
        observed = next(x for x in equality['emissions'] if x['source']['sha256'] == row['source']['sha256'])
        assert observed['byteEqual'] and pin(observed['output'])['sha256'] == row['output']['sha256']
    row['semanticQualification'] = dict(receipt=qualification, pass_=True)
    row['semanticQualification']['pass'] = row['semanticQualification'].pop('pass_')
out.mkdir(parents=True)
method_id = method(method_dir)
oracle = dict(kind='phase61-qualified-compiler-output-oracles',complete=True,pass_=True,
    backend='direct',catalog=old_oracle['catalog'],image=image,cases=cases,inputs=list(inputs.values()),
    scope='Exactly two sources. B1 retains prior executed semantics through exact non-native executable closure; B2 additionally freshly emitted bytes equal those qualified outputs. Preparation rechecks actual complete modules before timing.')
oracle['pass'] = oracle.pop('pass_')
write(out/'oracles.json', oracle)
bindings = dict(kind='phase61-compiler-image-bindings',version=1,comparison='changed-source',
    roles=dict(baseline=baseline,candidate=candidate),outputPolicies=dict(
        baseline=dict(kind='qualified',manifest=old_oracle_id),candidate=dict(kind='qualified',manifest=pin(out/'oracles.json'))))
write(out/'bindings.json', bindings)
common = ['python3', str(method_dir/'run.py'), 'OUT', '--bindings', str(out/'bindings.json'),
    '--roles','baseline,candidate','--head-oracles',str(OLD/'head-ts-oracles01.json'),
    '--cases','numeric-recurrence,test-map-set-ops','--seconds','180','--rounds','2','--warm-requests','0']
prepare = common.copy();prepare[2] = str(out/'preparation');prepare += ['--prepare-only']
screen = common.copy();screen[2] = str(out/'screen');screen += ['--preparations',str(out/'preparation/report.json')]
analysis = ['taskset','-c','0','python3','-B',str(ROOT/'selfhost/tools/performance/phase66/latency/analysis/clean.py'),
    str(out/'screen/report.json'),'--out',str(out/'summary.json')]
write(out/'recipe.json',dict(kind='phase67-two-source-latency-screen',complete=True,dataOnly=True,targetExecuted=False,
    method=method_id,bindings=pin(out/'bindings.json'),image=a.image,commands=dict(prepare=prepare,screen=screen,analysis=analysis),
    scope='Eight fresh workers, two roles/two sources/two rotated rounds. No TypeScript timing or broad ratio update. Existing runner owns one guard.'))
print(json.dumps(dict(recipe=pin(out/'recipe.json'))))
