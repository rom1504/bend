#!/usr/bin/env python3
"""Data-only join of the retained 45-point qualification into 23 compiler inputs."""
import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
HERE = Path(__file__).resolve().parent
P58 = ROOT / 'selfhost/build/phase58'
inputs = {}


def pin(file, expected=None):
    file = Path(file).resolve(strict=True)
    data = file.read_bytes()
    row = dict(file=str(file), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
    if expected:
        assert row['sha256'] == expected['sha256'], str(file)
        if 'bytes' in expected:
            assert row['bytes'] == expected['bytes'], str(file)
    if str(file) in inputs:
        assert inputs[str(file)] == row
    inputs[str(file)] = row
    return row


def read(file, expected=None):
    row = pin(file, expected)
    return row, json.loads(Path(row['file']).read_text())


def asset(row, base=ROOT):
    return pin(base / row.get('file', row.get('path')), row)


def observe(source):
    assert source.count('export default ') == 1
    return source.replace('export default ', 'const $Owned_exports = ', 1) + (
        '\nexport default {...$Owned_exports,bench:(n,seed)=>{const st=$Owned_exports["row.probe"](n,seed);'
        'return JSON.stringify([st.a,st.b,st.prev,st.cur]);}};\n')


p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--out', type=Path, default=HERE / 'catalog.json')
a = p.parse_args()
out = a.out.resolve()
assert out.is_relative_to(HERE) and not out.exists()
producer = pin(__file__)
original_id, original = read(ROOT / 'selfhost/tools/performance/phase37/catalog.json')
qualification_id, qualification = read(ROOT / 'selfhost/tools/performance/phase58/evidence/qualification-last01.json')
assert qualification['complete'] and qualification['qualifiedScopesPassed']
selected = {k: asset(v) for k, v in qualification['selected'].items()
            if isinstance(v, dict) and 'path' in v}
assert selected['directB2']['sha256'] == 'a73daccf86a807092a334d5f3121745e0b91c3054164c25462f1658644b7b081'
equality_id, equality = read(asset(qualification['programs']['b2Equality'])['file'])
assert equality['complete'] and equality['pass'] and not equality['programsExecuted']
assert equality['counts'] == dict(freshCheckedSources=23, rawByteEqualModules=23,
                                 pointByteEqual=45, uniquePointModules=24, observerModules=1)
assert equality['image']['api']['sha256'] == selected['directB2']['sha256']
assert equality['image']['source']['sha256'] == selected['source']['sha256']
checked_id, checked = read(equality['reference']['file'], equality['reference'])
checked_dir = Path(checked_id['file']).parent
baseline_id, baseline = read(P58 / 'final-performance-last01/baseline/manifest.json')
baseline_dir = Path(baseline_id['file']).parent
aggregate_id, aggregate = read(P58 / 'final-performance-last01/aggregate/report.json')
assert aggregate['complete'] and aggregate['passed']
assert (aggregate['points'], aggregate['sources'], aggregate['samples']) == (45, 23, 669)
assert checked['complete'] and baseline['complete']
assert checked['catalogSha256'] == baseline['catalogSha256'] == original_id['sha256']
assert checked['roles']['candidate']['compiler']['api']['sha256'] == selected['checkedB1']['sha256']
assert checked['roles']['candidate']['compiler']['sourceSha256'] == selected['source']['sha256']
typescript = baseline['roles']['typescript']['compiler']
assert typescript['kind'] == 'checked-pinned-typescript'
ts_inputs = [asset(x) for x in typescript['sources']]
assert typescript['upstreamCommit'] == original['upstreamCommit'] == checked['upstreamCommit']
node = qualification['selected']['nodeReportedByCheckedAttempt']
node = dict(pin(node['file'], node), version=node['version'])
base = selected['base']
runtime = selected['directRuntime']
observer_producer = pin(ROOT / 'selfhost/tools/performance/phase52/prepare-v2.py',
    dict(sha256='7a08af571e14ed0f508d49eb1a8560b76d05cd6cf6438b5f4d119fadc818b017'))
emissions = {x['source']['sha256']: x for x in equality['emissions']}
equal_points = {x['id']: x for x in equality['points']}
checked_points = {x['id']: x for x in checked['cases']}
ts_points = {x['id']: x for x in baseline['cases']}
cases = original['cases']
assert len(cases) == len(emissions) + 22 == 45
assert set(original['sets']['full']) == {x['id'] for x in cases}
assert set(equal_points) == set(checked_points) == set(ts_points) == set(original['sets']['full'])

# Join every retained runtime sample to its point, role, whole module and expected value.
runtime_evidence = {}
sample_count = 0
for report_row in aggregate['reports']:
    report_id, report = read(asset(report_row)['file'])
    assert report['complete'] and report['pass']
    for case in report['cases']:
        key = case['id']
        assert key not in runtime_evidence
        assert case['point'] == checked_points[key]['point'] == ts_points[key]['point']
        counts = {}
        for sample in case['samples']:
            result = sample['result']
            assert sample['complete'] and sample['process']['complete'] and sample['process']['returncode'] == 0
            assert result['complete'] and result['pass']
            role = sample['role']
            module = checked_points[key]['modules']['candidate'] if role == 'candidate' else ts_points[key]['modules'][role]
            assert result['module']['sha256'] == module['sha256']
            assert all(result['config'][k] == case['point'][k] for k in ('exportName', 'args', 'expected'))
            counts[role] = counts.get(role, 0) + 1
            sample_count += 1
        assert set(counts) == {'typescript', 'baseline', 'candidate'}
        runtime_evidence[key] = dict(report=report_id, samples=counts, inherited=True, rerun=False)
assert sample_count == 669 and len(runtime_evidence) == 45

groups = {}
points = []
for case in cases:
    key = case['id']
    source = pin(Path(original_id['file']).parent / case['source']['path'], case['source'])
    text = Path(source['file']).read_text()
    assert re.findall(r'^import\s+([^\n]+)', text, re.M) == ['Base']
    assert not re.search(r'^\s*foreign\b', text, re.M)
    emission = emissions[source['sha256']]
    assert emission['byteEqual'] and emission['observation']['checked'] and emission['observation']['status'] == 'ok'
    assert equal_points[key]['byteEqual'] and equal_points[key]['point'] == case['point']
    assert checked_points[key]['sourceSha256'] == ts_points[key]['sourceSha256'] == source['sha256']
    direct = asset(emission['output'])
    direct_b1 = asset(emission['reference'])
    assert direct['sha256'] == direct_b1['sha256']
    receipt_id, receipt = read(asset(emission['checkedB1Receipt'])['file'])
    assert receipt['complete'] and receipt['observation']['checked'] and receipt['observation']['status'] == 'ok'
    assert receipt['input']['sha256'] == source['sha256'] and receipt['compiler'] == checked['roles']['candidate']['compiler']
    assert receipt['directPrefix']['host'] == 'none'
    closure = [asset(x) for x in emission['emissionInputs']]
    assert [x['sha256'] for x in closure] == [source['sha256'], base['sha256'], runtime['sha256']]
    direct_point = asset(equal_points[key]['output'])
    ts_point = asset(ts_points[key]['modules']['typescript'], baseline_dir)
    adapter = case.get('adapter')
    assert adapter in (None, 'generic-row')
    group_id = Path(source['file']).stem
    if group_id not in groups:
        groups[group_id] = dict(id=group_id, source=source, files=[source, base],
            emissionInputs=closure, options=dict(mode='library', backend='direct'),
            typescriptOptions=dict(load='book_load', check='book_valid', emit='js_lib(book,true)'),
            roots='ordinary-library-exports', imports=[dict(name='Base', identity=base)],
            foreignLibraries=[], foreignScope='No external libraries in these emitted pure library modules; Base declares dormant effects.',
            pointIds=[], oracles=[], references=dict(direct=direct),
            preparationEvidence=dict(checkedReceipt=receipt_id, b2Equality=equality_id),
            sourceProvenance=case['source'].get('provenance'))
    group = groups[group_id]
    assert group['source'] == source and group['references']['direct'] == direct
    if adapter is None:
        if 'typescript' in group['references']:
            assert group['references']['typescript'] == ts_point
        group['references']['typescript'] = ts_point
        assert direct_point['sha256'] == direct['sha256']
    group['pointIds'].append(key)
    group['oracles'].append(dict(id=key, point=case['point'], adapter=adapter))
    points.append(dict(id=key, compileInputId=group_id, family=case['family'],
        point=case['point'], oracleDescription=case['oracle'], adapter=adapter,
        modules=dict(direct=direct_point, typescript=ts_point), qualification=runtime_evidence[key]))
assert len(groups) == 23 and all('typescript' in x['references'] for x in groups.values())
for point in points:
    if point['adapter']:
        assert point['id'] == 'complete-generic-row32'
        for role in ('direct', 'typescript'):
            raw = Path(groups[point['compileInputId']]['references'][role]['file']).read_text()
            assert observe(raw) == Path(point['modules'][role]['file']).read_text()
for row in groups.values():
    for role, identity in row['references'].items():
        text = Path(identity['file']).read_text()
        assert not re.search(r'^(?:import |const require =|const \$ffi)', text, re.M), (row['id'], role)

# Record dormant Base support files separately from actual request import/emission inputs.
base_support = []
for name in re.findall(r'^\s+import "([^"\n]+)"', Path(base['file']).read_text(), re.M):
    base_support.append(pin(Path(base['file']).parent / name))
result = dict(kind='phase60-compiler-corpus-catalog', schemaVersion=1, complete=True, pass_=True,
    dataOnly=True, targetExecuted=False, producer=producer, upstreamCommit=original['upstreamCommit'], node=node,
    counts=dict(points=45, compileInputs=23, uniqueRuntimeModulesPerRole=24, observerModulesPerRole=1),
    scope='Unchanged selected Phase58 B2 and pinned TypeScript. Retained runtime qualification; fresh survey requests compare complete raw library bytes. No runtime point is rerun by this producer.',
    deduplication='Source identity plus Base import context, ordinary whole-library roots and role options; runtime arguments and post-emission observers do not create compilation inputs.',
    selected=selected, typescript=dict(compiler=typescript, inputs=ts_inputs),
    qualification=dict(index=qualification_id, b2Equality=equality_id, runtimeAggregate=aggregate_id,
                       checkedManifest=checked_id, typescriptManifest=baseline_id, originalCatalog=original_id,
                       inheritedRuntime=True, freshRuntime=False),
    adapters={'generic-row': dict(stage='post-emission', changesCompileInput=False, producer=observer_producer,
        operation='Rename the sole default export to $Owned_exports; export bench calling row.probe and JSON.stringify([st.a,st.b,st.prev,st.cur]).', exactBothRoleBytesVerified=True)},
    dormantBaseForeignSupport=base_support, compileInputs=list(groups.values()), points=points)
for row in list(inputs.values()):
    assert pin(row['file']) == row
result['inputs'] = list(inputs.values())
result['inputsUnchanged'] = True
result['pass'] = result.pop('pass_')
out.parent.mkdir(parents=True, exist_ok=True)
with out.open('x') as stream:
    json.dump(result, stream, indent=2)
    stream.write('\n')
print(json.dumps(dict(file=str(out), sha256=hashlib.sha256(out.read_bytes()).hexdigest(),
                     bytes=out.stat().st_size, counts=result['counts'])))
