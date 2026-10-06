#!/usr/bin/env python3
"""Derive Phase55 retention metadata from frozen Phase54 methods; no target jobs."""
import ast
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
OLD = HERE.parent / 'phase54'
RAW = ROOT / 'selfhost/build/phase54'
inputs = []


def pin(file, expected=None):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    row = dict(file=str(file), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())
    if expected:
        assert row['sha256'] == expected, str(file)
    inputs.append(row)
    return row


def write(file, text):
    with file.open('x') as stream:
        stream.write(text)
    return pin(file)


def save(file, value):
    return write(file, json.dumps(value, indent=2) + '\n')


pin(__file__)
parent = pin(OLD / 'semantic-plan-v2.json', '2600b4c8f70db57f6c709a5e57028b780a36b4169336bf5f2528095c36a96a5b')
plan = json.loads(Path(parent['file']).read_text())
for row in plan['immutableInputs']:
    pin(row['file'], row['sha256'])
plan.update(kind='phase55-semantic-qualification-plan', parentPlan=parent,
    installedBaseline=pin(OLD / 'evidence/installed-release.json', 'ff0299e906bbdf06cee3b97cfe447c1e791174c2c95cd09dca5a0374a13c3c40'),
    installedAPI='d7d0396cda189918299ddeb0105e9d682f6a22bffa70004ab6d0ebeac20f4857',
    baselineAttempt=pin(RAW / 'checked-graph02/attempt.json', '594381ea67444070290efeb516458997c528829f9cd4b65385109afc2d0d4a76'),
    baselineJS45=pin(RAW / 'semantic-final02-completion01/production-js45/manifest.json'),
    baselineSemantic={name: pin(RAW / 'semantic-final02' / (name + '-acquisition/manifest.json'))
                      for name in ['source', 'numeric', 'composition', 'overapplication']})
baseline_attempt = json.loads(Path(plan['baselineAttempt']['file']).read_text())
assert baseline_attempt['checked'] and baseline_attempt['api']['sha256'] == plan['installedAPI']
for row in plan['baselineSemantic'].values():
    manifest = json.loads(Path(row['file']).read_text())
    assert manifest['complete'] and manifest['passed']
    assert manifest['roles']['direct']['attempt']['sha256'] == plan['baselineAttempt']['sha256']
production = json.loads(Path(plan['baselineJS45']['file']).read_text())
assert production['complete'] and len(production['cases']) == 45
assert production['roles']['candidate']['compiler']['api']['sha256'] == plan['installedAPI']
toolchain = pin(RAW / 'semantic-native-retry01/toolchain-binding.json')
plan['nativeEnvironment'] = json.loads(Path(toolchain['file']).read_text())['environment']
plan['nativeToolchainBinding'] = toolchain
outputs = [save(HERE / 'semantic-plan-v1.json', plan)]
derivations = []


def derive(old_name, old_sha, new_name, changes):
    before = pin(OLD / old_name, old_sha)
    text = Path(before['file']).read_text()
    for previous, replacement in changes:
        assert text.count(previous) == 1, (old_name, previous)
        text = text.replace(previous, replacement)
    if new_name.endswith('.py'):
        ast.parse(text)
    after = write(HERE / new_name, text)
    outputs.append(after)
    derivations.append(dict(parent=before, output=after,
                            exactSubstitutions=[dict(before=a, after=b) for a, b in changes]))


derive('semantic-byte-compare-v2.py', '86e209919e507400cf52ca5713b572107e828424fbae97b869a1763d27c771ce', 'semantic-byte-compare-v1.py', [
    ("Path(__file__).with_name('semantic-byte-compare-v1.py')", "Path(__file__).parent.parent/'phase54/semantic-byte-compare-v2.py'"),
    ("with_name('semantic-plan-v2.json')", "with_name('semantic-plan-v1.json')"),
    ('frozen installed-Phase53 acquisition', 'frozen installed-Phase54 acquisition'),
    ("kind='phase54-exact-emitted-module-comparison'", "kind='phase55-exact-emitted-module-comparison'")])
