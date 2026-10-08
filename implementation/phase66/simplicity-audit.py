#!/usr/bin/env python3
"""Read-only source/image census. Writes one fresh receipt; runs no subprocesses."""
import argparse, hashlib, json, os, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
parser = argparse.ArgumentParser()
parser.add_argument('--attempt', type=Path)
parser.add_argument('--b2-report', type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
assert args.attempt or not args.b2_report
assert os.sched_getaffinity(0) == {0}, 'Data-only audit must run on CPU0'
INPUTS = {}
FIELDS = ['physicalLines', 'codeLines', 'definitions', 'laws', 'types', 'utf8Bytes']
HOST = ['tools/typed-driver.mjs', 'tools/base-cache-graph.mjs',
        'tools/development/workflow.mjs', 'tools/development/release.mjs']
RUNTIME = [f'src/runtime/js/{name}.mjs' for name in
           ['core', 'base', 'effects', 'readback', 'foreign', 'direct']]
RUNTIME += ['src/runtime/native/runtime.c']

def identity(file, expected=None):
    file = Path(file).resolve()
    data = file.read_bytes()
    row = {'file': str(file), 'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}
    if expected:
        assert row['sha256'] == expected['sha256'], str(file)
        if 'bytes' in expected:
            assert row['bytes'] == expected['bytes'], str(file)
    assert str(file) not in INPUTS or INPUTS[str(file)] == row, str(file)
    INPUTS[str(file)] = row
    return row

def read(file, expected=None):
    row = identity(file, expected)
    return json.loads(Path(file).read_text()), row

def count(file, bend=False):
    data = Path(file).read_bytes()
    text = data.decode('utf-8')
    assert text.encode('utf-8') == data
    lines = text.splitlines()
    result = {'physicalLines': len(lines), 'utf8Bytes': len(data)}
    if bend:
        result.update(codeLines=sum(bool(s.strip()) and not s.lstrip().startswith('#') for s in lines),
                      definitions=sum(bool(re.match(r'^def\s', s)) for s in lines),
                      laws=sum(bool(re.match(r'^law\s', s)) for s in lines),
                      types=sum(bool(re.match(r'^type\s', s)) for s in lines))
    else:
        result['nonblankLines'] = sum(bool(s.strip()) for s in lines)
    return result

def inventory(snapshot, frozen):
    snapshot = snapshot.resolve()
    manifest, manifest_id = read(snapshot / 'src/compiler.json', frozen['src/compiler.json'])
    names = manifest['modules']
    assert len(names) == len(set(names)) and all(n.endswith('.bend') for n in names)
    modules = {}
    for name in names:
        file = snapshot / name
        assert file.resolve().is_relative_to(snapshot)
        modules[name] = {'identity': identity(file, frozen[name]), 'metrics': count(file, True)}
    totals = {key: sum(row['metrics'][key] for row in modules.values()) for key in FIELDS}
    totals['modules'] = len(modules)
    support = {}
    effects = sorted(name for name in frozen if name.startswith(('src/runtime/js/effs/', 'src/runtime/native/effs/')) and name.endswith(('.js', '.c')))
    for name in HOST + RUNTIME + effects:
        if name in frozen:
            support[name] = {'identity': identity(snapshot / name, frozen[name]), 'metrics': count(snapshot / name)}
    return {'snapshotRoot': str(snapshot), 'manifest': manifest_id, 'upstream': manifest['upstream'],
            'moduleOrder': names, 'metrics': totals, 'modules': modules, 'support': support,
            'generatedOrdinaryRuntime': identity(snapshot / 'src/runtime.mjs', frozen['src/runtime.mjs'])}

campaign, campaign_id = read(ROOT / 'selfhost/build/phase66/campaign.json')
frozen_source, frozen_id = read(ROOT / 'selfhost/build/phase66/baseline-source.json')
assert frozen_source['complete']
base_root = ROOT / 'selfhost/build/phase66/baseline-source'
frozen = {}
for row in frozen_source['files']:
    copied = ROOT / row['copy']['file']
    assert copied.resolve().is_relative_to(base_root.resolve())
    assert row['copy']['sha256'] == row['original']['sha256']
    identity(copied, row['copy'])
    name = str(copied.relative_to(base_root))
    assert name not in frozen
    frozen[name] = row['copy']
baseline = inventory(base_root, frozen)
published, published_id = read(ROOT / 'implementation/phase65/evidence/state10-size.json')
assert published['complete'] and published['pass']
assert baseline['metrics'] == published['candidate']['metrics']
baseline['publishedSizeReceipt'] = published_id
baseline['images'] = {name: identity(row['file'], row) for name, row in published['candidate']['images'].items()}
assert baseline['images']['checkedB1EqualityDerived']['sha256'] == campaign['baselineB1']
assert baseline['images']['genuineB2']['sha256'] == campaign['baselineB2']

upstream_delta, upstream_delta_id = read(ROOT / 'selfhost/build/phase66/upstream-delta.json')
assert upstream_delta['old'] == campaign['oldUpstream'] and upstream_delta['new'] == campaign['newUpstream']
upstream = {}
for key, checkout, expected_key in [('old', 'upstream-phase23', 'before'), ('new', 'upstream-phase66', 'after')]:
    rows = {}
    for row in upstream_delta['files']:
        name = row['file']
        file = ROOT / 'selfhost/.bootstrap' / checkout / name
        rows[name] = {'identity': identity(file, row[expected_key]), 'metrics': count(file, name.endswith('.bend'))}
        assert rows[name]['metrics']['physicalLines'] == row[expected_key]['lines']
    upstream[key] = {'commit': upstream_delta[key], 'files': rows,
                     'primaryTypeScriptPhysicalLines': sum(rows[n]['metrics']['physicalLines'] for n in ['bend2/bend.ts', 'bend2/comp.ts', 'bend2/main.ts'])}

candidate = None
comparison = None
if args.attempt:
    attempt_file = args.attempt.resolve() / 'attempt.json'
    attempt, attempt_id = read(attempt_file)
    assert attempt['checked'] and attempt['config']['strictExact']
    snapshot = Path(attempt['snapshot']['root'])
    frozen = {str(Path(row['frozen']['file']).relative_to(snapshot)): row['frozen'] for row in attempt['snapshot']['sources']}
    candidate = inventory(snapshot, frozen)
    assert candidate['upstream'] == campaign['newUpstream']
    candidate['attempt'] = attempt_id
    candidate['images'] = {'checkedB1Raw': identity(attempt['checkedApi']['file'], attempt['checkedApi']),
                           'checkedB1EqualityDerived': identity(attempt['api']['file'], attempt['api'])}
    if args.b2_report:
        b2, b2_id = read(args.b2_report)
        assert b2['complete'] and b2['pass']
        assert b2['subject']['attempt']['sha256'] == attempt_id['sha256']
        identity(b2['subject']['attempt']['file'], b2['subject']['attempt'])
        identity(b2['subject']['source']['file'], b2['subject']['source'])
        candidate['images']['genuineB2'] = identity(b2['module']['file'], b2['module'])
        candidate['b2Receipt'] = b2_id
        candidate['exports'] = b2['roots']
    changed = []
    unchanged = []
    for name in sorted(set(baseline['modules']) | set(candidate['modules'])):
        old, new = baseline['modules'].get(name), candidate['modules'].get(name)
        if old and new and old['identity']['sha256'] == new['identity']['sha256']:
            assert old['metrics'] == new['metrics']
            unchanged.append(name)
        else:
            changed.append({'module': name, 'before': old, 'after': new})
    comparison = {'bendDelta': {key: candidate['metrics'][key] - baseline['metrics'][key] for key in baseline['metrics']},
                  'changedModules': changed, 'unchangedModules': unchanged,
                  'imageByteDeltas': {key: row['bytes'] - baseline['images'][key]['bytes'] for key, row in candidate['images'].items()},
                  'supportChanges': [{'file': name, 'before': baseline['support'].get(name), 'after': candidate['support'].get(name)}
                                     for name in sorted(set(baseline['support']) | set(candidate['support']))
                                     if baseline['support'].get(name, {}).get('identity', {}).get('sha256') != candidate['support'].get(name, {}).get('identity', {}).get('sha256')]}

producer = identity(__file__)
for row in list(INPUTS.values()):
    identity(row['file'], row)
report = {'kind': 'phase66-source-simplicity-census', 'complete': True, 'pass': True,
          'dataOnly': True, 'targetExecuted': False, 'producer': producer,
          'campaign': campaign_id, 'baselineFreeze': frozen_id, 'upstreamDelta': upstream_delta_id,
          'method': {'bendBoundary': 'Exactly frozen compiler.json modules; same Phase65 splitlines, code-line and declaration rules.',
                     'supportBoundary': 'Four host files, five ordinary JS runtime fragments, direct JS runtime, native runtime and effect sources; never add generated runtime.mjs again.',
                     'upstreamBoundary': 'Primary TS bend.ts+comp.ts+main.ts; safe.ts, Base and Lean separately. comp.ts includes embedded runtime source.',
                     'concepts': 'No automated semantic concept count. Qualitative ownership/representation/ABI/cache ledger is reviewed separately.'},
          'baseline': baseline, 'upstream': upstream, 'candidate': candidate, 'comparison': comparison,
          'verifiedInputCount': len(INPUTS), 'verifiedAllInputsUnchanged': True,
          'limitations': ['Line counts are not semantic complexity, correctness or speed.',
                         'TypeScript and Bend boundaries and language verbosity differ; primary totals are not scope-normalized.',
                         'Candidate absence is unmeasured; image byte deltas use actual recorded export scopes.']}
args.output.parent.mkdir(parents=True, exist_ok=True)
with args.output.open('x') as stream:
    json.dump(report, stream, indent=2)
    stream.write('\n')
print(json.dumps({'output': str(args.output.resolve()), 'verifiedInputs': len(INPUTS),
                  'baseline': baseline['metrics'], 'candidate': candidate['metrics'] if candidate else None,
                  'upstreamPrimaryLines': {key: row['primaryTypeScriptPhysicalLines'] for key, row in upstream.items()},
                  'delta': comparison['bendDelta'] if comparison else None}))
