#!/usr/bin/env python3
"""Metadata-only Phase134 validation adapter; never launch compiler targets.

Freeze the measured Phase131 N2 and qualified N3 separately. Candidate plans
reuse original request, aligned-build, focused/full45 and timing supervisors.
Only role bindings change; ordinary and repetition-wrapper oracles stay distinct.
"""
import argparse
import copy
import filecmp
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
BUILD = ROOT / 'selfhost/build'
TOOLS = ROOT / 'selfhost/tools/performance'
SELECTION = ROOT / 'implementation/phase131/final/candidate.json'
SELECTION_SHA = '6e55f7b0b0b30e74459c2d2320cb5febb9da9499f55b28972fc904e331791bdb'
FROZEN = TOOLS / 'phase131/native/timing-plan.py'
REQUEST = TOOLS / 'phase130/native-request.py'
GUARD = TOOLS / 'phase111/guard.py'


def pin(path):
    path = Path(path).resolve(); h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1048576), b''): h.update(chunk)
    return dict(file=str(path), bytes=path.stat().st_size, sha256=h.hexdigest())


def read(path): return json.loads(Path(path).read_text())


def require(ok, why):
    if not ok: raise ValueError(why)


def verify(item):
    require(pin(item['file']) == item, 'Changed input: ' + item['file'])
    return Path(item['file'])


def load(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec); spec.loader.exec_module(result)
    return result


def save(path, value):
    path = Path(path).resolve()
    require(path.is_relative_to(BUILD / 'phase134') and not path.exists(), 'Fresh Phase134 metadata path required')
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as f: json.dump(value, f, indent=2); f.write('\n')


def authorities():
    require(pin(SELECTION)['sha256'] == SELECTION_SHA, 'Phase131 selection changed')
    require(pin(FROZEN)['sha256'] == 'de623e0e5366a0bc5df27de16a2ea8bed590cbef191a8380326e8cd104e2086a', 'Frozen timing helper changed')
    t = load(FROZEN, 'p134_frozen_timing')
    require(pin(t.BASE)['sha256'] == t.BASE_SHA and pin(t.RUNNER)['sha256'] == t.RUNNER_SHA, 'Timing policy changed')
    parent, base = read(SELECTION), read(t.BASE)
    require(parent['complete'] and parent['nativeQualified'] and parent['runtime'] == base['runtime'], 'Qualified parent/runtime required')
    require(parent['compilerTiming']['measuredImage'] == parent['n2'] and parent['finalImage'] == parent['n3'], 'N2 timing and N3 qualification identities differ')
    require(pin(REQUEST) == parent['entryPoints']['requestTool'], 'Original native request transport changed')
    return parent, base, t


def freeze(out):
    parent, base, t = authorities()
    keep = ['source', 'sourceManifest', 'checkedApi', 'api', 'runtime', 'runtimeReport', 'n2', 'n3', 'qualificationArchive', 'preferredCarrierReceipt']
    inputs = [pin(__file__), pin(SELECTION), pin(FROZEN), pin(t.BASE), pin(t.RUNNER), pin(GUARD), pin(REQUEST)] + [parent[k] for k in keep]
    timing = parent['compilerTiming']['parentComparison']['rawReport']
    equality = parent['generatedPrograms']['equality']; screen = parent['generatedPrograms']['measuredScreen']
    for item in [*inputs, timing, equality, screen]: verify(item)
    old, eq = read(timing['file']), read(equality['file'])
    require(old['complete'] and old['passed'] and old['roles']['phase112']['binary'] == parent['n2'], 'N2 timing evidence differs')
    require(eq['complete'] and eq['all45ByteExact'] and eq['image'] == parent['n2'] and eq['runtime'] == parent['runtime'] and eq['measuredScreen'] == screen, 'Native wrapper evidence differs')
    cases = []
    for case in base['cases']:
        rows = [r for r in old['rows'] if r['name'] == case['name'] and r['role'] == 'phase112']
        require(len(rows) == 3 and all(r['passed'] for r in rows) and len({r['representation']['sha256'] for r in rows}) == 1, 'Three stable parent request products required')
        cases.append(dict(name=case['name'], source=case['source'], expectedQbe=rows[0]['representation']))
    wrappers = [dict(name=r['name'], source=r['source'], expectedQbe=r['nativeQbe'], measuredBinary=r['measuredBinary']) for r in eq['cases']]
    require(len(wrappers) == 45 and len({r['name'] for r in wrappers}) == 45, 'Original45 wrappers required')
    for row in cases + wrappers:
        for key in ['source', 'expectedQbe', 'measuredBinary']:
            if key in row: verify(row[key])
    record = dict(kind='phase134-frozen-phase131-reference', complete=True, targetsRun=False,
        inputs=inputs + [timing, equality, screen], source=parent['source'], measuredN2=parent['n2'], qualifiedFallbackN3=parent['n3'],
        runtime=parent['runtime'], carrierReceipt=parent['preferredCarrierReceipt'], parentTiming=timing, wrapperEquality=equality,
        measuredProgramScreen=screen, cases=cases, wrappers=wrappers,
        scope='N2 is the compiler timing reference; N3 is the independently qualified fallback. Historical times are evidence only: every new ratio uses fresh same-block parent observations. No Phase128/130 parent substitution.')
    save(out, record); return record