derive('semantic-census-v1.py', '29473be97b729f6164efd39270ea8df82efff222176061d252a6f2455d309535', 'semantic-census-v1.py', [
    ("ROOT/'selfhost/build/phase54'", "ROOT/'selfhost/build/phase55'"),
    ("pin(__file__);", "pin(__file__);pin(HERE.parent/'phase54/semantic-census-v1.py');"),
    ("kind='phase54-direct-js-census'", "kind='phase55-direct-js-census'")])
derive('semantic-native-v1.mjs', '92de8fb4be5d53192368efa1323065b3b019860b037ba67ff196552f88fb044a', 'semantic-native-v1.mjs', [
    ("kind:'phase54-native-representative-retention'", "kind:'phase55-native-representative-retention'"),
    ('pin(import.meta.filename);', "pin(import.meta.filename);pin(path.join(import.meta.dirname,'../phase54/semantic-native-v1.mjs'));")])

launcher_changes = [
    ("tools/'phase54/semantic-launch-plan-v2.py'", "tools/'phase54/semantic-launch-plan-v3.py'"),
    ("tools/'phase54/semantic-plan-v2.json'", "tools/'phase55/semantic-plan-v1.json'"),
    ("tools/'phase54/semantic-byte-compare-v2.py'", "tools/'phase55/semantic-byte-compare-v1.py'"),
    ("[('source','semantic-ordered02-acquisition01'),('numeric','semantic-numeric-ordered02'),('composition','semantic-composition-ordered02'),('overapplication','semantic-overapplication-ordered02')]", "[(name,name+'-acquisition') for name in ['source','numeric','composition','overapplication']]"),
    ("root/'selfhost/build/phase53'/prior/'manifest.json'", "root/'selfhost/build/phase54/semantic-final02'/prior/'manifest.json'"),
    ("tools/'phase54/semantic-census-v1.py'", "tools/'phase55/semantic-census-v1.py'"),
    ("tools/'phase53/bundles/current/manifest.json'", "root/'selfhost/build/phase54/semantic-final02-completion01/production-js45/manifest.json'"),
    ("'phase54/semantic-native-v1.mjs'", "'phase55/semantic-native-v1.mjs'"),
    ("kind='phase54-semantic-launch-plan'", "kind='phase55-semantic-launch-plan'"),
    ("a.plan_file.parent.mkdir(parents=True,exist_ok=True)", "assert out.is_relative_to(root/'selfhost/build/phase55') and not out.exists()\n    policy=json.loads((tools/'phase55/semantic-plan-v1.json').read_text())\n    commands[-1]['environment']=policy['nativeEnvironment']\n    config['nativeToolchainBinding']=policy['nativeToolchainBinding']\n    a.plan_file.parent.mkdir(parents=True,exist_ok=True)")]
# Two call sites use the same byte comparator; record the exact two-site delta.
before = pin(OLD / 'semantic-launch-plan-v3.py', '8473354802fdd8e0cb1699a87774aa064bafa6696fae9afdf5cb133c9b5f5a2b')
text = Path(before['file']).read_text()
for previous, replacement in launcher_changes:
    count = 2 if previous == "tools/'phase54/semantic-byte-compare-v2.py'" else 1
    assert text.count(previous) == count, previous
    text = text.replace(previous, replacement)
ast.parse(text)
after = write(HERE / 'semantic-launch-plan-v1.py', text)
outputs.append(after)
derivations.append(dict(parent=before, output=after, exactSubstitutions=launcher_changes))
for row in list(inputs):
    assert pin(row['file']) == row
save(HERE / 'retention-methods-v1.derivation.json', dict(kind='phase55-retention-method-derivation',
    complete=True, dataOnly=True, targetExecuted=False, inputs=inputs, inputsUnchanged=True,
    outputs=outputs, derivations=derivations,
    scope='Frozen Phase54 algorithms and independent oracles retained. Only phase paths, exact Phase54 baseline metadata, parent pins and native environment binding change. The launcher writes a plan, not execution evidence.'))
print(json.dumps(dict(complete=True, targetExecuted=False, outputs=[row['file'] for row in outputs])))
