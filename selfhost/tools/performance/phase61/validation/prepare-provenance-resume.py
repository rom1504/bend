#!/usr/bin/env python3
"""Prepare the identity-schema repair and B2 semantic resume; execute no targets."""
import argparse
import copy
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase61'
METHOD_SHA = 'e555167c7a1b62e0f98c89a655073d46b6d67c62adc766b6a66b980e7dba91da'
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--methods', type=Path, required=True)
p.add_argument('--final-root', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--plan', type=Path, required=True)
a = p.parse_args()
inputs = {}

def pin(file):
    file = Path(file).resolve(strict=True)
    row = dict(file=str(file), sha256=hashlib.sha256(file.read_bytes()).hexdigest())
    assert str(file) not in inputs or inputs[str(file)] == row
    inputs[str(file)] = row
    return row

def read(file):
    pin(file)
    return json.loads(Path(file).read_text())

def write(file, value):
    with file.open('x') as stream:
        stream.write(value if isinstance(value, str) else json.dumps(value, indent=2) + '\n')

methods = a.methods.resolve(strict=True)
base = a.final_root.resolve(strict=True)
out, plan_file = a.out.resolve(), a.plan.resolve()
assert all(x.is_relative_to(RAW) for x in [methods, base, out, plan_file])
assert not out.exists() and not plan_file.exists()
pin(__file__)
manifest_file = methods / 'methods.json'
assert pin(manifest_file)['sha256'] == METHOD_SHA
manifest = read(manifest_file)
outputs = {r['output']['file']: r['output'] for r in manifest['rows']}
old_plan_file = base / 'b2-semantics-plan.json'
old_plan = read(old_plan_file)
failed = read(base / 'b2-semantics-execution/report.json')
assert failed['planSha256'] == pin(old_plan_file)['sha256']
assert not failed['complete'] and not failed['pass']
assert len(failed['steps']) == 2 and [x['returncode'] for x in failed['steps']] == [0, 1]
assert all(x['command'] == y['command'] for x, y in zip(failed['steps'], old_plan['commands']))
failure = read(base / 'b2-semantics/composition-controls/report.json')
assert not failure['complete'] and not failure['pass'] and failure['observations'] == []
assert 'canonicalPath' in failure['error'] and 'image-provenance.mjs' in failure['error']
acquisition = read(base / 'b2-semantics/composition-acquisition/manifest.json')
assert acquisition['complete'] and acquisition['passed']
old = ' const pin=item=>{verify(item);inputs.push(item);return item;};'
new = ''' const pin=item=>{
  if(Object.hasOwn(item,'canonicalPath'))assert.equal(item.canonicalPath,fs.realpathSync(item.file),'Incorrect canonicalPath');
  if(Object.hasOwn(item,'bytes'))assert.equal(item.bytes,fs.statSync(item.file).size,'Incorrect byte count');
  const normalized={file:item.file,sha256:item.sha256};verify(normalized);inputs.push(normalized);return normalized;
 };'''
names = ['image-provenance.mjs', 'composition-controls.mjs', 'overapplication-controls.mjs', 'source-controls.mjs', 'numeric-controls.mjs']
bodies = {}
for name in names:
    parent = methods / 'qualification' / name
    assert pin(parent) == outputs[str(parent)]
    body = parent.read_text()
    if name == 'image-provenance.mjs':
        assert body.count(old) == 1
        body = body.replace(old, new)
    bodies[name] = body
out.mkdir(parents=True)
rows = []
for name, body in bodies.items():
    target = out / name
    write(target, body)
    rows.append(dict(parent=pin(methods / 'qualification' / name), output=pin(target),
                     edits=[dict(old=old, new=new)] if name == 'image-provenance.mjs' else [],
                     oracleBodyUnchanged=name != 'image-provenance.mjs'))
derivation = out / 'derivation.json'
write(derivation, dict(kind='phase61-b2-identity-schema-successor', complete=True, producer=pin(__file__),
                      parentMethods=pin(manifest_file), rows=rows,
                      scope='Validate optional canonicalPath/bytes, then verify/record/return exact file+sha256 identities. Four controller bytes and all oracle logic are unchanged. No targets executed.'))
resume = copy.deepcopy(old_plan)
resume.update(kind='phase61-b2-semantic-resume-plan', executed=False, derivedFrom=pin(old_plan_file),
              producer=pin(__file__), successor=pin(derivation), preservedFailure=pin(base / 'b2-semantics-execution/report.json'),
              reusedSuccessfulAcquisition=pin(base / 'b2-semantics/composition-acquisition/manifest.json'))
resume['commands'] = copy.deepcopy(old_plan['commands'][1:])
assert len(old_plan['commands']) == 8 and len(resume['commands']) == 7
old_out = str(base / 'b2-semantics/composition-controls')
new_out = str(base / 'b2-semantics/composition-controls-retry02')
for row in resume['commands']:
    replacements = {str(methods / 'qualification' / name): str(out / name) for name in names[1:]}
    if row['name'] == 'composition-controls':
        replacements.update({old_out: new_out, old_out + '-supervisor': new_out + '-supervisor'})
    row['command'] = [replacements.get(x, x) for x in row['command']]
    assert not Path(row['command'][-1]).exists(), 'Only the successful acquisition may be reused'
assert not Path(new_out + '-supervisor').exists()
resume['scope'] += ' Original failed provenance precondition stays failed; one successful acquisition is reused. Seven healthy commands remain required. Only adjacent identity helper/controller locations and the failed control output paths change.'
resume['inputs'] += list(inputs.values()) + [pin(derivation)]
for item in list(inputs.values()):
    assert pin(item['file']) == item
write(plan_file, resume)
print(json.dumps(dict(plan=pin(plan_file), derivation=pin(derivation), targetsExecuted=False, commands=7)))