def reference(path):
    r = read(path)
    require(r['kind'] == 'phase134-frozen-phase131-reference' and r['complete'], 'Frozen Phase134 reference required')
    parent, base, t = authorities()
    require(r['measuredN2'] == parent['n2'] and r['qualifiedFallbackN3'] == parent['n3'] and r['runtime'] == parent['runtime'], 'Reference roles changed')
    for item in r['inputs']: verify(item)
    require(r['carrierReceipt'] == parent['preferredCarrierReceipt'] and r['source'] == parent['source'], 'Reference source/carrier changed')
    require([(c['name'], c['source']) for c in r['cases']] == [(c['name'], c['source']) for c in base['cases']], 'Frozen three-request corpus changed')
    old = read(parent['compilerTiming']['parentComparison']['rawReport']['file'])
    for case in r['cases']:
        expected = next(x['representation'] for x in old['rows'] if x['name'] == case['name'] and x['role'] == 'phase112')
        require(case['expectedQbe'] == expected, 'Parent request product changed')
    eq = read(parent['generatedPrograms']['equality']['file'])
    expected = [dict(name=x['name'], source=x['source'], expectedQbe=x['nativeQbe'], measuredBinary=x['measuredBinary']) for x in eq['cases']]
    require(r['wrappers'] == expected and r['measuredProgramScreen'] == parent['generatedPrograms']['measuredScreen'], 'Measured wrapper binding changed')
    return r, parent, base, t


def candidate(a, ref, base, t):
    manifest, api, emission, build = map(read, [a.source_manifest, a.checked_api, a.emission, a.build])
    source = manifest['source']; runtime = ref['runtime']
    require(manifest.get('complete') and api.get('kind') == 'phase111-checked-api' and api.get('complete') and api.get('checked') and api.get('status') == 0 and source in api['inputs'], 'Independent checked candidate source required')
    require(emission.get('kind') == 'phase130-native-source-qbe-request' and emission.get('complete') and emission.get('exitCode') == 0 and not emission.get('changedInputs') and emission['stderr']['bytes'] == 0, 'Successful complete native acquisition required')
    require(emission['source'] == source and emission['runtime'] == runtime and ref['carrierReceipt'] in emission['inputs'], 'Acquisition source/runtime/carrier differs')
    allowed = [ref['measuredN2'], ref['qualifiedFallbackN3']]
    if a.producer_plan:
        previous = read(a.producer_plan)
        require(previous.get('kind') == 'phase134-candidate-validation-plan' and previous['source'] == source and previous['runtime'] == runtime, 'Previous same-source candidate plan required')
        for item in previous['inputs']: verify(item)
        allowed.append(previous['image'])
    require(emission['image'] in allowed, 'Acquisition must use qualified parent or recorded same-source predecessor')
    image = t.Q.build(build, emission['product'], runtime, base['tools'])
    inputs = [pin(p) for p in [__file__, a.reference, a.source_manifest, a.checked_api, a.emission, a.build]] + [source, api['api'], image, runtime, emission['image'], emission['product']]
    if a.producer_plan: inputs.append(pin(a.producer_plan))
    # Preserve the independent frontend/tool identities from the selected checked API.
    parent_api = read(read(SELECTION)['checkedApi']['file'])
    for item in parent_api['inputs']:
        path = Path(item['file'])
        if (path.parent.name == 'bend2' and path.name in {'bend.ts', 'comp.ts', 'base.bend'}) or path.name == 'bun':
            require(item in api['inputs'], 'Independent checking toolchain changed')
    for item in [*inputs, *api['inputs'], *emission['inputs']]: verify(item)
    return dict(source=source, image=image, runtime=runtime, inputs=inputs, generation=a.generation)


