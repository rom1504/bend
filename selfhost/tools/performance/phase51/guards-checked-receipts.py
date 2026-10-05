#!/usr/bin/env python3
"""Bind unchanged guard controls to real checked output, without rewriting or executing it."""
import argparse
import hashlib
import json
from pathlib import Path

CASES = ['coverage-unicode-text-16', 'coverage-map-churn-32', 'coverage-record-aggregation-64', 'test-evening-program']
pins = {}

def identity(path):
    path = Path(path).resolve(strict=True); h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1048576), b''): h.update(block)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())

def pin(path, expected=None):
    item = identity(path)
    if expected:
        assert item['sha256'] == expected['sha256']
        assert item['bytes'] == expected.get('bytes', item['bytes'])
    if item['file'] in pins: assert pins[item['file']] == item
    pins[item['file']] = item
    return item

def read(path, expected=None):
    item = pin(path, expected)
    return json.loads(Path(item['file']).read_text()), item

def once(text, old, new):
    assert text.count(old) == 1
    return text.replace(old, new)

ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('attempt', type=Path); ap.add_argument('manifest', type=Path)
ap.add_argument('baseline_inputs', type=Path); ap.add_argument('out', type=Path)
a = ap.parse_args(); assert not a.out.exists(), 'Fresh receipts only'
producer = pin(__file__)
controller = Path(__file__).with_name('guards-token-controls.mjs')
pin(controller, {'sha256': '91a3098b7067ebe4394ae873104daf81f744bdf5b9039c61ac2719b6c87ca2ba'})
attempt, attempt_id = read(a.attempt / 'attempt.json')
build, _ = read(a.attempt / 'build.json')
assert attempt['checked'] is True and build['complete'] and attempt['api']['sha256'] == build['api']['sha256']
for key in ('api', 'checkedApi', 'runtime', 'base'): pin(attempt[key]['file'], attempt[key])
bootstrap, _ = read(attempt['bootstrapReport']['file'], attempt['bootstrapReport'])
assert bootstrap['apiSha256'] == attempt['checkedApi']['sha256']
source = pin(bootstrap['source'], {'sha256': bootstrap['sourceSha256']})
for module in bootstrap['modules']: pin(Path(attempt['snapshot']['root']) / module['file'], module)
derivation, _ = read(attempt['derivationReport']['file'], attempt['derivationReport'])
assert derivation['complete'] and derivation['output']['sha256'] == attempt['api']['sha256']
manifest, manifest_id = read(a.manifest)
assert manifest['complete'] and manifest['upstreamCommit'] == '018751270e800bc222a93dad7f257083ee53a5f7'
compiler = manifest['roles']['candidate']['compiler']
assert compiler['sourceSha256'] == source['sha256']
for key in ('api', 'runtime', 'base'):
    assert compiler[key]['sha256'] == attempt[key]['sha256']
    pin(compiler[key]['file'], compiler[key])
