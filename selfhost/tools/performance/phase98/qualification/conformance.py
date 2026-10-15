#!/usr/bin/env python3
"""Offline adapt unchanged native69+3 fixtures/harness to two candidate images."""
import argparse
import copy
import json
from pathlib import Path
import sys
from support import Bindings, HERE, ROOT, PERF, S, authenticate, backend_policy, baseline, freeze_methods, native_args, pin, read
from conformance_integrity import execution_inputs, validate_partition


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--b1-build', type=Path, required=True)
    p.add_argument('--b2-build', type=Path, required=True)
    p.add_argument('--backend-policy', type=Path)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); assert not out.exists(); out.mkdir(parents=True)
    b = Bindings(); ctx = baseline(b); freeze_methods(out, b)
    old_pin = b.bind(ROOT / 'selfhost/build/phase92/conformance01/plan.json'); old = read(old_pin['file'])
    assert old['complete'] and old['targetReady'] and len(old['eligible']) == 69 and len(old['excluded']) == 31
    plan = copy.deepcopy(old)
    plan.update(method=pin(__file__), phase98=True, historicalPlan=old_pin, targetExecuted=False, roles={})
    for stage, path in [('b1', a.b1_build), ('b2', a.b2_build)]:
        receipt = read(path)
        producer = authenticate(receipt['binary']['file'], stage, receipt['source']['file'], path, b, ctx)
        plan['roles'][stage] = dict(producer=producer, argv=native_args(ctx, producer, plan['sourceMarker'], plan['outputMarker']))
    assert plan['roles']['b1']['producer']['source'] == plan['roles']['b2']['producer']['source']
    if a.backend_policy:
        plan['backendPolicy'] = backend_policy(a.backend_policy, plan['roles']['b1']['producer']['source'], b)
    for row in old['inputs']: b.bind(row)
    for row in old['eligible'] + old['excluded']: b.bind(row['source'])
    for row in old['negatives']: b.bind(row['source'])
    selection = dict(cases=[dict(id=x['id'], file=x['source']['file'], lanes=['native']) for x in old['eligible']])
    S.save(out / 'selection.json', selection); plan['selection'] = b.bind(out / 'selection.json')
    assets = ctx['roles']['b2']['admission']
    plan['executionAssets'] = {key:assets[key] for key in ['base', 'runtime', 'template', 'parts', 'effects', 'cache']}
    plan['adapterParent'] = b.bind(PERF / 'phase92/conformance/adapter.mjs')
    plan['diagnosticsParent'] = b.bind(PERF / 'phase92/conformance/diagnostics.mjs')
    plan['adapter'] = b.bind(HERE / 'conformance-adapter.mjs')
    plan['diagnosticsMethod'] = b.bind(HERE / 'conformance-diagnostics.mjs')
    plan['integrityMethod'] = b.bind(HERE / 'conformance_integrity.py')
    plan['semanticCollector'] = b.bind(PERF / 'phase92/conformance/collect.py')
    plan['provenancePolicy'] = 'full-before-after-suite-and-admission'
    plan['executionInputs'] = {stage:execution_inputs(plan, stage, b) for stage in ['b1', 'b2']}
    execution = {row['file']:row for rows in plan['executionInputs'].values() for row in rows}
    plan['inputs'] = [execution[file] for file in sorted(execution)]
    plan['scope'] = 'Phase98 private candidate B1/B2, unchanged Phase92 native69+3 semantic selection, argv and oracle. Full provenance checked per suite; only actual selected execution inputs checked per isolated case.31 exclusions remain untested; no public admission.'
    node = plan['node']['file']; guard = PERF / 'phase86/guard.py'; upstream = ROOT / 'selfhost/.bootstrap/upstream-phase66'
    adapter = Path(plan['adapter']['file']); commands = []
    for role in ['b1', 'b2']:
        env = {**plan['environment'], 'BEND_NATIVE_CONFORMANCE_PLAN':str(out / 'plan.json'), 'BEND_NATIVE_CONFORMANCE_ROLE':role}
        command = [node, '--stack-size=4096', '--max-old-space-size=512', str(ROOT / 'selfhost/tools/conformance/run.mjs'),
                   '--upstream', str(upstream), '--adapter', str(adapter), '--output', str(out / role / 'report.json'),
                   '--jobs', '1', '--timeout', '60000', '--worker-mode', 'isolated', '--stack-kb', '4096', '--heap-mb', '512',
                   '--lanes', 'native', '--selection', str(out / 'selection.json'), '--retain', 'failed', '--selected-exit', '1']
        commands.append(dict(role=role, command=[sys.executable, '-B', str(guard), '--out', str(out / (role+'-guard')),
                            '--seconds', '300', '--rss-mib', '2048', '--available-mib', '4096', '--cpu', '3', '--', 'env',
                            *[k+'='+v for k,v in env.items()], *command]))
    commands.append(dict(role='diagnostics', command=[sys.executable, '-B', str(guard), '--out', str(out / 'diagnostics-guard'),
                        '--seconds', '90', '--rss-mib', '2048', '--available-mib', '4096', '--cpu', '3', '--', node,
                        plan['diagnosticsMethod']['file'], str(out / 'plan.json'), str(out / 'diagnostics')]))
    plan['suiteCommands'] = commands
    plan['provenanceInputs'] = list(b.rows.values())
    plan['inputBytes'] = dict(provenance=sum(row['bytes'] for row in plan['provenanceInputs']),
        perRole={stage:sum(row['bytes'] for row in plan['executionInputs'][stage]) for stage in ['b1', 'b2']})
    validate_partition(plan, b)
    S.save(out / 'plan.json', plan)
    guarded = [dict(role=job['role'], command=[sys.executable, '-B', plan['integrityMethod']['file'],
               'run', '--plan', str(out / 'plan.json'), '--role', job['role']]) for job in commands]
    S.save(out / 'commands.json', guarded)
    b.unchanged()
    print(json.dumps(dict(complete=True, targetsRun=False, plan=str(out / 'plan.json'), jobs=len(commands), inputBytes=plan['inputBytes'])))


if __name__ == '__main__': main()
