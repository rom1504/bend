#!/usr/bin/env python3
"""Close inherited Phase39 owners plus the Phase40 actual structural-tail witness; execute no compiler or target."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[4]
LOCAL = Path(__file__).resolve().parent
HERE = LOCAL.parent / 'phase39'
PIN = '018751270e800bc222a93dad7f257083ee53a5f7'
BASELINE_API = 'ea5db4a2857ffddce8263406041f56acc9b613754660d7a20c6b7c58682c86a1'
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('attempt', type=Path)
ap.add_argument('mapping', type=Path)
ap.add_argument('out', type=Path)
a = ap.parse_args()
out = a.out.resolve()
assert not out.exists(), 'Use a new report path'
observed, git_observed = {}, {}
upstream_tree = None
bootstrap_modules = {}

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


def verify(ref, base=ROOT):
    name = Path(ref.get('file', ref.get('path')))
    file = name.resolve() if name.is_absolute() else (base/name).resolve()
    actual = observed.get(str(file)) or identity(file)
    assert actual['sha256'] == ref['sha256'], ('Changed input', str(file))
    if 'bytes' in ref:
        assert actual['bytes'] == ref['bytes'], str(file)
    if 'canonicalPath' in ref:
        assert actual['file'] == ref['canonicalPath'], str(file)
    observed[str(file)] = actual
    return file


def git_identity(commit, git_path):
    assert upstream_tree is not None and commit == PIN
    relative = Path(git_path)
    assert not relative.is_absolute() and '..' not in relative.parts
    git = verify(identity(shutil.which('git')))
    # Historical benchmark files are outside the sparse checkout, but their
    # pinned Git blobs remain available. This reads bytes; it runs no compiler.
    env = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_NO_REPLACE_OBJECTS='1')
    raw = subprocess.check_output([str(git), '-C', str(upstream_tree), 'cat-file', 'blob',
                                   commit+':'+git_path], env=env, timeout=15)
    return dict(checkout=str(upstream_tree), commit=commit, gitPath=git_path,
                sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw),
                gitBlob=hashlib.sha1(('blob '+str(len(raw))+'\0').encode()+raw).hexdigest())


def verify_contextual(ref, document_file, data):
    name = Path(ref.get('file', ref.get('path')))
    if 'commit' in ref:
        assert not name.is_absolute()
        key = (ref['commit'], name.as_posix())
        actual = git_observed.get(key) or git_identity(*key)
        for field in ['sha256', 'bytes', 'gitBlob']:
            if field in ref:
                assert actual[field] == ref[field], ('Changed Git provenance', key, field)
        git_observed[key] = actual
        return None
    if name.is_absolute():
        return verify(ref)
    kind = data.get('kind') if isinstance(data, dict) else None
    if name.parts[0] == 'selfhost':
        base = ROOT
    elif kind in ['bend-program-catalog', 'bend-program-bundle', 'bend-program-preparation']:
        base = document_file.parent
    elif isinstance(data, dict) and data.get('stage') == 'upstream-bootstrap':
        return bootstrap_module(ref, document_file, data)
    elif kind == 'phase37-application-point-proposal':
        # Proposal source paths deliberately use the phase catalog's base.
        assert document_file.name == 'points-v1.json' and document_file.parent.name == 'fixtures-new'
        base = document_file.parent.parent
    else:
        raise AssertionError(('Unknown relative identity namespace', str(document_file), kind, str(name)))
    return verify(ref, base)



def bootstrap_module(ref, document_file, data):
    # Bootstrap modules are relative to the assembled-source snapshot, not the
    # repository or the current compiler. Bind that namespace to its checked
    # attempt, absolute provenance, and the corresponding frozen source bytes.
    key = str(document_file)
    if key not in bootstrap_modules:
        image = attempt_check(document_file.parent/'attempt.json')
        assert verify(image['bootstrapReport']) == document_file
        assert data['revision'] == PIN and data['baseSha256'] == image['base']['sha256']
        source = verify(dict(file=data['source'], sha256=data['sourceSha256']))
        snapshot = resolve(image['snapshot']['root'])
        assert snapshot in source.parents
        frozen = {verify(row['frozen']).relative_to(snapshot).as_posix(): row['frozen']
                  for row in image['snapshot']['sources']}
        modules = {row['file']: row for row in data['modules']}
        assert len(modules) == len(data['modules']) and modules
        provenance = [row for row in data['provenance']['inputs'] if row.get('role') == 'compiler-module']
        absolute = {verify(row): row for row in provenance}
        assert len(absolute) == len(provenance) == len(modules)
        resolved = {}
        for name, module in modules.items():
            relative = Path(name)
            assert not relative.is_absolute() and '..' not in relative.parts
            assert relative.parts[0] == 'src' and relative.suffix == '.bend'
            target = verify(module, source.parent)
            assert source.parent in target.parents and target in absolute
            assert absolute[target]['sha256'] == module['sha256'] == frozen[name]['sha256']
            resolved[name] = (target, module)
        bootstrap_modules[key] = resolved
    target, module = bootstrap_modules[key][ref['file']]
    assert ref == module, ('Unknown bootstrap module identity', key, ref)
    return target

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
        target = verify_contextual(ref, file, data)
        if target is not None and target.suffix == '.json':
            scan(target, seen)
    return seen


def document(file, default):
    return resolve(file/default if file.is_dir() else file)


def compiler_check(compiler, selected):
    assert compiler['kind'] == 'checked-development-attempt' and compiler['artifact'] == 'derived-b1'
    for key in ['api', 'runtime', 'base']:
        assert verify(compiler[key]) == verify(selected[key]), key
        assert compiler[key]['sha256'] == selected[key]['sha256'], key
    assert verify(compiler['driver']) == Path(selected['snapshot']['root'])/'tools/typed-driver.mjs'
    bootstrap = read(verify(selected['bootstrapReport']))
    assert compiler['sourceSha256'] == bootstrap['sourceSha256']
    assert compiler['upstreamCommit'] == bootstrap['revision'] == PIN


def emission(file, source_hash, role):
    data = read(file)
    assert data['kind'] == 'bend-program-checked-emission' and data['complete'] is True
    observation = data['observation']
    assert observation['checked'] is True and observation['status'] == 'ok'
    assert data['input']['sha256'] == source_hash
    verify(data['input']); verify(data['output'])
    assert data['compiler']['upstreamCommit'] == PIN
    if role == 'typescript':
        assert data['compiler']['kind'] == 'checked-pinned-typescript'
        assert observation['mode'] == 'library' and len(data['compiler']['sources']) == 3
        for ref in data['compiler']['sources']:
            verify(ref)
    else:
        assert observation['phase'] == 'compile' and observation['exitCode'] == 0
        image_file = verify(data['attempt'])
        image = attempt_check(image_file)
        if role == 'candidate':
            assert image_file == attempt_file, 'Earlier checked image cannot close final owner gate'
        else:
            assert role == 'baseline' and image['api']['sha256'] == BASELINE_API
        compiler_check(data['compiler'], image)
        assert observation['typeAccepted'] is True
    scan(file)
    return data


def tool_check(file, report_inputs, consumed=None):
    file = resolve(file)
    expected = spec['files'][file.relative_to(ROOT).as_posix()]
    assert verify(expected) == file
    assert any(verify(row) == file for row in report_inputs), ('Missing tool input', str(file))
    if consumed:
        assert identity(verify(identity(consumed)))['sha256'] == expected['sha256']
    return file


def command_check(execution_file, tool, args):
    run = read(execution_file)
    assert run['complete'] is True and run['returncode'] == 0 and not run.get('error')
    assert resolve(run['cwd']) == ROOT
    assert verify(run['producer']) == verify(spec['files']['selfhost/tools/performance/phase32/bounded-run.py'])
    command = run['command']
    assert command[:3] == ['taskset', '-c', '3']
    assert resolve(command[3]) == verify(attempt['node'])
    assert '--max-old-space-size=1024' in command[4:]
    index = next(i for i, value in enumerate(command) if value.endswith('.mjs'))
    assert resolve(command[index]) == tool
    assert [resolve(value) for value in command[index+1:]] == [resolve(value) for value in args]
    assert 0 < run['rssLimitBytes'] <= 2048*2**20
    assert run['availableFloorBytes'] >= 2048*2**20
    assert run['peakTreeRssBytes'] <= run['rssLimitBytes']
    assert run['minimumAvailableBytes'] >= run['availableFloorBytes']
    assert 0 < run['secondsLimit'] <= 600
    assert run['wallSeconds'] <= run['secondsLimit']
    scan(execution_file)
    return run


def cohort_check(name, file):
    data = read(file)
    owner = spec['owners'][name]
    assert data['kind'] == owner['cohortKind']
    assert data['complete'] is True and data['pass'] is True and not data.get('error')
    assert set(data['cases']) == {name} and data['sourceMap'] == {name: owner['fixture']}
    assert data['cpu'] == 3 and data['protocol']['serial'] is True
    assert 0 < data['protocol']['heapMiB'] <= 1024
    assert 0 < data['protocol']['rssMiB'] <= 2048 and data['protocol']['availableMiB'] >= 2048
    tool = tool_check(HERE/owner['acquirer'], data['inputs'], file.parent/'consumed'/owner['acquirer'])
    fixture = verify(spec['files'][(HERE/owner['fixture']).relative_to(ROOT).as_posix()])
    fixture_copy = file.parent/'consumed'/owner['fixture']
    assert identity(fixture_copy)['sha256'] == identity(fixture)['sha256']
    compiler_check(data['compilers']['candidate'], attempt)
    case = data['cases'][name]
    target = verify(case['manifest'])
    assert target == file.parent/name/'derive.json' and resolve(case['cohort']) == target
    manifest = read(target)
    assert manifest['complete'] is True and manifest['compilers'] == data['compilers']
    assert verify(manifest['source']) == fixture_copy
    assert set(manifest['variants']) == set(manifest['emissions']) == {'baseline', 'candidate', 'typescript'}
    processes = case['processes']
    assert [row['role'] for row in processes] == ['baseline', 'candidate', 'typescript']
    receipts = {}
    for row in processes:
        role, process = row['role'], row['process']
        assert process['complete'] is True and process['returncode'] == 0
        emitted = emission(verify(manifest['emissions'][role]), manifest['source']['sha256'], role)
        assert emitted['compiler'] == manifest['compilers'][role]
        assert verify(manifest['variants'][role]) == verify(emitted['output'])
        command = process['command']
        assert command[:3] == ['taskset', '-c', '3']
        assert resolve(command[3]) == verify(attempt['node']) and '--max-old-space-size=1024' in command
        if role == 'typescript':
            assert command[-4].startswith('upstream:')
            assert resolve(command[-4][len('upstream:'):]) == upstream_tree
        else:
            assert resolve(command[-4]) == (attempt_file.parent if role == 'candidate' else
                verify(emitted['attempt']).parent)
        assert resolve(command[-3]) == fixture_copy and resolve(command[-2]) == verify(emitted['output'])
        assert resolve(command[-1]) == verify(emitted['catalog'])
        assert resolve(command[-5]) == verify(emitted['producer'])
        assert verify(emitted['producer']) == verify(spec['files']['selfhost/tools/performance/programs/emit-worker.mjs'])
        assert 0 < process['rssLimitBytes'] <= 2048*2**20
        assert process['availableFloorBytes'] >= 2048*2**20
        assert process['peakTreeRssBytes'] <= process['rssLimitBytes']
        assert process['minimumAvailableBytes'] >= process['availableFloorBytes']
        assert 0 < data['protocol']['secondsPerEmission'] <= 1800
        assert process['wallSeconds'] <= data['protocol']['secondsPerEmission']
        receipts[role] = emitted
    scan(file)
    return manifest, receipts, target


attempt_file = document(a.attempt, 'attempt.json')
mapping_file = resolve(a.mapping)
spec_file = LOCAL/'inherited-owner-spec-v1.json'
report = dict(kind='phase40-inherited-owner-controls-v1', complete=False, **{'pass': False},
              scope='All V4 owner receipt/hash/control contracts retained. Component diagnostic deriver successor adds actual proved structural-tail observation; supplementary tail controls are mandatory. Conformance, timing and installation remain separate.',
              cases=[])
try:
    verify(identity(Path(__file__)))
    spec = read(spec_file)
    assert spec['kind'] == 'phase40-inherited-owner-spec' and spec['version'] == 1
    assert set(spec['owners']) == {'countdown', 'guard', 'component', 'unary'}
    for ref in spec['files'].values():
        verify(ref)
    attempt = attempt_check(attempt_file)
    assert attempt['config']['strictExact'] is True and attempt['config']['jobs'] == 1
    assert str(attempt['config']['cpu']) == '3' and 0 < attempt['config']['heapMb'] <= 1024
    upstream_tree = resolve(attempt['config']['upstream'])
    scan(spec_file)
    mapping = read(mapping_file)
    assert set(mapping) == set(spec['owners'])
    for name in ['countdown', 'guard', 'component', 'unary']:
        entry, owner = mapping[name], spec['owners'][name]
        assert set(entry) == ({'report', 'execution', 'derivation'} if name == 'guard' else
            {'report', 'execution', 'derivation', 'cohort', 'tailReport', 'tailExecution'} if name == 'component' else
            {'report', 'execution', 'cohort'})
        file, execution = resolve(entry['report']), resolve(entry['execution'])
        gate = read(file)
        assert gate['kind'] == owner['kind'] and gate['complete'] is True and gate['pass'] is True
        assert not gate.get('error') and not gate.get('errors') and not gate.get('current')
        assert gate['node'] == 'v24.18.0'
        for key, count in owner['counts'].items():
            assert len(gate[key]) == count, (name, key, count)
        tool = tool_check(HERE/owner['controls'], gate['inputs'], file.parent/'consumed-controls.mjs')
        inputs = {verify(ref) for ref in gate['inputs']}
        if name != 'guard':
            cohort_file = document(resolve(entry['cohort']), 'derive.json')
            manifest, receipts, manifest_file = cohort_check(name, cohort_file)
        if name in ['countdown', 'unary']:
            assert manifest_file in inputs
            assert all(verify(row) in inputs for row in manifest['variants'].values())
            command_check(execution, tool, [manifest_file.parent, file.parent])
            if name == 'countdown':
                assert len(gate['diagnostics']) == 2
                for diagnostic in gate['diagnostics']:
                    assert diagnostic['role'] in ['baseline', 'candidate']
                    assert verify(diagnostic['parent']) == verify(manifest['variants'][diagnostic['role']])
                    assert diagnostic['sites']
                assert {row['role'] for row in gate['diagnostics']} == {'baseline', 'candidate'}
            else:
                assert verify(gate['diagnostic']['parent']) == verify(manifest['variants']['candidate'])
                assert set(gate['diagnostic']['workers']) == {'unary.first', 'unary.middle', 'unary.last'}
                assert set(gate['diagnostic']['chooserSites']) == {'unary.pick_first', 'unary.pick_middle', 'unary.pick_last'}
                assert gate['refusals'] == owner['refusals']
                assert len([r for r in gate['structures'] if r.get('kind') == 'deep-actual-worker' and r['n'] == 30000]) == 2
                assert {r['label'] for r in gate['order']} == {'pre', 'child', 'post'}
        else:
            derived_file = document(resolve(entry['derivation']), 'derive.json')
            derived = read(derived_file)
            assert derived_file in inputs and derived['complete'] is True
            assert verify(derived['attempt']) == attempt_file
            tool_check(HERE/owner['deriver'], derived['inputs'], derived_file.parent/'consumed-derive.mjs')
            command_check(execution, tool, [derived_file.parent, file.parent])
            if name == 'guard':
                assert derived['kind'] == 'phase39-checked-scalar-root-scope'
                assert verify(derived['api']) == verify(attempt['api'])
                assert len(derived['guardNames']) == len(set(derived['guardNames'])) == 26
                emitted = emission(verify(derived['receipt']), owner['sourceSha256'], 'candidate')
                pairs = [('baseline', owner['baselineModuleSha256']), ('scope', emitted['output']['sha256'])]
                for variant, expected in pairs:
                    rows = [r for r in derived['modules'] if r['variant'] == variant]
                    assert len(rows) == 2 and {r['counters'] for r in rows} == {False, True}
                    clean, counter = (next(r for r in rows if r['counters'] == value) for value in [False, True])
                    assert clean['sha256'] == expected and verify(counter) in inputs
                assert len([r for r in gate['observations'] if r['kind'] == 'ordinary']) == 5
                assert len([r for r in gate['observations'] if r['kind'] == 'injected-error-reentry']) == 1
                baseline_receipt = emission(verify(owner['baselineReceipt']), owner['sourceSha256'], 'baseline')
                assert baseline_receipt['output']['sha256'] == owner['baselineModuleSha256']
            else:
                assert derived['kind'] == 'phase39-actual-structural-component' and derived['checked'] is True
                assert verify(derived['successor']['parent']) == verify(spec['files']['selfhost/tools/performance/phase39/component-actual-derive.mjs'])
                compiler_check(derived['compiler'], attempt)
                compiler_check(gate['compiler'], attempt)
                assert verify(gate['attempt']) == attempt_file
                assert derived['source']['sha256'] == manifest['source']['sha256']
                assert verify(derived['typescript']) == verify(manifest['variants']['typescript'])
                for variant, role in [('original', 'baseline'), ('direct', 'candidate')]:
                    rows = [r for r in derived['modules'] if r['variant'] == variant]
                    assert len(rows) == 2 and {r['counters'] for r in rows} == {False, True}
                    for row in rows:
                        assert verify(row['parent']) == verify(manifest['variants'][role])
                        assert verify(row['emission']) == verify(manifest['emissions'][role])
                        if row['counters']:
                            assert verify(row) in inputs
                        else:
                            assert row['sha256'] == row['parent']['sha256']
                        assert set(row['closure']['callTargets']) <= set(row['closure']['declarations'])
                        expected_tail = 1 if variant == 'direct' else 0
                        assert row['tailWorker'] == row['tailLeafSites'] == expected_tail
                        assert row['rootSites'] == row['admissionSites'] == (4 if variant == 'direct' else 3)
                tail_file, tail_execution = resolve(entry['tailReport']), resolve(entry['tailExecution'])
                tail = read(tail_file)
                assert tail['kind'] == owner['tailKind'] and tail['complete'] is True and tail['pass'] is True
                assert not tail.get('error') and not tail.get('current') and tail['node'] == gate['node']
                for key, count in owner['tailCounts'].items():
                    assert len(tail[key]) == count, ('component-tail', key, count)
                assert verify(tail['attempt']) == attempt_file
                compiler_check(tail['compiler'], attempt)
                tail_tool = tool_check(HERE/owner['tailControls'], tail['inputs'], tail_file.parent/'consumed-controls.mjs')
                tail_inputs = {verify(ref) for ref in tail['inputs']}
                assert derived_file in tail_inputs
                assert all(verify(row) in tail_inputs for row in derived['modules'] if row['counters'])
                command_check(tail_execution, tail_tool, [derived_file.parent, tail_file.parent])
                assert len([r for r in tail['oracle'] if r['kind'] == 'deep-actual-tail' and r['depth'] == 30000]) == 1
                assert len([r for r in tail['oracle'] if r['kind'] == 'independent-tail-value-and-terminal-alias']) == 12
                assert tail['admission'][0]['kind'] == 'ordinary-tail-source-entry' and tail['admission'][0]['value'] == 41
                assert {r['name'] for r in tail['boundaries']} == {
                    n+':'+k for n in ['component.tail','component.makeA','component.score','tail_check']
                    for k in ['wrap','getter','binding']} | {'public-tail:'+k for k in
                    ['tag','left','right','left-error','right-error','deferred','deferred-error']}
                scan(tail_file)
                report['tail'] = dict(report=identity(tail_file), execution=identity(tail_execution), counts=owner['tailCounts'])
                assert len([r for r in gate['admission'] if r['kind'] == 'deep-tail-cycle' and r['steps'] == 30000]) == 2
            scan(derived_file)
        closure = scan(file)
        report['cases'].append(dict(name=name, report=identity(file), execution=identity(execution),
                                   counts=owner['counts'], identityDocuments=len(closure)))
    for row in observed.values():
        assert identity(row['file']) == row, ('Changed during audit', row['file'])
    for key, row in git_observed.items():
        assert git_identity(*key) == row, ('Changed pinned Git provenance', key)
    report.update(attempt=identity(attempt_file), api=attempt['api'], runtime=attempt['runtime'],
        spec=identity(spec_file), mapping=identity(mapping_file), verifiedIdentities=list(observed.values()),
        verifiedGitProvenance=list(git_observed.values()), complete=True, **{'pass': True})
except Exception as error:
    report['error'] = repr(error)
    raise
finally:
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2)+'\n')
print(json.dumps(dict(complete=True, groups=len(report['cases']), identities=len(observed), output=str(out))))
