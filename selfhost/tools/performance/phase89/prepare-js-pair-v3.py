#!/usr/bin/env python3
"""Offline paired checked-JS-B1 plan for the unchanged Phase83 request worker."""
import argparse
import hashlib
import json
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
P = ROOT/'selfhost/tools/performance'
OLD = ROOT/'selfhost/build/phase88/js-development01'
HOST_FILES = {'tools/'+n+'.mjs' for n in ('typed-driver', 'assemble', 'native-build',
    'node-resource-args', 'compiler-abi', 'base-cache-graph')}
HOST_FILES.update(('src/runtime.mjs', 'src/compiler.json'))


def read(path):
    return json.loads(Path(path).read_text())


def pin(path):
    path = Path(path).resolve()
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return dict(file=str(path), sha256=digest.hexdigest(), bytes=path.stat().st_size)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('attempt', type=Path)
    ap.add_argument('out', type=Path)
    ap.add_argument('--rounds', type=int, default=2)
    ap.add_argument('--shadow-receipt', type=Path, required=True)
    ap.add_argument('--shadow-sha256', required=True)
    a = ap.parse_args()
    assert 1 <= a.rounds <= 5
    out = a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase89') and not out.exists()
    inputs, copies, roles, admissions = {}, [], {}, {}

    def remember(path, expected=None):
        actual = pin(path)
        if expected:
            assert actual['sha256'] == expected['sha256'], str(path)
            assert 'bytes' not in expected or actual['bytes'] == expected['bytes'], str(path)
        prior = inputs.setdefault(actual['file'], actual)
        assert prior == actual
        return actual

    evidence_path = ROOT/'implementation/phase88/evidence.json'
    evidence = read(evidence_path)
    archive = ROOT/evidence['archive']['file']
    archive_pin = pin(archive)
    assert all(archive_pin[k] == evidence['archive'][k] for k in ('sha256', 'bytes'))
    manifest_path = ROOT/evidence['manifest']['file']
    manifest_pin = pin(manifest_path)
    assert all(manifest_pin[k] == evidence['manifest'][k] for k in ('sha256', 'bytes'))
    sealed = {p['file']: p for p in read(manifest_path)}
    z = zipfile.ZipFile(archive)

    def archived(path):
        name = str(Path(path).relative_to(ROOT))
        data = z.read(name)
        assert hashlib.sha256(data).hexdigest() == sealed[name]['sha256']
        assert len(data) == sealed[name]['bytes']
        return data

    for method in [Path(__file__), P/'phase83/worker.mjs', P/'phase83/run.py', P/'programs/support.py']:
        remember(method)
    shadow_receipt = a.shadow_receipt.resolve()
    shadow = read(shadow_receipt)
    remember(shadow_receipt, {'sha256': a.shadow_sha256})
    assert shadow['complete'] and not shadow['compiled']
    assert shadow['sourceFiles'] == 333 and shadow['productionModulesVerified'] == 132
    kinds = {'phase89-ordinary-js-shadow-project': 10,
             'phase89-ordinary-js-owned-shadow-project': 1}
    assert shadow['overriddenModules'] == kinds[shadow['kind']]
    if shadow['overriddenModules'] == 1:
        assert [x['relative'] for x in shadow['overrides']] == ['src/back/native/bridge.bend']
    remember(shadow['config']['file'], shadow['config'])
    shadow_root = Path(shadow['config']['file']).with_suffix('').with_suffix('')
    shadow_outputs = {str(Path(p['file']).relative_to(shadow_root)): p for p in shadow['outputs']}
    out.mkdir(parents=True)
    old_inventory = None
    for label, attempt_path in [('baseline', OLD/'attempt.json'), ('candidate', a.attempt.resolve())]:
        remember(attempt_path)
        attempt = read(attempt_path)
        if label == 'baseline':
            assert attempt_path.read_bytes() == archived(attempt_path)
        assert attempt['checked'] and attempt['artifactKind'] == 'derived-b1'
        assert attempt['config']['profile'] == 'equality'
        directory = attempt_path.parent
        build_path, validation_path = directory/'build.json', directory/'validation-001/report.json'
        build, validation = read(build_path), read(validation_path)
        remember(build_path); remember(validation_path)
        assert build['complete'] and validation['complete'] and validation['pass'] and validation['strictExact']
        api = remember(attempt['api']['file'], attempt['api'])
        raw = remember(attempt['checkedApi']['file'], attempt['checkedApi'])
        assert build['api']['sha256'] == validation['api']['sha256'] == api['sha256']
        bootstrap_pin = remember(attempt['bootstrapReport']['file'], attempt['bootstrapReport'])
        bootstrap = read(bootstrap_pin['file'])
        assert bootstrap['stage'] == 'upstream-bootstrap' and bootstrap['revision'] == '059266225b77c8ca256ac6b25ee5c21449bab151'
        assert bootstrap['apiSha256'] == raw['sha256'] and bootstrap['provenance']['verifiedAfterBuild']
        derivative_pin = remember(attempt['derivationReport']['file'], attempt['derivationReport'])
        derivative = read(derivative_pin['file'])
        assert derivative['kind'] == 'bend-derived-b1-equality' and derivative['complete']
        assert derivative['original']['api']['sha256'] == raw['sha256']
        assert derivative['original']['bootstrapReport']['sha256'] == bootstrap_pin['sha256']
        assert derivative['output']['sha256'] == api['sha256']
        node = remember(attempt['node']['file'], attempt['node'])
        base = remember(attempt['base']['file'], attempt['base'])
        assert bootstrap['baseSha256'] == base['sha256']
        snapshot = Path(attempt['snapshot']['root'])
        inventory = {str(Path(r['frozen']['file']).relative_to(snapshot)): r['frozen'] for r in attempt['snapshot']['sources']}
        assert len(inventory) == 333
        if label == 'baseline':
            old_inventory = inventory
        else:
            assert set(inventory) == set(shadow_outputs)
            assert all(p['sha256'] == shadow_outputs[n]['sha256'] for n, p in inventory.items())
        selected = [n for n in inventory if n in HOST_FILES or n.startswith('src/runtime/native/')]
        assert HOST_FILES <= set(selected)
        project = out/label/'project'
        for rel in selected:
            original = inventory[rel]
            assert original['sha256'] == old_inventory[rel]['sha256'], f'Host changed: {rel}'
            data = archived(original['file']) if label == 'baseline' else Path(original['file']).read_bytes()
            assert hashlib.sha256(data).hexdigest() == original['sha256']
            target = project/rel
            target.parent.mkdir(parents=True, exist_ok=True)
            with target.open('xb') as stream:
                stream.write(data)
            copied = remember(target)
            copies.append(dict(role=label, original=original, copy=copied,
                transport='authenticated-phase88-archive' if label == 'baseline' else 'checked-attempt-snapshot'))
        roles[label] = dict(api=api, node=node, base=base, project=str(project),
            driver=remember(project/'tools/typed-driver.mjs'), runtime=remember(project/'src/runtime.mjs'),
            nativeProducts=False, preparation=str(out/'runs'/f'prepare-{label}'/'report.json'))
        admissions[label] = dict(attempt=pin(attempt_path), build=pin(build_path),
            validation=pin(validation_path), rawApi=raw, selectedApi=api,
            bootstrap=bootstrap_pin, derivative=derivative_pin)
    assert roles['baseline']['node'] == roles['candidate']['node']
    assert roles['baseline']['base'] == roles['candidate']['base']
    assert roles['baseline']['api']['sha256'] != roles['candidate']['api']['sha256']

    screen_path = ROOT/'selfhost/build/phase88/screen01/plan.json'
    screen_report = screen_path.with_name('report.json')
    assert screen_path.read_bytes() == archived(screen_path)
    assert screen_report.read_bytes() == archived(screen_report)
    remember(screen_path); remember(screen_report)
    screen, observed = read(screen_path), read(screen_report)
    assert observed['complete'] and observed['allJobsSucceeded']
    source_inputs = {p.get('file', p.get('path')): p for p in screen['inputs']}
    cases = {}
    for name, path in screen['cases'].items():
        source = remember(path, source_inputs[path])
        row = next(r for r in observed['rows'] if r['case'] == name and r['role'] == 'b2')
        assert row['guard']['complete'] and row['guard']['returncode'] == 0 and len(row['outputs']) == 1
        oracle = row['outputs'][0]
        old_path = oracle.get('file', oracle.get('path'))
        data = archived(old_path)
        assert hashlib.sha256(data).hexdigest() == oracle['sha256'] and len(data) == oracle['bytes']
        target = out/'oracles'/f'{name}.c'
        target.parent.mkdir(exist_ok=True)
        with target.open('xb') as stream:
            stream.write(data)
        expected = remember(target)
        cases[name] = dict(input=source, expected={r: expected for r in roles},
            oracleOrigin=dict(report=pin(screen_report), row=row['name'], original=oracle))
    assert len(cases) == 6
    derivations = ROOT/'selfhost/build/phase86/fixtures/provenance.json'
    remember(derivations)
    jobs = [dict(name=f'prepare-{r}', role=r, action='prepare', profile=False) for r in roles]
    for rnd in range(a.rounds):
        for i, case in enumerate(cases):
            order = list(roles)
            if (rnd+i) % 2:
                order.reverse()
            jobs.extend(dict(name=f'clean-{rnd+1}-{case}-{r}', role=r, case=case,
                action='request', profile=False, withReport=True, round=rnd+1) for r in order)
    plan = dict(kind='phase68-native-compilation-plan', version=3, status='prepared-unexecuted',
        producer=pin(__file__), roles=roles, cases=cases, jobs=jobs, cpu=3,
        nodeArgs=['--max-old-space-size=1024', '--stack-size=4096'],
        seconds=90, rssMiB=2048, availableMiB=4096, admissions=admissions, copies=copies,
        sourceDerivations=pin(derivations), archiveTransport=dict(archive=archive_pin, manifest=manifest_pin),
        inputs=list(inputs.values()), scope='Paired Phase88/candidate ordinary checked JS B1 equality profiles. Six identical sources and retained B2 C outputs; two rotated cold rounds by default. Each role prepares its own API-specific Base cache. No TypeScript requests, native host, optional native products, warm-call inference, compiled-program timing or promotion claim.')
    assert all(pin(p['file']) == p for p in inputs.values())
    with (out/'plan.json').open('x') as stream:
        stream.write(json.dumps(plan, indent=2)+'\n')
    print(json.dumps(dict(plan=pin(out/'plan.json'), cases=len(cases), jobs=len(jobs),
        targetJobsRun=0, instructions='Run phase83/run.py --plan PLAN --group prepare, then --group clean. Fifth-call comparison requires a separate explicit repeated-request worker/plan.'), indent=2))


if __name__ == '__main__':
    main()