def guarded(out, name, seconds, command, cpu='3'):
    return dict(name=name, seconds=seconds + 15, command=[sys.executable, '-B', str(GUARD), '--out', str(out.parent / (out.stem + '-' + name + '-guard')), '--seconds', str(seconds), '--rss-mib', '4096', '--available-mib', '16384', '--file-mib', '256', '--cpu', cpu, '--', *map(str, command)])


def request_job(out, tag, image, receipt, case):
    dest = BUILD / 'phase130' / (tag + '-' + case['name'])
    require(not dest.exists(), 'Request destination already exists')
    cmd = [sys.executable, '-B', REQUEST, '--image', image['file'], '--source', case['source']['file'], '--carrier-receipt', receipt['file'], '--out', dest, '--seconds', '30', '--expected-qbe', case['expectedQbe']['file']]
    return guarded(out, case['name'], 60, cmd), str(dest / 'report.json')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('action', choices=['freeze', 'candidate', 'timing', 'finish-wrappers'])
    p.add_argument('--out', type=Path, required=True)
    for name in ['reference', 'source-manifest', 'checked-api', 'emission', 'build', 'producer-plan', 'focused', 'plan']:
        p.add_argument('--' + name, type=Path)
    p.add_argument('--tag'); p.add_argument('--generation', choices=['N1', 'N2', 'N3'], default='N1')
    a = p.parse_args(); out = a.out.resolve()
    require(not out.exists() and out.is_relative_to(BUILD / 'phase134'), 'Fresh Phase134 result required')
    if a.action == 'freeze':
        freeze(out); print(json.dumps(dict(complete=True, targetsRun=False, reference=pin(out)))); return
    if a.action == 'finish-wrappers':
        plan = read(a.plan); ref, _, _, _ = reference(plan['reference']['file'])
        require(plan['kind'] == 'phase134-candidate-validation-plan', 'Candidate plan required')
        for item in plan['inputs']: verify(item)
        rows = []
        for case in plan['wrappers']:
            r = read(case['receipt'])
            require(r['complete'] and r['byteExact'] and r['exitCode'] == 0 and not r['changedInputs'] and r['stderr']['bytes'] == 0, 'Native wrapper gate failed')
            require(r['image'] == plan['image'] and r['source'] == case['source'] and r['runtime'] == ref['runtime'] and r['expectedQbe'] == case['expectedQbe'] and ref['carrierReceipt'] in r['inputs'], 'Wrapper lineage changed')
            for item in r['inputs'] + [r['product'], r['stderr'], case['expectedQbe'], case['measuredBinary']]: verify(item)
            require(filecmp.cmp(r['product']['file'], case['expectedQbe']['file'], shallow=False), 'Wrapper full bytes differ')
            rows.append(dict(name=case['name'], receipt=pin(case['receipt']), nativeQbe=r['product'], expectedQbe=case['expectedQbe'], measuredBinary=case['measuredBinary']))
        require(len(rows) == 45, 'All45 wrappers required')
        save(out, dict(complete=True, targetsRun=False, all45ByteExact=True, nativeQualified=False, image=plan['image'], runtime=ref['runtime'], inputs=[pin(__file__), pin(a.plan), plan['reference']], cases=rows, reusedMeasuredScreen=ref['measuredProgramScreen'], scope='Actual native output identity permits reuse of authenticated Phase131 machine products and historical program-runtime evidence. No fresh same-block performance claim; full compiler qualification remains separate.'))
        print(json.dumps(dict(complete=True, all45ByteExact=True))); return
    require(a.reference and a.tag and re.fullmatch(r'p134-[a-z0-9_-]+', a.tag), 'Reference and unique p134 tag required')
    require(all([a.source_manifest, a.checked_api, a.emission, a.build]), 'Checked source and actual native build receipts required')
    ref, parent, base, t = reference(a.reference); c = candidate(a, ref, base, t)
    if a.action == 'timing':
        require(a.focused, 'Focused19 receipt required before timing')
        t.focused(a.focused, c['image'], c['runtime'])
        manifest = copy.deepcopy(base)
        manifest.update(preparedOnly=True, targetsRun=False, researchOnly=True, nativeQualified=False, unqualified=True)
        manifest['roles']['phase111'] = dict(binary=ref['measuredN2'], source=ref['source'], generation='Qualified Phase131 measured N2; fresh process, compact Base', nativeQualified=True, carrierReceipt=ref['carrierReceipt'])
        manifest['roles']['phase112'] = dict(binary=c['image'], source=c['source'], generation='Experimental Phase134 ' + a.generation + '; checked source and focused19 only', nativeQualified=False, carrierReceipt=ref['carrierReceipt'])
        manifest['inputs'] = c['inputs'] + [pin(FROZEN), pin(t.BASE), pin(t.RUNNER), pin(a.focused), pin(SELECTION)]
        manifest['lineage'] = dict(reference=pin(a.reference), actualParent='Phase131 measured N2', candidateGeneration=a.generation, processState='fresh process for every observation', cacheState='prepared Base; no semantic edit cache', sameCompilerSource=c['source'] == ref['source'], nativeQualificationEstablished=False, policy='Unchanged three sources, outputs, 27-row rotated schedule, clocks, aligned machine builds and upstream source-Base path. Request ratios are primary; machine-stage sums have distinct runtime-build policies.')
        save(out, manifest)
        target = BUILD / 'phase112' / a.tag; require(not target.exists(), 'Fresh timing target required')
        command = [sys.executable, '-B', t.RUNNER, '--manifest', out, '--out', target, '--rounds', '3', '--modes', 'cache']
        jobs = [guarded(out, 'timing', 240, command)]
    else:
        jobs, wrappers, requests = [], [], []
        for kind, cases in [('requests', ref['cases']), ('wrappers', ref['wrappers'])]:
            for case in cases:
                job, receipt = request_job(out, a.tag + '-' + kind, c['image'], ref['carrierReceipt'], case)
                job['group'] = kind; jobs.append(job)
                (requests if kind == 'requests' else wrappers).append(dict(case, receipt=receipt))
        for label, tool, selector in [('focused19', 'coverage.py', ['--suite', 'focused']), ('ordinary45', 'full45.py', ['--partition', 'all45'])]:
            dest = BUILD / 'phase111' / (a.tag + '-' + label); require(not dest.exists(), 'Fresh native coverage target required')
            command = [sys.executable, '-B', TOOLS / 'phase125/native' / tool, '--image', c['image']['file'], '--runtime', c['runtime']['file'], '--out', dest, *selector, '--seconds', '60', '--build-seconds', '30']
            job = guarded(out, label, 300, command); job['group'] = label; jobs.append(job)
        result = dict(kind='phase134-candidate-validation-plan', complete=True, targetsRun=False, nativeQualified=False, reference=pin(a.reference), **c, requests=requests, wrappers=wrappers, jobs=jobs, scope='Root executes selected groups serially. Three compact-carrier exact-QBE requests; unchanged focused19/ordinary45 supervisors use their legacy prepared-Base transport. Wrapper equality is distinct from ordinary correctness and fresh runtime timing. This plan grants no qualification or selection.')
        save(out, result)
    jobs_path = out.with_name(out.stem + '-jobs.json')
    save(jobs_path, dict(complete=True, targetsRun=False, inputs=[pin(__file__), pin(out)], jobs=jobs))
    print(json.dumps(dict(complete=True, targetsRun=False, plan=pin(out), jobs=pin(jobs_path))))


if __name__ == '__main__': main()