pin(compiler['driver']['file'], compiler['driver'])
baseline, baseline_id = read(a.baseline_inputs)
assert baseline['roles']['candidate']['compiler']['api']['sha256'] == '6f9d111aa68c19f3ce45b80785621d57c4d10efb12d50164f5cb0597bc952100'
old_runtime_id = baseline['roles']['candidate']['compiler']['runtime']
pin(old_runtime_id['file'], old_runtime_id)
old_runtime = Path(old_runtime_id['file']).read_text()
new_runtime = Path(attempt['runtime']['file']).read_text()
expected_runtime = once(old_runtime, 'function apply(f,args,owned=false){', "function applyIO(f,args){\n  return apply(fn(2,a=>Object.hasOwn(f,'pureValue')?call(a[1],[f.pureValue]):{request:true,action:f,k:a[1]}),args);\n}\nfunction apply(f,args,owned=false){")
expected_runtime = once(expected_runtime, "  if(f?.io)return apply(fn(2,a=>Object.hasOwn(f,'pureValue')?call(a[1],[f.pureValue]):{request:true,action:f,k:a[1]}),args);", '  if(f?.io)return applyIO(f,args);')
expected_runtime = once(expected_runtime, 'const callbackU32Guard={__proto__:null};', 'const callbackU32Guard={__proto__:null};\n// Contextual roots pass this only after fresh host/String checks and cached scalar inputs.\n// It reuses permission within that entry; it never caches permission across calls.\nconst stringHostChecked={__proto__:null};')
expected_runtime = once(expected_runtime, 'if(capability!==callbackU32Guard)', 'if(capability!==callbackU32Guard&&capability!==stringHostChecked)')
assert new_runtime == expected_runtime, 'Runtime differs from reviewed token plus IO extraction'
dispatch_source, dispatch_source_id = read(Path(__file__).resolve().parents[4] / 'selfhost/build/phase51/dispatch-evening-io01/receipt.json', {'sha256': 'da36e5737f7bd0c45eed53312008f39cae97817a4516a88e2cf06c9a21962987'})
pin(Path(__file__).with_name('dispatch-controls.mjs'))
assert dispatch_source['kind'] == 'phase51-dispatch-prototype' and dispatch_source['complete']
assert dispatch_source['diagnosticSuffix'] == '\nexport const $dispatchProbe={apply,force,fn,jump,build,call,callOwned,exactCode,get,pure,G};\n'
rows = []
for case_id in CASES:
    old = [c for c in baseline['cases'] if c['id'] == case_id]
    new = [c for c in manifest['cases'] if c['id'] == case_id]
    assert len(old) == len(new) == 1
    old, new = old[0], new[0]
    assert old['point'] == new['point'] and old['sourceSha256'] == new['sourceSha256']
    parent = pin(old['module']['file'], old['module'])
    module = new['modules']['candidate']
    candidate = pin(a.manifest.parent / module['path'], module)
    emission, emission_id = read(candidate['file'] + '.json')
    assert emission['complete'] and emission['observation']['checked'] and emission['observation']['status'] == 'ok'
    assert emission['observation']['exitCode'] == 0 and emission['compiler'] == compiler
    assert emission['attempt']['sha256'] == attempt_id['sha256'] and emission['output']['sha256'] == candidate['sha256']
    assert emission['input']['sha256'] == new['sourceSha256']
    for key in ('input', 'producer', 'catalog'): pin(emission[key]['file'], emission[key])
    original = Path(parent['file']).read_text(); actual = Path(candidate['file']).read_text()
    assert original.startswith(old_runtime)
    body = original[len(old_runtime):]
    before = '&&localGuard($guards)){/* private contextual instances */'
    after = '&&localGuard($guards,stringHostChecked)){/* private contextual instances */'
    sites = body.count(before)
    assert (sites == 0 if case_id == 'test-evening-program' else sites > 0)
    assert sites == body.count('/* private contextual instances */')
    assert actual == new_runtime + body.replace(before, after), 'Unexpected generated body difference'
    rows.append(dict(kind='phase51-same-entry-string-proof', complete=True, artifactKind='actual-checked-compiler-output',
                     compatibilitySchema='Legacy kind retained for unchanged controller; this producer rewrites no module.',
                     parent=parent, candidate=candidate, producer=producer, caseId=case_id, point=new['point'],
                     checkedAttempt=attempt_id, preparedManifest=manifest_id, baselineInputs=baseline_id,
                     emission=emission_id, compiler=compiler, source=source, expectedTransformationMatched=True,
                     contextualSites=sites, installed=False, targetExecution=False))
assert all(identity(r['file']) == r for r in pins.values()), 'Consumed input changed'
a.out.mkdir(parents=True)
(a.out / 'consumed-guards-checked-receipts.py').write_bytes(Path(__file__).read_bytes())
for row in rows:
    directory = a.out / row['caseId']; directory.mkdir()
    if row['caseId'] == 'test-evening-program':
        outputs = {'baseline.mjs': row['parent'], 'candidate.mjs': row['candidate']}
        for role, source in [('baseline', row['parent']), ('candidate', row['candidate'])]:
            target = directory / (role + '-controls.mjs')
            target.write_text(Path(source['file']).read_text() + dispatch_source['diagnosticSuffix'])
            outputs[role + '-controls.mjs'] = identity(target)
        row.update(kind='phase51-dispatch-prototype', outputs=outputs, originalApply=old_runtime,
                   replacement=new_runtime, diagnosticSuffix=dispatch_source['diagnosticSuffix'],
                   originalApplyScope='Legacy field covers the complete runtime prefix; exact token plus IO-only transformation was independently verified, with generated program body byte-identical.',
                   diagnosticSource=dispatch_source_id)
    (directory / 'derivation.json').write_text(json.dumps(dict(row, inputs=list(pins.values())), indent=2) + '\n')
(a.out / 'report.json').write_text(json.dumps(dict(kind='phase51-checked-guard-bindings', complete=True, producer=producer, cases=rows, inputs=list(pins.values())), indent=2) + '\n')
print(json.dumps(dict(complete=True, cases=len(rows), report=identity(a.out / 'report.json'))))
