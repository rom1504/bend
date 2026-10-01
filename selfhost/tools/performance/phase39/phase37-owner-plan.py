#!/usr/bin/env python3
"""Freeze Phase37 cast/DataView/finite gates for one Phase39 image; execute nothing."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parents[4]
PHASE37 = ROOT/'selfhost/tools/performance/phase37'
TOOLS = PHASE37/'optimizer'
PIN = '018751270e800bc222a93dad7f257083ee53a5f7'
ap = argparse.ArgumentParser(description=__doc__)
ap.add_argument('attempt', type=Path)
ap.add_argument('prepared', type=Path, help='Complete 45-point candidate preparation from this exact image')
ap.add_argument('out', type=Path)
ap.add_argument('--baseline-attempt', type=Path, default=ROOT/'selfhost/build/phase36/checked03')
a = ap.parse_args()
attempt, prepared, out = (p.resolve() for p in [a.attempt, a.prepared, a.out])
baseline = a.baseline_attempt.resolve()
assert not out.exists()
inputs = {}


def identity(file):
    file = Path(file).resolve()
    h = hashlib.sha256()
    with file.open('rb') as stream:
        for block in iter(lambda: stream.read(2**20), b''):
            h.update(block)
    return dict(file=str(file), sha256=h.hexdigest(), bytes=file.stat().st_size)


def keep(file, expected=None):
    row = identity(file)
    if expected:
        assert row['sha256'] == expected['sha256'], row['file']
        if 'bytes' in expected:
            assert row['bytes'] == expected['bytes'], row['file']
        if 'canonicalPath' in expected:
            assert row['file'] == expected['canonicalPath'], row['file']
    if row['file'] in inputs:
        assert inputs[row['file']] == row, row['file']
    inputs[row['file']] = row
    return row


def ref(row, base=ROOT):
    file = Path(row.get('file', row.get('path')))
    return Path(keep(file if file.is_absolute() else base/file, row)['file'])


def read(file):
    keep(file)
    return json.loads(Path(file).read_text())


def save(file, value):
    file.write_text(json.dumps(value, indent=2)+'\n')


selected = read(attempt/'attempt.json')
old = read(baseline/'attempt.json')
assert selected['kind'] == old['kind'] == 'bend-development-attempt'
assert selected['checked'] is True and selected['artifactKind'] == 'derived-b1'
assert selected['config']['strictExact'] and selected['config']['jobs'] == 1
assert str(selected['config']['cpu']) == '3' and 0 < selected['config']['heapMb'] <= 1024
assert old['checked'] and old['api']['sha256'] == '93e55ad7ee456eebb5fa3dd9606c2cf262ea386c6f66bfd891ffe187d8f50a75'
for image in [selected, old]:
    for key in ['api', 'checkedApi', 'runtime', 'base', 'node', 'bootstrapReport', 'derivationReport']:
        ref(image[key])
    for row in image['snapshot']['sources']:
        ref(row['frozen'])
        assert row['frozen']['sha256'] == row['original']['sha256']
node = ref(selected['node'])
upstream = Path(selected['config']['upstream']).resolve()
catalog_file = PHASE37/'catalog.json'
catalog = read(catalog_file)
assert catalog['upstreamCommit'] == PIN
bundle = read(prepared/'manifest.json')
assert bundle['kind'] == 'bend-program-bundle' and bundle['complete'] is True
assert bundle['upstreamCommit'] == PIN and bundle['catalogSha256'] == identity(catalog_file)['sha256']
assert set(bundle['roles']) == {'candidate'}
compiler = bundle['roles']['candidate']['compiler']
assert compiler['kind'] == 'checked-development-attempt' and compiler['artifact'] == 'derived-b1'
assert compiler['upstreamCommit'] == PIN
for key in ['api', 'runtime', 'base']:
    assert ref(compiler[key]) == ref(selected[key])
assert ref(compiler['driver']) == Path(selected['snapshot']['root'])/'tools/typed-driver.mjs'
assert compiler['sourceSha256'] == read(ref(selected['bootstrapReport']))['sourceSha256']
preparation_file = ref(bundle['preparation'], prepared)
preparation = read(preparation_file)
assert preparation['kind'] == 'bend-program-preparation' and preparation['complete'] is True
assert ref(preparation['catalog']) == catalog_file
lookup = {case['id']: case for case in catalog['cases']}
assert len(bundle['cases']) == len(lookup) == 45
assert {case['id'] for case in bundle['cases']} == set(lookup)
assert len(preparation['sources']) == len({case['source']['path'] for case in catalog['cases']}) == 23
raw_modules = set()
source_modules = {}
for source in preparation['sources']:
    assert source['process']['complete'] and source['process']['returncode'] == 0
    source_file = ref(source['source'])
    emission = read(ref(source['emission'], prepared))
    assert emission['kind'] == 'bend-program-checked-emission' and emission['complete']
    assert emission['observation']['checked'] and emission['observation']['status'] == 'ok'
    assert emission['observation']['typeAccepted'] and emission['observation']['exitCode'] == 0
    assert emission['compiler'] == compiler and ref(emission['attempt']) == attempt/'attempt.json'
    assert ref(emission['input']) == source_file
    raw_module = ref(emission['output'])
    raw_modules.add(raw_module)
    assert emission['input']['sha256'] not in source_modules
    source_modules[emission['input']['sha256']] = raw_module
    ref(emission['producer']); ref(emission['catalog'])
    for verifier in emission['verifiers']:
        ref(verifier)
adapted_modules = set()
adapted_parents = {}
for adapter in preparation['adapters']:
    assert adapter['kind'] == 'complete-generic-row-serialization'
    raw = ref(adapter['raw'], prepared)
    assert raw in raw_modules
    ref(adapter['producer'])
    adapted = ref(adapter['adapted'], prepared)
    adapted_modules.add(adapted)
    assert adapted not in adapted_parents
    adapted_parents[adapted] = raw
for case in bundle['cases']:
    expected = lookup[case['id']]
    assert case['point'] == expected['point'] and case['sourceSha256'] == expected['source']['sha256']
    ref(expected['source'], catalog_file.parent)
    module = ref(case['modules']['candidate'], prepared)
    assert module in (adapted_modules if expected.get('adapter') else raw_modules)
    assert (adapted_parents[module] if expected.get('adapter') else module) == source_modules[case['sourceSha256']]

tool_names = ['native-cast-acquire-v1.mjs', 'native-cast-actual-derive-v4.mjs',
             'native-cast-actual-controls-v5.mjs', 'native-cast-actual-dataview-controls-v4.mjs',
             'finite-acquire-v5.py', 'finite-acquire-v4.py', 'finite-controls-v2.mjs',
             'finite-fixture-v5.bend', 'native-cast-fixture-v1.bend', 'native-cast-fixture-v1.json']
files = [TOOLS/name for name in tool_names] + [Path(__file__), PHASE37/'owner-close-v2.py',
    PHASE37/'owner-close.py', PHASE37/'fixtures-new/points-v1.json',
    PHASE37.parent/'phase32/bounded-run.py', PHASE37.parent/'phase35/final-integration-run.py',
    PHASE37.parent/'programs/support.py', PHASE37.parent/'programs/emit-worker.mjs',
    PHASE37.parent/'programs/catalog.json', ROOT/'selfhost/tools/development/workflow.mjs',
    ROOT/'selfhost/tools/development/release.mjs']
for file in files:
    keep(file)
out.mkdir()
(out/'consumed').mkdir()
for file in files:
    target = out/'consumed'/file.name
    assert not target.exists()
    shutil.copyfile(file, target)
    keep(target)
commands = []


def command(name, argv, seconds, scope, self_supervised=False):
    argv = ['taskset', '-c', '3', *map(str, argv)]
    wrapper = [sys.executable, str(PHASE37.parent/'phase32/bounded-run.py'), '--seconds', str(seconds),
               '--rss-mib', '2048', '--available-mib', '2048', str(out/('run-'+name)), '--', *argv]
    commands.append(dict(name=name, command=argv, supervisedCommand=argv if self_supervised else wrapper,
        selfSupervised=self_supervised, cpu=3, outerTimeoutSeconds=seconds, treeRssMiB=2048,
        availableFloorMiB=2048, scope=scope, stage='owner', executed=False))


node_args = [node, '--stack-size=4096', '--max-old-space-size=1024']
cast, derived, finite = out/'cast-acquisition', out/'cast-derived', out/'finite-cohort'
command('cast-acquire', [*node_args, TOOLS/'native-cast-acquire-v1.mjs', baseline, attempt, upstream, cast],
        600, 'Three fresh checked emissions; Phase36 is the frozen semantic comparator, not a speed comparator.')
command('cast-derive', [*node_args, TOOLS/'native-cast-actual-derive-v4.mjs', cast/'original.mjs',
        cast/'candidate.mjs', cast/'typescript.mjs', attempt, derived], 120,
        'Unchanged actual-output instrumentation; clean outputs remain compiler emitted.')
command('cast', [*node_args, TOOLS/'native-cast-actual-controls-v5.mjs', derived,
        PHASE37/'fixtures-new/points-v1.json', out/'cast'], 120, 'Unchanged 44 oracles, 57 boundaries and 7 admission observations.')
command('dataview', [*node_args, TOOLS/'native-cast-actual-dataview-controls-v4.mjs', derived, out/'dataview'],
        120, 'Unchanged 22 DataView observations.')
command('finite-acquire', [sys.executable, TOOLS/'finite-acquire-v5.py', '--attempt', attempt,
        '--baseline-attempt', baseline, '--upstream', upstream, '--out', finite, '--node', node,
        '--cpu', '3', '--rss-mib', '2048', '--available-mib', '2048', '--timeout', '180'],
        600, 'Self-supervised serial cohort; never nest the shared lock.', self_supervised=True)
command('finite', [*node_args, TOOLS/'finite-controls-v2.mjs', finite/'finite/baseline.mjs',
        finite/'finite/candidate.mjs', finite/'finite/typescript.mjs', out/'finite'], 180,
        'Unchanged 154 oracles, 9 admission observations and 76 boundaries, including deep tail cycles.')
mapping = {name: dict(report=str(out/name/'report.json'), execution=str(out/('run-'+name)/'run.json'))
           for name in ['cast', 'dataview', 'finite']}
save(out/'mapping.json', mapping)
keep(out/'mapping.json')
command('close', [sys.executable, PHASE37/'owner-close-v2.py', attempt, derived, finite,
        out/'mapping.json', out/'closure/report.json'], 120,
        'Unchanged Phase37 owner auditor closes actual selected API, all receipt edges and exact historical counts.')
for row in inputs.values():
    assert identity(row['file']) == row
save(out/'plan.json', dict(kind='phase35-final-integration-plan', phase='phase39-inherited-phase37-owners',
    complete=True, executed=False, attempt=keep(attempt/'attempt.json'), api=selected['api'],
    prepared=keep(prepared/'manifest.json'), inputs=list(inputs.values()), commands=commands,
    assertionPolicy='No historical tool source or semantic assertion changes; all acquisitions and outputs are new.',
    scope='Three inherited Phase37 groups only. Phase35/36 owners, new Phase39 owners, frontend/backend, performance and installation remain separate.',
    execution='Use unchanged Phase35 final-integration-run.py --stage owner. Do not wrap the runner in the shared supervisor.'))
print(json.dumps(dict(complete=True, executed=False, commands=len(commands), out=str(out), api=selected['api']['sha256'])))
