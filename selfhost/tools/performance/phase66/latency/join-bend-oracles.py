#!/usr/bin/env python3
"""Bind an actual checked HEAD Bend image to all original 45 point observations."""
import argparse, hashlib, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT / 'selfhost/build/phase66'
PIN = '059266225b77c8ca256ac6b25ee5c21449bab151'
inputs = {}

def identity(value):
    p = Path(value.get('file', value.get('path')) if isinstance(value, dict) else value).resolve(strict=True)
    row = dict(file=str(p), sha256=hashlib.sha256(p.read_bytes()).hexdigest())
    if isinstance(value, dict):
        assert row['sha256'] == value['sha256'], str(p)
        if 'bytes' in value: assert p.stat().st_size == value['bytes']
    inputs[str(p)] = row
    return row

def read(value):
    return json.loads(Path(identity(value)['file']).read_text())

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--attempt', type=Path, required=True)
p.add_argument('--acquisition', type=Path, required=True)
p.add_argument('--smoke', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
assert a.out.resolve().is_relative_to(RAW) and not a.out.exists()
catalog_id = identity(ROOT/'selfhost/tools/performance/phase60/catalog.json')
catalog = read(catalog_id)
original_id = identity(ROOT/'selfhost/tools/performance/phase37/catalog.json')
original = read(original_id)
manifest_id = identity(a.acquisition/'manifest.json')
manifest = read(manifest_id)
prep = read(a.acquisition/manifest['preparation']['path'])
for verifier in prep['verifiers']:
    # The acquisition captured these verifier bytes before the live upstream
    # migration. Bind those copies, never demand that mutable live tools revert.
    saved = a.acquisition/'consumed'/('verifier-'+Path(verifier.get('file',verifier.get('path'))).name)
    assert identity(saved)['sha256'] == verifier['sha256']
smoke_id = identity(a.smoke/'report.json')
smoke = read(smoke_id)
assert manifest['complete'] and manifest['upstreamCommit'] == PIN
assert set(manifest['roles']) == {'candidate'}
compiler = manifest['roles']['candidate']['compiler']
assert compiler['kind'] == 'checked-development-attempt' and compiler['upstreamCommit'] == PIN
assert compiler['backend'] == 'direct' and compiler['callingContract'] == 'upstream-compatible-direct-v1'
attempt_id = identity(a.attempt/'attempt.json' if a.attempt.is_dir() else a.attempt)
attempt = read(attempt_id); assert attempt['checked'] is True
boot = read(attempt['bootstrapReport']); assert boot['revision'] == PIN
source = identity(boot['source']); assert source['sha256'] == boot['sourceSha256'] == compiler['sourceSha256']
compiler_inputs = [identity(compiler[k]) for k in ['api','runtime','base','driver','directRuntime']]
for key in ['api','runtime','base']: assert identity(compiler[key])['sha256'] == identity(attempt[key])['sha256']
frozen = {row['frozen']['file']:row['frozen']['sha256'] for row in attempt['snapshot']['sources']}
for key in ['driver','directRuntime']: assert frozen[compiler[key]['file']] == compiler[key]['sha256']
image = {key:identity(compiler[key]) for key in ['api','runtime','base','driver','directRuntime']}
image['source'] = source
new_catalog = read(prep['catalog'])
assert new_catalog['upstreamCommit'] == PIN
assert new_catalog['phase66Derivation']['parent'] == original_id
assert new_catalog['cases'] == original['cases'] and new_catalog['sets'] == original['sets']
assert prep['complete'] and prep['backend'] == 'direct' and len(prep['sources']) == 23
assert smoke['kind'] == 'phase66-program-output-smoke' and smoke['role'] == 'candidate'
assert smoke['complete'] and smoke['passed'] and smoke['inputsUnchanged']
assert len(smoke['cases']) == len(manifest['cases']) == 45
rows = {x['id']:x for x in manifest['cases']}
observations = {x['id']:x for x in smoke['cases']}
assert set(rows) == set(observations) == {x['id'] for x in original['cases']}
raw = {}
for x in prep['sources']:
    assert x['process']['complete'] and x['process']['returncode'] == 0
    emission = read(a.acquisition/x['emission']['path'])
    assert emission['complete'] and emission['observation']['checked'] and emission['observation']['status'] == 'ok'
    assert emission['compiler'] == compiler and emission['input']['sha256'] == x['source']['sha256']
    assert identity(emission['attempt']) == attempt_id
    assert emission['backend'] == 'direct' and emission['callingContract'] == 'upstream-compatible-direct-v1'
    identity(emission['input']); identity(emission['output'])
    raw[emission['input']['sha256']] = emission['output']
assert len(raw) == 23
for case in original['cases']:
    row, observation = rows[case['id']], observations[case['id']]
    assert row['sourceSha256'] == case['source']['sha256'] and row['point'] == case['point']
    module = row['modules']['candidate']
    module_id = identity(dict(file=str(a.acquisition/module['path']), **{k:module[k] for k in ['sha256','bytes']}))
    assert observation['passed'] and observation['process']['complete'] and observation['process']['returncode'] == 0
    result = read(observation['receipt'])
    assert result == observation['result'] and result['complete'] and result['pass']
    assert result['module']['sha256'] == module_id['sha256']
    assert all(result['config'][k] == case['point'][k] for k in ['exportName','args','expected'])
    source = Path(raw[case['source']['sha256']]['file']).read_text()
    if case.get('adapter'):
        assert case['adapter'] == 'generic-row' and source.count('export default ') == 1
        source = source.replace('export default ', 'const $Owned_exports = ', 1) + '\nexport default {...$Owned_exports,bench:(n,seed)=>{const st=$Owned_exports["row.probe"](n,seed);return JSON.stringify([st.a,st.b,st.prev,st.cur]);}};\n'
    assert Path(module_id['file']).read_text() == source
cases = [dict(id=c['id'], source=c['source'], pointIds=c['pointIds'], oracleValues=c['oracles'],
              output=identity(raw[c['source']['sha256']]), semanticQualification=dict(receipt=smoke_id, **{'pass':True}))
         for c in catalog['compileInputs']]
assert len(cases) == 23
result = dict(kind='phase61-qualified-compiler-output-oracles', complete=True, **{'pass':True}, dataOnly=True,
    targetExecuted=False, producer=identity(__file__), catalog=catalog_id, originalRuntimeCatalog=original_id, backend='direct', image=image, attempt=attempt_id,
    upstreamCommit=PIN, compiler=compiler, compilerInputs=compiler_inputs, acquisition=manifest_id,
    semanticQualification=smoke_id, cases=cases, inputs=list(inputs.values()),
    scope='All original23sources/45point values; fresh checked HEAD Bend image modules and exact original observer. '
          'Acquisition and finite runtime qualification precede clean latency. This is not full language conformance.')
a.out.parent.mkdir(parents=True, exist_ok=True)
a.out.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(dict(output=identity(a.out), sources=23, points=45)))
