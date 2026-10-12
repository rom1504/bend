#!/usr/bin/env python3
"""Prepare a narrowly rebound saved-binary calibrator; never execute targets."""
import argparse
import ast
import hashlib
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase70'
PARENT = RAW / 'coverage-methods02/run.py'
PARENT_SHA = '743d90b6a1e790eab2c600209f23043ecfaebc82443f536db51df920a9e126b0'
ALLOW = {
    str(ROOT/'selfhost/src/compiler.json'): 'Observer source registration; compiler assembly only.',
    str(ROOT/'selfhost/tools/typed-driver.mjs'): 'Analysis-only no_observer_plan export; compiler bootstrap/host emission only.'}


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(path=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))


def write(path, value):
    with path.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2) + '\n')


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--recipe', type=Path, required=True)
p.add_argument('--acquired', type=Path, required=True)
p.add_argument('--calibration-out', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert os.sched_getaffinity(0) == {0}
out, destination = a.out.resolve(), a.calibration_out.resolve()
assert out.is_relative_to(RAW) and not out.exists()
assert destination.is_relative_to(RAW) and not destination.exists()
recipe_pin, parent_pin = pin(a.recipe), pin(PARENT)
assert parent_pin['sha256'] == PARENT_SHA
recipe = json.loads(a.recipe.read_text())
acquired = a.acquired.resolve(strict=True)
report_pin = pin(acquired/'report.json')
report = json.loads((acquired/'report.json').read_text())
assert report['complete'] and report['recipe'] == recipe_pin
assert report['kind'] == 'phase70-native-coverage-acquire'
assert recipe['kind'] == 'phase70-native-coverage-method-v2'
assert report['inputs'] == recipe['inputs']
rebindings = {}
for before in recipe['inputs']:
    after = pin(before['path'])
    if before != after:
        assert before['path'] in ALLOW, ('Unexpected changed input', before['path'])
        rebindings[before['path']] = dict(before=before, after=after,
                                         reason=ALLOW[before['path']], executedBySavedBinaryTiming=False)
assert rebindings, 'No rebind is necessary; use the original method'
cases = ['list-pipeline', 'array-map', 'tape-observer', 'string-order']
assert {(r['case'], r['role']) for r in report['records']} == {
    (case, role) for case in cases for role in ['upstream', 'selfhost']}
for row in report['records']:
    assert row['correct']
    for key in ['source', 'executable', 'nativeSource', 'emissionReceipt']:
        assert pin(row[key]['path']) == row[key]
source = PARENT.read_text()
edits = []


def replace(old, new, count=1):
    global source
    assert source.count(old) == count, (old, source.count(old), count)
    source = source.replace(old, new)
    edits.append(dict(before=old, after=new, count=count))


replace('def check(inputs):\n for i in inputs:\n  assert S.identity(i[\'path\'])==i,i[\'path\']',
        'EMISSION_ONLY_REBINDINGS='+repr(rebindings)+'\nFROZEN_RECIPE='+repr(recipe_pin)+'\n'
        'def check(inputs):\n for i in inputs:\n'
        '  changed=EMISSION_ONLY_REBINDINGS.get(i[\'path\'])\n'
        '  if changed:\n'
        '   assert i==changed[\'before\'],i[\'path\']\n'
        '   assert S.identity(i[\'path\'])==changed[\'after\'],i[\'path\']\n'
        '  else:\n'
        '   assert S.identity(i[\'path\'])==i,i[\'path\']')
replace("choices=['acquire','calibrate','measure']", "choices=['calibrate','measure']")
replace('default=120', 'default=300')
replace('default=16000', 'default=3000')
replace("recipe=json.loads(a.recipe.read_text());check(recipe['inputs']);",
        "assert S.identity(a.recipe)==FROZEN_RECIPE,'This successor is bound to one immutable acquisition recipe'\nrecipe=json.loads(a.recipe.read_text());check(recipe['inputs']);")
replace("inputs=recipe['inputs']);write(a.out/'report.json',report)",
        "inputs=recipe['inputs'],executionMethod=S.identity(__file__),methodDerivation=S.identity(Path(__file__).with_suffix('.derivation.json')),nonexecutedEmissionInputRebindings=EMISSION_ONLY_REBINDINGS,scope='Saved native binaries only. Original acquisition recipe remains unchanged; exactly recorded compiler-only metadata has fresh explicit hashes. All other recipe, executable, generated C, emission, oracle and guard inputs retain their original checks.');write(a.out/'report.json',report)")
ast.parse(source)
out.mkdir(parents=True)
target = out/'run-saved.py'
write(target, source)
receipt = dict(kind='phase70-saved-native-calibration-derivation', parent=parent_pin,
               output=pin(target), producer=pin(__file__), edits=edits,
               recipe=recipe_pin, acquisition=report_pin, rebindings=rebindings,
               targetsExecuted=False,
               scope='Reject acquisition; no compiler, Node, Clang or loader invocation. Only two named emission-only inputs may receive exact replacement pins; subsequent changes still refuse. Original recipe and all old methods remain unchanged.')
write(target.with_suffix('.derivation.json'), receipt)
command = ['python3', '-B', str(target), 'calibrate', '--recipe', str(a.recipe.resolve()),
           '--acquired', str(acquired), '--out', str(destination), '--cases', ','.join(cases),
           '--roles', 'upstream,selfhost', '--target-ms', '300', '--max-slow-ms', '3000']
write(out/'plan.json', dict(kind='phase70-saved-native-calibration-plan', command=command,
                           targetsExecuted=False, expectedObservations=8,
                           producer=pin(__file__), method=pin(target),
                           derivation=pin(target.with_suffix('.derivation.json')),
                           recipe=recipe_pin, acquisition=report_pin,
                           note='Root executes this command in its sole guarded target lane. Calibration does not establish a final speed ratio. Repeat with generated --plan if observations are below10ms.'))
assert pin(a.recipe) == recipe_pin and pin(acquired/'report.json') == report_pin
for changed in rebindings.values():
    assert pin(changed['after']['path']) == changed['after']
print(json.dumps(dict(plan=pin(out/'plan.json'), rebindings=len(rebindings), targetsExecuted=False)))
