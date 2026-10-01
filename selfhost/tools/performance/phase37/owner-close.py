#!/usr/bin/env python3
"""Audit three new Phase37 owner gates against one checked image; execute no jobs."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('attempt', type=Path)
ap.add_argument('cast_derivation', type=Path)
ap.add_argument('finite_cohort', type=Path)
ap.add_argument('mapping', type=Path, help='Exact keys cast, dataview, finite; each value has report and execution paths')
ap.add_argument('out', type=Path)
a = ap.parse_args()
out = a.out.resolve()
assert not out.exists(), 'Use a new output report'
observed = {}


def resolve(file):
    file = Path(file)
    return (file if file.is_absolute() else ROOT/file).resolve()


def identity(file):
    file = resolve(file)
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            h.update(block)
    return dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)


def verify(ref):
    file = resolve(ref.get('file', ref.get('path')))
    actual = observed.get(str(file)) or identity(file)
    assert actual['sha256'] == ref['sha256'], ('Changed input', str(file))
    if 'bytes' in ref:
        assert actual['bytes'] == ref['bytes'], str(file)
    if 'canonicalPath' in ref:
        assert actual['file'] == ref['canonicalPath'], str(file)
    observed[str(file)] = actual
    return file


def read(file):
    file = resolve(file)
    actual = identity(file)
    if str(file) in observed:
        assert observed[str(file)] == actual, ('Changed during audit', str(file))
    observed[str(file)] = actual
    return json.loads(file.read_text())


def refs(value):
    if isinstance(value, dict):
        if 'sha256' in value and ('file' in value or 'path' in value):
            yield value
        for child in value.values():
            yield from refs(child)
    elif isinstance(value, list):
        for child in value:
            yield from refs(child)


def attempt_check(file):
    data = read(file)
    assert data['kind'] == 'bend-development-attempt' and data['checked'] is True
    assert data['artifactKind'] == 'derived-b1'
    for key in ['api', 'checkedApi', 'runtime', 'base', 'bootstrapReport', 'derivationReport', 'node']:
        verify(data[key])
    for row in data['snapshot']['sources']:
        verify(row['frozen'])
        assert row['frozen']['sha256'] == row['original']['sha256']
    for row in data['artifacts']:
        verify(row)
    return data


def scan(file, seen=None):
    seen = {} if seen is None else seen
    file = resolve(file)
    if str(file) in seen:
        return seen
    data = read(file)
    seen[str(file)] = data
    if isinstance(data, dict) and data.get('kind') == 'bend-development-attempt':
        # Historical original source paths can change; verify the frozen image.
        attempt_check(file)
        return seen
    for ref in refs(data):
        target = verify(ref)
        if target.suffix == '.json':
            scan(target, seen)
    return seen


def document(file, default):
    return resolve(file/default if file.is_dir() else file)


attempt_file = document(a.attempt, 'attempt.json')
cast_file = document(a.cast_derivation, 'derive.json')
finite_file = document(a.finite_cohort, 'derive.json')
report = dict(kind='phase37-final-new-owner-controls', complete=False, **{'pass': False},
              scope='New finite/cast/DataView owners only. Inherited controls, canonical source, performance and installation remain separate.',
              inputs=[identity(p) for p in [Path(__file__), attempt_file, cast_file, finite_file, a.mapping]], cases=[])
try:
    for ref in report['inputs']:
        verify(ref)
    attempt = attempt_check(attempt_file)
    mapping = read(a.mapping)
    assert set(mapping) == {'cast', 'dataview', 'finite'}
    compiler_keys = ['api', 'runtime', 'base']

    def compiler_check(compiler, selected=attempt):
        assert compiler['kind'] == 'checked-development-attempt' and compiler['artifact'] == 'derived-b1'
        for key in compiler_keys:
            assert verify(compiler[key]) == verify(selected[key]), key
            assert compiler[key]['sha256'] == selected[key]['sha256'], key
        driver = verify(compiler['driver'])
        assert driver == Path(selected['snapshot']['root'])/'tools/typed-driver.mjs'
        bootstrap = read(verify(selected['bootstrapReport']))
        assert compiler['sourceSha256'] == bootstrap['sourceSha256']
        assert compiler['upstreamCommit'] == bootstrap['revision']

    def emission(file, source_hash, role):
        data = read(file)
        assert data['kind'] == 'bend-program-checked-emission' and data['complete'] is True
        assert data['observation']['checked'] is True and data['observation']['status'] == 'ok'
        assert data['input']['sha256'] == source_hash
        verify(data['input']); verify(data['output'])
        if role == 'candidate':
            compiler_check(data['compiler'])
            assert verify(data['attempt']) == attempt_file
            assert data['observation']['typeAccepted'] is True and data['observation']['exitCode'] == 0
        elif role == 'baseline':
            assert data['compiler']['api']['sha256'] == '93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75'
            baseline = attempt_check(verify(data['attempt']))
            compiler_check(data['compiler'], baseline)
            assert data['observation']['typeAccepted'] is True and data['observation']['exitCode'] == 0
        else:
            assert role == 'typescript' and data['compiler']['kind'] == 'checked-pinned-typescript'
            assert data['observation']['mode'] == 'library'
            assert len(data['compiler']['sources']) == 3
            for ref in data['compiler']['sources']:
                verify(ref)
        assert data['compiler']['upstreamCommit'] == '018751270e800bc222a93dad7f257083ee53a5f7'
        scan(file)
        return data

    cast = read(cast_file)
    assert cast['kind'] == 'phase37-actual-private-native-cast' and cast['complete'] is True and cast['checked'] is True
    assert verify(cast['attempt']) == attempt_file
    compiler_check(cast['compiler'])
    cast_closure = scan(cast_file)
    source_hash = cast['source']['sha256']
    cast_modules = {}
    for variant, role in [('original', 'baseline'), ('direct', 'candidate')]:
        rows = [r for r in cast['modules'] if r['variant'] == variant]
        assert len(rows) == 2 and {r['counters'] for r in rows} == {True, False}
        clean = next(r for r in rows if not r['counters'])
        counter = next(r for r in rows if r['counters'])
        receipt = emission(verify(clean['emission']), source_hash, role)
        assert clean['sha256'] == clean['parent']['sha256'] == receipt['output']['sha256']
        assert counter['parent']['sha256'] == clean['sha256']
        assert counter['emission']['sha256'] == clean['emission']['sha256']
        assert len(counter['privateCallSites']) == (7 if role == 'candidate' else 0)
        cast_modules[variant] = dict(clean=clean, counter=counter, receipt=receipt)
    ts_receipts = [(file, d) for file, d in cast_closure.items() if isinstance(d, dict) and d.get('kind') == 'bend-program-checked-emission'
                   and d.get('compiler', {}).get('kind') == 'checked-pinned-typescript']
    assert len(ts_receipts) == 1
    ts = emission(ts_receipts[0][0], source_hash, 'typescript')
    assert ts['output']['sha256'] == cast['typescript']['sha256']

    finite = read(finite_file)
    assert finite['kind'] == 'phase37-finite-checked-cohorts-v5'
    assert finite['complete'] is True and finite['pass'] is True and not finite.get('error')
    assert set(finite['cases']) == {'finite'}
    assert finite['sourceMap'] == {'finite': 'finite-fixture-v5.bend'}
    assert '7bc5394962b33e8597225e19d0fca5b9c6e115f156a0d5f82538f7afc86a430b' in {r['sha256'] for r in finite['inputs']}
    compiler_check(finite['compilers']['candidate'])
    assert finite['compilers']['candidate'] == cast['compiler']
    finite_manifest_file = verify(finite['cases']['finite']['manifest'])
    finite_manifest = read(finite_manifest_file)
    assert finite_manifest['complete'] is True
    assert finite_manifest['source']['sha256'] == 'c8d68da2cb6ddd292651ecdb304fa915b7035f79af165bb2f954b0f7f2749d58'
    for role in ['baseline', 'candidate', 'typescript']:
        emitted = emission(verify(finite_manifest['emissions'][role]), finite_manifest['source']['sha256'], role)
        assert finite_manifest['variants'][role]['sha256'] == emitted['output']['sha256']
        assert emitted['compiler'] == finite['compilers'][role]
    scan(finite_file)

    specs = {
        'cast': ('phase37-actual-private-native-cast-controls-v4', 'native-cast-actual-controls-v5.mjs', {'oracles': 44, 'boundaries': 57, 'admission': 7}),
        'dataview': ('phase37-actual-private-native-cast-dataview-controls-v4', 'native-cast-actual-dataview-controls-v4.mjs', {'observations': 22, 'errors': 0}),
        'finite': ('phase37-actual-finite-controls-v2', 'finite-controls-v2.mjs', {'oracle': 154, 'admission': 9, 'boundaries': 76}),
    }
    for name in ['cast', 'dataview', 'finite']:
        entry = mapping[name]
        assert set(entry) == {'report', 'execution'}
        file = resolve(entry['report']); gate = read(file)
        kind, tool_name, counts = specs[name]
        assert gate['kind'] == kind and gate['complete'] is True and gate['pass'] is True and not gate.get('error')
        assert not gate.get('errors') and not gate.get('current')
        for key, count in counts.items():
            assert len(gate[key]) == count, (name, key, count)
        tool = ROOT/'selfhost/tools/performance/phase37/optimizer'/tool_name
        hashes = {ref['sha256'] for ref in gate['inputs']}
        tool_identity = identity(tool)
        consumed_identity = identity(file.parent/'consumed-controls.mjs')
        verify(tool_identity); verify(consumed_identity)
        assert tool_identity['sha256'] in hashes
        assert consumed_identity['sha256'] == tool_identity['sha256']
        if name == 'finite':
            assert tool_identity['sha256'] == '9baf2039bc818faa257904363c3621b1c0b2bc5e408ba630c8d8793bd094ce29'
        execution_file = resolve(entry['execution']); execution = read(execution_file)
        assert execution['complete'] is True and execution['returncode'] == 0
        assert resolve(execution['cwd']) == ROOT
        assert str(verify(attempt['node'])) in execution['command']
        assert any(resolve(arg) == tool for arg in execution['command'] if isinstance(arg, str) and arg.endswith('.mjs'))
        assert resolve(execution['command'][-1]) == file.parent
        if name in ['cast', 'dataview']:
            compiler_check(gate['compiler']); assert verify(gate['attempt']) == attempt_file
            assert identity(cast_file)['sha256'] in hashes
            for row in cast_modules.values():
                assert row['counter']['sha256'] in hashes
            if name == 'dataview':
                assert all(row['pass'] is True for row in gate['observations'])
        else:
            target = finite_manifest['variants']['candidate']['sha256']
            assert gate['diagnostic']['parent']['sha256'] == target and target in hashes
            for row in finite_manifest['variants'].values():
                assert row['sha256'] in hashes
            assert len(gate['diagnostic']['sites']) > 0
            assert len([r for r in gate['admission'] if r['kind'] == 'deep-tail-cycle' and r['steps'] == 30000]) == 2
        closure = scan(file); scan(execution_file)
        report['cases'].append(dict(name=name, reports=[identity(file)], execution=identity(execution_file),
                                    counts=counts, identityDocuments=len(closure)))
    for row in observed.values():
        assert identity(row['file']) == row, ('Changed during audit', row['file'])
    report.update(attempt=identity(attempt_file), api=attempt['api'], runtime=attempt['runtime'],
                  verifiedIdentities=list(observed.values()), complete=True, **{'pass': True})
except Exception as error:
    report['error'] = repr(error)
    raise
finally:
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(complete=True, groups=len(report['cases']), verifiedIdentities=len(observed), output=str(out))))
