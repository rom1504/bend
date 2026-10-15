#!/usr/bin/env python3
"""Offline adapt unchanged native69+3 fixtures/harness to two candidate images."""
import argparse
import copy
import json
from pathlib import Path
import sys
from support import Bindings, ROOT, PERF, S, authenticate, baseline, freeze_methods, native_args, pin, read


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--b1-build', type=Path, required=True)
    p.add_argument('--b2-build', type=Path, required=True)
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
    for row in old['inputs']: b.bind(row)
    for row in old['eligible'] + old['excluded']: b.bind(row['source'])
    for row in old['negatives']: b.bind(row['source'])
    selection = dict(cases=[dict(id=x['id'], file=x['source']['file'], lanes=['native']) for x in old['eligible']])
    S.save(out / 'selection.json', selection); plan['selection'] = b.bind(out / 'selection.json')
    plan['inputs'] = list(b.rows.values())
    plan['scope'] = 'Phase98 private candidate B1/B2, unchanged Phase92 native69+3 selection and adapter protocol.31 module/provider exclusions remain untested; no public admission.'
    S.save(out / 'plan.json', plan)
    node = plan['node']['file']; guard = PERF / 'phase86/guard.py'; upstream = ROOT / 'selfhost/.bootstrap/upstream-phase66'
    adapter = PERF / 'phase92/conformance/adapter.mjs'; commands = []
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
                        str(PERF / 'phase92/conformance/diagnostics.mjs'), str(out / 'plan.json'), str(out / 'diagnostics')]))
    S.save(out / 'commands.json', commands)
    b.unchanged()
    print(json.dumps(dict(complete=True, targetsRun=False, plan=str(out / 'plan.json'), jobs=len(commands))))


if __name__ == '__main__': main()
